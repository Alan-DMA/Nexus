import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // Lista de items en el carrito (inicializada con los ítems del boceto)
  final List<CartItem> _cart = [
    CartItem(
      product: {
        'id': 'p-pepsi-2l',
        'name': 'Pepsi 2L',
        'barcode': '7591007000200',
        'price_usd': 3.00,
      },
      quantity: 2,
      priceUsd: 3.00,
    ),
    CartItem(
      product: {
        'id': 'p-harina-pan',
        'name': 'Harina PAN 1kg',
        'barcode': '7591007000108',
        'price_usd': 1.20,
      },
      quantity: 1,
      priceUsd: 1.20,
    ),
  ];

  List<dynamic> _products = [];
  final double _exchangeRate = 36.50; // Tasa del día
  bool _showVes = false; // Toggle para ver subtotal en VES

  final TextEditingController _searchController = TextEditingController();

  // Controladores para el modal de cobro
  final _usdCashController = TextEditingController(text: '0.00');
  final _vesMobileController = TextEditingController(text: '0.00');
  final _usdZelleController = TextEditingController(text: '0.00');
  final _vesCashController = TextEditingController(text: '0.00');

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _usdCashController.dispose();
    _vesMobileController.dispose();
    _usdZelleController.dispose();
    _vesCashController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final repository = ref.read(salesRepositoryProvider);
      final productsData = await repository.fetchProducts();
      if (mounted) {
        setState(() {
          _products = productsData;
        });
      }
    } catch (_) {}
  }

  double get _totalUsd => _cart.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _totalVes => _totalUsd * _exchangeRate;

  void _incrementQty(int index) {
    setState(() {
      _cart[index].quantity += 1;
    });
  }

  void _decrementQty(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity -= 1;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _addProductByBarcode(String barcode) {
    final product = _products.firstWhere(
      (p) => p['barcode'] == barcode,
      orElse: () => null,
    );

    if (product != null) {
      setState(() {
        final existingIndex = _cart.indexWhere(
          (item) => item.product['id'] == product['id'],
        );
        if (existingIndex >= 0) {
          _cart[existingIndex].quantity += 1;
        } else {
          _cart.add(
            CartItem(
              product: product,
              quantity: 1,
              priceUsd: double.tryParse(product['price_usd'].toString()) ?? 1.0,
            ),
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} agregado al carrito'),
          backgroundColor: const Color(0xFF34A853),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _showQuickCreateDialog(barcode);
    }
  }

  Future<void> _showQuickCreateDialog(String barcode) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => QuickProductModal(initialBarcode: barcode),
    );

    if (result != null) {
      await _loadInitialData();
      _addProductByBarcode(result['barcode'] ?? '');
    }
  }

  void _simulateScan() {
    final list = [
      '7591007000200', // Pepsi 2L
      '7591007000108', // Harina PAN
      '7590001', // Pasta Primor
      '7590002', // Azúcar Montalbán
    ];
    final random = Random();
    final selectedBarcode = list[random.nextInt(list.length)];
    _addProductByBarcode(selectedBarcode);
  }

  void _openPaymentSheet() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'El carrito está vacío. Agrega productos para cobrar.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _usdCashController.text = _totalUsd.toStringAsFixed(2);
    _vesMobileController.text = '0.00';
    _usdZelleController.text = '0.00';
    _vesCashController.text = '0.00';

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final paidUsd = double.tryParse(_usdCashController.text) ?? 0.0;
            final paidZelle = double.tryParse(_usdZelleController.text) ?? 0.0;
            final paidVesCash = double.tryParse(_vesCashController.text) ?? 0.0;
            final paidVesMobile =
                double.tryParse(_vesMobileController.text) ?? 0.0;
            final totalPaidUsd =
                paidUsd +
                paidZelle +
                ((paidVesCash + paidVesMobile) / _exchangeRate);
            final remainingUsd = _totalUsd - totalPaidUsd;

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confirmar Cobro',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$ ${_totalUsd.toStringAsFixed(2)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Equivalente: Bs. ${_totalVes.toStringAsFixed(2)} (Tasa: $_exchangeRate)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Divider(height: 24, color: theme.colorScheme.outline),
                  Text(
                    'Métodos de Pago',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Efectivo USD
                  TextField(
                    controller: _usdCashController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Efectivo USD',
                      prefixIcon: const Icon(
                        Icons.attach_money_rounded,
                        color: Color(0xFF10B981),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 10),
                  // Pago Móvil (VES)
                  TextField(
                    controller: _vesMobileController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Pago Móvil (Bs.)',
                      prefixIcon: const Icon(
                        Icons.phone_android_rounded,
                        color: Color(0xFF38BDF8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  if (remainingUsd > 0.01)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Resta por cubrir: \$ ${remainingUsd.toStringAsFixed(2)} (Bs. ${(remainingUsd * _exchangeRate).toStringAsFixed(2)})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: remainingUsd > 0.05
                          ? null
                          : LinearGradient(
                              colors: [
                                theme.colorScheme.secondary,
                                theme.colorScheme.primary,
                              ],
                            ),
                    ),
                    child: ElevatedButton(
                      onPressed: remainingUsd > 0.05
                          ? null
                          : () {
                              Navigator.pop(context);
                              _finishSale();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Finalizar Venta',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _finishSale() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      setState(() {
        _cart.clear();
      });

      final theme = Theme.of(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                '¡Venta Completada!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'Comprobante VTA-000035 generado exitosamente. Se ha registrado el ingreso y actualizado el inventario.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Volver al Inicio',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProductThumbnail(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pepsi') ||
        lower.contains('refresco') ||
        lower.contains('soda')) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Center(
          child: Icon(
            Icons.local_drink_rounded,
            color: Color(0xFF38BDF8),
            size: 30,
          ),
        ),
      );
    } else if (lower.contains('harina') ||
        lower.contains('pan') ||
        lower.contains('alimento')) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF262010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF423512), width: 0.8),
        ),
        child: const Center(
          child: Icon(
            Icons.breakfast_dining_rounded,
            color: Color(0xFFFACC15),
            size: 30,
          ),
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: Color(0xFF94A3B8),
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Nueva Venta',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                'VTA-000035',
                style: GoogleFonts.jetBrainsMono(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Barra de Búsqueda y Escáner (Píldora Oscura)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Buscar producto o escanear...',
                        hintStyle: GoogleFonts.inter(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _addProductByBarcode(val.trim());
                          _searchController.clear();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    onPressed: _simulateScan,
                    tooltip: 'Escanear código de barras',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // 2. Lista de Productos del Carrito
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 54,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'El carrito está vacío',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _cart.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _cart.length) {
                        // 3. Botón "+ Agregar producto al vuelo"
                        return Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                          child: InkWell(
                            onTap: () => _showQuickCreateDialog(''),
                            borderRadius: BorderRadius.circular(16),
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.6,
                                ),
                                strokeWidth: 1.2,
                                dashWidth: 5.0,
                                dashSpace: 4.0,
                                borderRadius: 16.0,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+ Agregar producto al vuelo',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final item = _cart[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Miniatura del producto
                            _buildProductThumbnail(item.product['name'] ?? ''),
                            const SizedBox(width: 14),

                            // Nombre y Precio unitario
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product['name'] ?? 'Producto',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$ ${item.priceUsd.toStringAsFixed(2)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stepper de Cantidad (Píldora)
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botón Menos
                                  InkWell(
                                    onTap: () => _decrementQty(index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Icon(
                                        Icons.remove_rounded,
                                        size: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  // Cantidad
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      'x${item.quantity.toInt()}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  // Botón Más (Badge circular azul)
                                  InkWell(
                                    onTap: () => _incrementQty(index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.colorScheme.secondary
                                            .withValues(alpha: 0.3),
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 4. Panel Inferior Fijo de Cobro
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fila Subtotal y Ver en VES
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUBTOTAL',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _showVes
                                ? 'Bs. ${_totalVes.toStringAsFixed(2)}'
                                : '\$ ${_totalUsd.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showVes = !_showVes;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            _showVes ? 'VER EN USD' : 'VER EN VES',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botón "Cobrar"
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.primary,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _openPaymentSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cobrar   \$ ${_totalUsd.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor personalizado para el borde discontinuo (dashed border)
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
