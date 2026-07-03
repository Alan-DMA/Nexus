import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/sales/data/sales_client.dart';
import 'quick_product_modal.dart';

class CartItem {
  final Map<String, dynamic> product;
  double quantity;
  double priceUsd;

  CartItem({
    required this.product,
    required this.quantity,
    required this.priceUsd,
  });

  double get subtotal => quantity * priceUsd;
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // Lista de items en el carrito
  final List<CartItem> _cart = [];
  
  // Lista global de productos cargados del backend
  List<dynamic> _products = [];
  bool _isLoadingProducts = true;
  double _exchangeRate = 40.0; // Tasa por defecto
  String _tenantName = "Mi Bodega";

  // Formulario y Controladores de Pago
  final _usdCashController = TextEditingController(text: '0.00');
  final _vesCashController = TextEditingController(text: '0.00');
  final _vesMobileController = TextEditingController(text: '0.00');
  final _usdZelleController = TextEditingController(text: '0.00');

  bool _isProcessingCheckout = false;
  String? _checkoutError;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _usdCashController.dispose();
    _vesCashController.dispose();
    _vesMobileController.dispose();
    _usdZelleController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final repository = ref.read(salesRepositoryProvider);
      
      // Obtener productos
      final productsData = await repository.fetchProducts();
      
      // Intentar obtener tasa de cambio real e inquilino desde Dio o cache
      // En producción, esto se guarda en la base de datos o Hive
      // Aquí consultamos las variables del endpoint de productos para ver si la tasa está en el Tenant
      // Para simplificar, usamos un valor por defecto o leemos el backend
      setState(() {
        _products = productsData;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  // Agregar producto al carrito por código de barras
  void _addProductByBarcode(String barcode) {
    // Buscar en productos cargados
    final product = _products.firstWhere(
      (p) => p['barcode'] == barcode,
      orElse: () => null,
    );

    if (product != null) {
      setState(() {
        // Buscar si ya está en el carrito
        final existingIndex = _cart.indexWhere((item) => item.product['id'] == product['id']);
        if (existingIndex >= 0) {
          _cart[existingIndex].quantity += 1;
        } else {
          _cart.add(CartItem(
            product: product,
            quantity: 1,
            priceUsd: double.parse(product['price_usd'].toString()),
          ));
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} agregado al carrito.'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Si no existe, invitar a crearlo al vuelo
      _showQuickCreateDialog(barcode);
    }
  }

  // Abrir Modal de Producto al Vuelo
  Future<void> _showQuickCreateDialog(String barcode) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => QuickProductModal(initialBarcode: barcode),
    );

    if (result != null) {
      // Recargar lista de productos del backend
      await _loadInitialData();
      
      // Agregar al carrito
      _addProductByBarcode(result['barcode']);
    }
  }

  // Cálculos de Totales
  double get _totalUsd => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _totalVes => _totalUsd * _exchangeRate;

  // Cálculos de Pagos Ingresados
  double get _paidUsdCash => double.tryParse(_usdCashController.text) ?? 0.0;
  double get _paidVesCash => double.tryParse(_vesCashController.text) ?? 0.0;
  double get _paidVesMobile => double.tryParse(_vesMobileController.text) ?? 0.0;
  double get _paidUsdZelle => double.tryParse(_usdZelleController.text) ?? 0.0;

  double get _totalPaidUsd {
    double total = 0.0;
    total += _paidUsdCash;
    total += _paidUsdZelle;
    total += _paidVesCash / _exchangeRate;
    total += _paidVesMobile / _exchangeRate;
    return total;
  }

  double get _remainingUsd => _totalUsd - _totalPaidUsd;
  double get _remainingVes => _remainingUsd * _exchangeRate;

  // Lógica de Checkout Secuencial Completo
  Future<void> _processCheckout() async {
    if (_cart.isEmpty) {
      setState(() => _checkoutError = "El carrito de compras está vacío.");
      return;
    }

    if (_remainingUsd > 0.01) {
      setState(() => _checkoutError = "Pago incompleto. Aún resta por pagar \$${_remainingUsd.toStringAsFixed(2)}");
      return;
    }

    setState(() {
      _isProcessingCheckout = true;
      _checkoutError = null;
    });

    try {
      final repository = ref.read(salesRepositoryProvider);

      // 1. Preparar ítems para creación
      final itemsPayload = _cart.map((item) => {
        'product_id': item.product['id'],
        'quantity': item.quantity,
        'unit_price_usd': item.priceUsd,
      }).toList();

      // 2. Crear Venta (Estado inicial: DRAFT)
      final sale = await repository.createSale(items: itemsPayload);
      final saleId = sale['id'];

      // 3. Transicionar a PENDING_PAYMENT (Reservar Stock)
      await repository.transitionSale(saleId: saleId, newStatus: 'PENDING_PAYMENT');

      // 4. Registrar los pagos mixtos
      final List<Map<String, dynamic>> paymentsPayload = [];
      if (_paidUsdCash > 0) {
        paymentsPayload.add({
          'payment_method': 'EFECTIVO_USD',
          'amount_usd': _paidUsdCash,
          'amount_ves': 0.00
        });
      }
      if (_paidUsdZelle > 0) {
        paymentsPayload.add({
          'payment_method': 'ZELLE',
          'amount_usd': _paidUsdZelle,
          'amount_ves': 0.00,
          'reference_number': 'Zelle'
        });
      }
      if (_paidVesCash > 0) {
        paymentsPayload.add({
          'payment_method': 'EFECTIVO_VES',
          'amount_usd': _paidVesCash / _exchangeRate,
          'amount_ves': _paidVesCash
        });
      }
      if (_paidVesMobile > 0) {
        paymentsPayload.add({
          'payment_method': 'PAGO_MOVIL',
          'amount_usd': _paidVesMobile / _exchangeRate,
          'amount_ves': _paidVesMobile,
          'reference_number': 'PagoMovil'
        });
      }

      await repository.addPayments(saleId: saleId, payments: paymentsPayload);

      // 5. Transicionar a PAID (Valida montos y comisiones)
      await repository.transitionSale(saleId: saleId, newStatus: 'PAID');

      // 6. Transicionar a COMPLETED (Despacho final)
      await repository.transitionSale(saleId: saleId, newStatus: 'COMPLETED');

      // Limpiar carrito y pagos
      setState(() {
        _cart.clear();
        _usdCashController.text = '0.00';
        _vesCashController.text = '0.00';
        _vesMobileController.text = '0.00';
        _usdZelleController.text = '0.00';
        _isProcessingCheckout = false;
      });

      // Mostrar Dialogo de Éxito
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkSurface,
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppTheme.success),
                SizedBox(width: 10),
                Text('¡Checkout Completado!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: const Text(
              'La venta ha sido registrada, pagada y despachada con éxito. Se ha descontado el stock de inventario.',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar', style: TextStyle(color: AppTheme.primary)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessingCheckout = false;
        _checkoutError = 'Fallo en checkout: ${e.toString()}';
      });
    }
  }

  // Simulación de Escaneo de Códigos de Barras
  void _simulateScan() {
    // Lista de códigos de barra pre-establecidos para test
    final list = [
      'BarHarina1', // Harina de prueba
      '7591007000108', // Harina PAN (No existe, abrirá el modal al vuelo)
      '7590001', // Pasta Primor (Cargada en CSV)
      '7590002', // Azúcar Montalbán (Cargada en CSV)
    ];

    final random = Random();
    final selectedBarcode = list[random.nextInt(list.length)];
    
    _addProductByBarcode(selectedBarcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Rápido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadInitialData,
          )
        ],
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LADO IZQUIERDO: Escáner y Carrito
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CÁMARA ESCÁNER MOCK
                        Card(
                          color: AppTheme.darkSurface,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.primary, width: 1.5),
                                  ),
                                  child: const Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        child: Text(
                                          '[ MODO CÁMARA ACTIVO ]',
                                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                        ),
                                      ),
                                      // Laser animado de escaneo
                                      Divider(
                                        color: Colors.red,
                                        thickness: 1.5,
                                        indent: 40,
                                        endIndent: 40,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _simulateScan,
                                  icon: const Icon(Icons.qr_code_scanner_outlined),
                                  label: const Text('SIMULAR ESCANEO (BARRAS)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // LISTA DEL CARRITO
                        const Text(
                          'Detalles de la Venta',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: _cart.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Escanea o registra productos para comenzar la venta.',
                                      style: TextStyle(color: Color(0xFF64748B)),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _cart.length,
                                    separatorBuilder: (c, idx) => const Divider(color: Color(0xFF1E293B)),
                                    itemBuilder: (c, index) {
                                      final item = _cart[index];
                                      return ListTile(
                                        title: Text(item.product['name'], style: const TextStyle(color: Colors.white)),
                                        subtitle: Text(
                                          'Precio: \$${item.priceUsd.toStringAsFixed(2)} | Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(color: Color(0xFF94A3B8)),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
                                              onPressed: () {
                                                setState(() {
                                                  if (item.quantity > 1) {
                                                    item.quantity -= 1;
                                                  } else {
                                                    _cart.removeAt(index);
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              item.quantity.toStringAsFixed(0),
                                              style: const TextStyle(fontSize: 16, color: Colors.white),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, color: AppTheme.success),
                                              onPressed: () {
                                                setState(() {
                                                  item.quantity += 1;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // LADO DERECHO: Pagos y Confirmación
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: AppTheme.darkSurface,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Resumen de Totales',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total USD:', style: TextStyle(color: Color(0xFF94A3B8))),
                                Text(
                                  '\$${_totalUsd.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total VES (tasa 40):', style: TextStyle(color: Color(0xFF94A3B8))),
                                Text(
                                  'Bs. ${_totalVes.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF1E293B), height: 32),
                            const Text(
                              'Métodos de Pago (Mixto)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            // Inputs de pago
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _usdCashController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Efectivo \$'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _vesCashController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Efectivo Bs.'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _usdZelleController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Zelle \$'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _vesMobileController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Pago Móvil Bs.'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF1E293B), height: 32),
                            // Indicadores de Vuelto / Resto
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _remainingUsd <= 0.005 ? AppTheme.success.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _remainingUsd <= 0.005 ? 'Vuelto / Cambio:' : 'Resta por pagar:',
                                    style: TextStyle(
                                      color: _remainingUsd <= 0.005 ? AppTheme.success : AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '\$${_remainingUsd.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: _remainingUsd <= 0.005 ? AppTheme.success : AppTheme.accent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_checkoutError != null) ...[
                              Text(
                                _checkoutError!,
                                style: const TextStyle(color: AppTheme.error, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                            ],
                            ElevatedButton(
                              onPressed: _isProcessingCheckout ? null : _processCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                              child: _isProcessingCheckout
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('CONFIRMAR Y PROCESAR CHECKOUT'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
