import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/sales/data/sales_client.dart';
import 'package:frontend/features/sales/presentation/quick_product_modal.dart';
import 'package:frontend/features/inventory/presentation/widgets/inventory_operations_modal.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/inventory/presentation/screens/product_detail_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final String initialFilter;

  const InventoryScreen({super.key, this.initialFilter = 'Todos'});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  late String _selectedFilter;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  // Lista de inventario inicializada fielmente al boceto
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'id': '1',
      'name': 'Pepsi 2L',
      'sku': '7591024100016',
      'price_usd': 1.50,
      'cost_usd': 1.10,
      'stock': 48,
      'unit': 'uds',
      'is_low_stock': false,
      'is_combo': false,
      'category': 'Bebidas',
    },
    {
      'id': '2',
      'name': 'Harina PAN 1kg',
      'sku': '7591234500012',
      'price_usd': 1.20,
      'cost_usd': 0.90,
      'stock': 3,
      'unit': 'uds',
      'is_low_stock': true,
      'is_combo': false,
      'category': 'Alimentos',
    },
    {
      'id': '3',
      'name': 'Combo Desayuno',
      'sku': 'CMB-001',
      'price_usd': 4.50,
      'cost_usd': 3.20,
      'stock': 12,
      'unit': 'sets',
      'is_low_stock': false,
      'is_combo': true,
      'combo_info': '6 productos incluidos',
      'category': 'Combos',
    },
  ];

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter.toLowerCase();
    if (filter.contains('stock') || filter.contains('bajo')) {
      _selectedFilter = '⚠️ Stock Bajo';
    } else {
      _selectedFilter = widget.initialFilter;
    }
    _fetchBackendProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBackendProducts() async {
    try {
      final repository = ref.read(salesRepositoryProvider);
      final products = await repository.fetchProducts();
      if (mounted && products.isNotEmpty) {
        setState(() {
          for (final p in products) {
            final barcode = p['barcode'] ?? p['sku'] ?? '';
            final exists = _inventoryItems.any(
              (item) => item['sku'] == barcode || item['id'] == p['id']?.toString(),
            );
            if (!exists) {
              final double price = double.tryParse(p['price_mxn']?.toString() ?? p['price_usd']?.toString() ?? '1.0') ?? 1.0;
              final double cost = double.tryParse(p['cost_mxn']?.toString() ?? p['cost_usd']?.toString() ?? '0.80') ?? 0.80;
              final num stockVal = (p['total_stock'] is num) 
                  ? p['total_stock'] 
                  : (double.tryParse(p['total_stock']?.toString() ?? p['stock']?.toString() ?? '25') ?? 25);
              _inventoryItems.add({
                'id': p['id'].toString(),
                'name': p['name'] ?? 'Producto',
                'sku': barcode.isNotEmpty ? barcode : 'SKU-00${p['id']}',
                'price_usd': price,
                'cost_usd': cost,
                'stock': stockVal,
                'unit': 'uds',
                'is_low_stock': p['is_low_stock'] == true,
                'is_combo': false,
                'category': p['category_name'] ?? p['category'] ?? 'General',
              });
            }
          }
        });
      }
    } catch (_) {}
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _inventoryItems.where((item) {
      // 1. Filtro de búsqueda
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final name = item['name'].toString().toLowerCase();
        final sku = item['sku'].toString().toLowerCase();
        if (!name.contains(query) && !sku.contains(query)) {
          return false;
        }
      }

      // 2. Filtro de chips
      if (_selectedFilter == 'Stock bajo') {
        return item['is_low_stock'] == true || (item['stock'] as num) <= 5;
      }

      // 3. Filtro de categoría
      if (_selectedCategory != null) {
        return item['category'] == _selectedCategory;
      }

      return true;
    }).toList();
  }

  void _openProductDetail(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: item,
          onSave: (updated) {
            setState(() {
              final index = _inventoryItems.indexWhere(
                (p) => p['id'] == item['id'],
              );
              if (index >= 0) {
                _inventoryItems[index] = updated;
              }
            });
          },
          onDelete: () {
            setState(() {
              _inventoryItems.removeWhere((p) => p['id'] == item['id']);
            });
          },
        ),
      ),
    );
  }

  void _openOperationsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InventoryOperationsModal(
        products: _inventoryItems,
        onOperationComplete:
            ({
              required String type,
              required String productName,
              required int quantity,
              required String warehouse,
              String? documentNumber,
              String? supplier,
            }) {
              setState(() {
                final index = _inventoryItems.indexWhere(
                  (p) => p['name'] == productName,
                );
                if (index >= 0) {
                  _inventoryItems[index]['stock'] =
                      (_inventoryItems[index]['stock'] as int) + quantity;
                  _inventoryItems[index]['is_low_stock'] =
                      (_inventoryItems[index]['stock'] as int) <= 5;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Entrada de $quantity uds de $productName registrada por $type ($documentNumber) en $warehouse',
                  ),
                  backgroundColor: const Color(0xFF34A853),
                ),
              );
            },
        onTransferComplete:
            ({
              required String productName,
              required int quantity,
              required String originWarehouse,
              required String targetWarehouse,
            }) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Traslado de $quantity uds de $productName desde $originWarehouse a $targetWarehouse completado',
                  ),
                  backgroundColor: const Color(0xFF1A73E8),
                ),
              );
            },
      ),
    );
  }

  Future<void> _openQuickCreate() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const QuickProductModal(),
    );

    if (result != null) {
      setState(() {
        _inventoryItems.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': result['name'] ?? 'Nuevo Producto',
          'sku': result['barcode'] ?? 'SKU-${Random().nextInt(99999)}',
          'price_usd': double.tryParse(result['price_usd'].toString()) ?? 1.0,
          'cost_usd':
              double.tryParse(result['cost_usd']?.toString() ?? '0.80') ?? 0.80,
          'stock':
              int.tryParse(result['stock_inicial']?.toString() ?? '10') ?? 10,
          'unit': 'uds',
          'is_low_stock': false,
          'is_combo': false,
          'category': 'General',
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['name']} agregado al inventario'),
            backgroundColor: const Color(0xFF34A853),
          ),
        );
      }
    }
  }

  void _simulateScan() {
    final barcodes = ['7591024100016', '7591234500012', 'CMB-001'];
    final picked = barcodes[Random().nextInt(barcodes.length)];
    setState(() {
      _searchController.text = picked;
    });
  }

  Widget _buildProductThumbnail(Map<String, dynamic> item) {
    final name = (item['name'] ?? '').toString().toLowerCase();
    if (item['is_combo'] == true) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF2E1A47),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF5B308C)),
        ),
        child: const Center(
          child: Icon(
            Icons.inventory_2_rounded,
            color: Color(0xFFA855F7),
            size: 28,
          ),
        ),
      );
    } else if (name.contains('pepsi') ||
        name.contains('refresco') ||
        name.contains('soda')) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
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
    } else if (name.contains('harina') ||
        name.contains('pan') ||
        name.contains('alimento')) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF262010),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF423512)),
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
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    bool isWarning = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    Color bgColor = isSelected
        ? (isWarning
              ? AppTheme.warningOrange.withValues(alpha: 0.2)
              : theme.colorScheme.secondary.withValues(alpha: 0.3))
        : theme.colorScheme.surfaceContainerHighest;
    Color textColor = isSelected
        ? (isWarning ? AppTheme.warningOrange : theme.colorScheme.primary)
        : theme.colorScheme.onSurface;
    BorderSide borderSide = isSelected
        ? BorderSide(
            color: isWarning
                ? AppTheme.warningOrange
                : theme.colorScheme.primary,
            width: 1.2,
          )
        : BorderSide(color: theme.colorScheme.outline);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.fromBorderSide(borderSide),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Inventario',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Botón Operaciones de Inventario (Traslados y Carga)
          IconButton(
            icon: Icon(
              Icons.swap_horiz_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
            tooltip: 'Cargas y Traslados de Almacén',
            onPressed: _openOperationsModal,
          ),
          // Botón Agregar Producto
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: theme.colorScheme.onSurface,
              size: 26,
            ),
            onPressed: _openQuickCreate,
            tooltip: 'Crear nuevo producto',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Buscador y Escáner (Píldora Oscura)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
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
                        hintText: 'Buscar producto o escanear..',
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
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    onPressed: _simulateScan,
                    tooltip: 'Escanear código',
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // 2. Chips de Filtrado Horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  // Chip "Todos"
                  _buildFilterChip(
                    label: 'Todos',
                    isSelected:
                        _selectedFilter == 'Todos' && _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Todos';
                        _selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 10),

                  // Chip "Categoría ▾"
                  PopupMenuButton<String>(
                    onSelected: (cat) {
                      setState(() {
                        _selectedFilter = 'Categoría';
                        _selectedCategory = cat == 'Todas' ? null : cat;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: theme.colorScheme.surface,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Todas',
                        child: Text(
                          'Todas las categorías',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Alimentos',
                        child: Text(
                          'Alimentos',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Bebidas',
                        child: Text(
                          'Bebidas',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Combos',
                        child: Text(
                          'Combos',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Víveres',
                        child: Text(
                          'Víveres',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedCategory != null
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCategory ?? 'Categoría',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Chip "⚠️ Stock bajo" (Naranja destacado en dark mode)
                  _buildFilterChip(
                    label: '⚠️ Stock bajo',
                    isSelected: _selectedFilter == 'Stock bajo',
                    isWarning: true,
                    onTap: () {
                      setState(() {
                        if (_selectedFilter == 'Stock bajo') {
                          _selectedFilter = 'Todos';
                        } else {
                          _selectedFilter = 'Stock bajo';
                          _selectedCategory = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Tarjeta resumen total productos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} productos en lista',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Almacén Principal',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Lista de Ítems de Inventario
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 54,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No se encontraron productos',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isLowStock =
                          item['is_low_stock'] == true ||
                          (item['stock'] as num) <= 5;
                      final isCombo = item['is_combo'] == true;

                      return InkWell(
                        onTap: () => _openProductDetail(item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLowStock
                                  ? AppTheme.warningOrange.withValues(
                                      alpha: 0.6,
                                    )
                                  : theme.colorScheme.outline,
                              width: isLowStock ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Miniatura
                              _buildProductThumbnail(item),
                              const SizedBox(width: 14),

                              // Detalles (Nombre, SKU, Costo/Precio)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['name'] ?? 'Producto',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isCombo)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              left: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF5B308C,
                                              ).withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'COMBO',
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFFA855F7),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'SKU: ${item['sku']}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '\$ ${(item['price_usd'] as num).toStringAsFixed(2)}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Costo: \$ ${(item['cost_usd'] as num).toStringAsFixed(2)}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 12,
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Badge de Stock
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? AppTheme.warningOrange.withValues(
                                          alpha: 0.18,
                                        )
                                      : AppTheme.successGreen.withValues(
                                          alpha: 0.15,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isLowStock
                                        ? AppTheme.warningOrange.withValues(
                                            alpha: 0.5,
                                          )
                                        : AppTheme.successGreen.withValues(
                                            alpha: 0.4,
                                          ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${item['stock']} ${item['unit'] ?? 'uds'}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isLowStock
                                            ? AppTheme.warningOrange
                                            : AppTheme.successGreen,
                                      ),
                                    ),
                                    if (isLowStock)
                                      Text(
                                        'Stock bajo',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.warningOrange,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
