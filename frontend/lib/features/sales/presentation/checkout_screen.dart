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
          backgroundColor: Colors.green,
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'VTA-TEMP',
                style: AppTheme.numericMd(context).copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onSurfaceVariant),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Buscar producto...',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.camera_alt),
                                      onPressed: _simulateScan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // LISTA DEL CARRITO
                        Expanded(
                          child: Card(
                            child: _cart.isEmpty
                                ? Center(
                                    child: Text(
                                      'Aún no tienes productos.\nAgrega tu primer producto o escanea.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _cart.length,
                                    separatorBuilder: (c, idx) => const Divider(height: 1),
                                    itemBuilder: (c, index) {
                                      final item = _cart[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            // Imagen placeholder
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.surfaceVariant,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.inventory_2, color: Colors.grey),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.product['name'], style: theme.textTheme.bodyLarge),
                                                  Text(
                                                    'SKU: ${item.product['barcode'] ?? 'N/A'}',
                                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Precio unitario
                                            Text(
                                              '\$${item.priceUsd.toStringAsFixed(2)}',
                                              style: AppTheme.numericMd(context).copyWith(color: theme.colorScheme.primary),
                                            ),
                                            const SizedBox(width: 16),
                                            // Controles de cantidad
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove, size: 20),
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
                                                  'x${item.quantity.toStringAsFixed(0)}',
                                                  style: AppTheme.numericMd(context),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add, size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      item.quantity += 1;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                              onPressed: () {
                                                setState(() {
                                                  _cart.removeAt(index);
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
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Subtotal:',
                              style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${_totalUsd.toStringAsFixed(2)}',
                              style: AppTheme.numericLg(context).copyWith(fontSize: 32),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.arrow_downward, size: 16),
                              label: Text('ver en VES (Bs. ${_totalVes.toStringAsFixed(2)})'),
                            ),
                            const Divider(height: 32),
                            Text(
                              'Métodos de Pago',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            // Inputs de pago
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _usdCashController,
                                    keyboardType: TextInputType.number,
                                    style: AppTheme.numericMd(context),
                                    decoration: const InputDecoration(labelText: 'Efectivo \$'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _vesCashController,
                                    keyboardType: TextInputType.number,
                                    style: AppTheme.numericMd(context),
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
                                    style: AppTheme.numericMd(context),
                                    decoration: const InputDecoration(labelText: 'Zelle \$'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _vesMobileController,
                                    keyboardType: TextInputType.number,
                                    style: AppTheme.numericMd(context),
                                    decoration: const InputDecoration(labelText: 'Pago Móvil Bs.'),
                                    onChanged: (val) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            // Indicadores de Vuelto / Resto
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _remainingUsd <= 0.005 ? 'Vuelto en USD:' : 'Falta:',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                  Text(
                                    '\$${_remainingUsd.abs().toStringAsFixed(2)}',
                                    style: AppTheme.numericLg(context).copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_checkoutError != null) ...[
                              Text(
                                _checkoutError!,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              height: 56, // Altura dictada por el PDF
                              child: ElevatedButton(
                                onPressed: (_isProcessingCheckout || _remainingUsd > 0.01 || _cart.isEmpty) ? null : _processCheckout,
                                child: _isProcessingCheckout
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text('Procesando...'),
                                        ],
                                      )
                                    : Text('Cobrar \$${_totalUsd.toStringAsFixed(2)}'),
                              ),
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
