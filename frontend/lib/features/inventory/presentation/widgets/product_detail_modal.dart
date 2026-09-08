import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailModal extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic> updatedProduct) onSave;
  final VoidCallback? onDelete;

  const ProductDetailModal({
    super.key,
    required this.product,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costController;
  late TextEditingController _priceController;

  late String _selectedCategory;
  late int _stockPrincipal;
  late int _stockSecundario;
  late String _unit;

  final double _exchangeRate = 36.50;
  bool _isSaving = false;

  final List<String> _categories = ['Alimentos', 'Bebidas', 'Víveres', 'Combos', 'Limpieza', 'General'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name'] ?? '');
    _skuController = TextEditingController(text: widget.product['sku'] ?? '');
    _costController = TextEditingController(
      text: (widget.product['cost_usd'] ?? (widget.product['price_usd'] ?? 1.0) * 0.75).toStringAsFixed(2),
    );
    _priceController = TextEditingController(
      text: ((widget.product['price_usd'] as num?)?.toDouble() ?? 1.0).toStringAsFixed(2),
    );

    _selectedCategory = widget.product['category'] ?? 'General';
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }

    final totalStock = (widget.product['stock'] as num?)?.toInt() ?? 10;
    _stockPrincipal = totalStock > 10 ? totalStock - 10 : totalStock;
    _stockSecundario = totalStock > 10 ? 10 : 0;
    _unit = widget.product['unit'] ?? 'uds';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _currentPrice => double.tryParse(_priceController.text) ?? 0.0;
  double get _currentCost => double.tryParse(_costController.text) ?? 0.0;
  double get _marginPercent {
    if (_currentPrice <= 0) return 0.0;
    return ((_currentPrice - _currentCost) / _currentPrice) * 100;
  }

  void _showStockAdjustDialog(String warehouseName, bool isPrincipal) {
    final qtyController = TextEditingController(text: '1');
    String adjustReason = 'Conteo físico';
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Ajustar Stock - $warehouseName',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('+ Entrada / Sumar'),
                      selected: isAddition,
                      onSelected: (val) => setDialogState(() => isAddition = true),
                      selectedColor: const Color(0xFFD3E3FD),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('— Salida / Restar'),
                      selected: !isAddition,
                      onSelected: (val) => setDialogState(() => isAddition = false),
                      selectedColor: const Color(0xFFFADBD8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad ($_unit)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: adjustReason,
                decoration: InputDecoration(
                  labelText: 'Motivo del ajuste',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Conteo físico', child: Text('Conteo físico')),
                  DropdownMenuItem(value: 'Merma / Daño', child: Text('Merma / Daño')),
                  DropdownMenuItem(value: 'Devolución de cliente', child: Text('Devolución de cliente')),
                  DropdownMenuItem(value: 'Ajuste manual', child: Text('Ajuste manual')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => adjustReason = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final change = int.tryParse(qtyController.text) ?? 0;
                if (change > 0) {
                  setState(() {
                    if (isPrincipal) {
                      _stockPrincipal = isAddition
                          ? _stockPrincipal + change
                          : (_stockPrincipal >= change ? _stockPrincipal - change : 0);
                    } else {
                      _stockSecundario = isAddition
                          ? _stockSecundario + change
                          : (_stockSecundario >= change ? _stockSecundario - change : 0);
                    }
                  });
                }
                Navigator.pop(dialogCtx);
              },
              child: const Text('Aplicar Ajuste'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final totalStock = _stockPrincipal + _stockSecundario;
    final updated = Map<String, dynamic>.from(widget.product);
    updated['name'] = _nameController.text.trim();
    updated['sku'] = _skuController.text.trim();
    updated['category'] = _selectedCategory;
    updated['price_usd'] = _currentPrice;
    updated['cost_usd'] = _currentCost;
    updated['stock'] = totalStock;
    updated['is_low_stock'] = totalStock <= 5;

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isCombo = widget.product['is_combo'] == true;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAED),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cabecera: Título y Cerrar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ficha del Producto',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF202124),
                        ),
                      ),
                      Text(
                        isCombo ? 'Tipo: Paquete / Combo comercial' : 'Tipo: Artículo unitario',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5F6368)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE8EAED)),

              // 1. Nombre del Producto
              Text('Nombre del producto', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF1A73E8)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 14),

              // 2. SKU y Categoría
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código / SKU', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _skuController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            prefixIcon: const Icon(Icons.qr_code, color: Color(0xFF5F6368)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categoría', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Precios y Márgenes
              Text('Precios & Rentabilidad', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Costo USD', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5F6368))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _costController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio Venta USD', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5F6368))),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  isDense: true,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Margen: ${_marginPercent.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _marginPercent >= 15 ? const Color(0xFF34A853) : const Color(0xFFB06020),
                          ),
                        ),
                        Text(
                          'Equivalente: Bs. ${(_currentPrice * _exchangeRate).toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A73E8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Desglose y Control de Almacenes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Existencias por Almacén', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(
                    'Total: ${_stockPrincipal + _stockSecundario} $_unit',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: (_stockPrincipal + _stockSecundario) <= 5
                          ? const Color(0xFFBA1A1A)
                          : const Color(0xFF202124),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Almacén Principal
              _buildWarehouseRow(
                name: 'Almacén Principal',
                stock: _stockPrincipal,
                onAdjust: () => _showStockAdjustDialog('Almacén Principal', true),
              ),
              const SizedBox(height: 8),

              // Depósito Secundario
              _buildWarehouseRow(
                name: 'Depósito 2 (Secundario)',
                stock: _stockSecundario,
                onAdjust: () => _showStockAdjustDialog('Depósito 2 (Secundario)', false),
              ),
              const SizedBox(height: 24),

              // 5. Botones de Acción
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _isSaving ? 'Guardando...' : 'Guardar Cambios',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    if (widget.onDelete != null) widget.onDelete!();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFBA1A1A)),
                  label: Text(
                    'Desactivar producto del inventario',
                    style: GoogleFonts.inter(color: const Color(0xFFBA1A1A), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarehouseRow({
    required String name,
    required int stock,
    required VoidCallback onAdjust,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.warehouse_outlined, size: 20, color: Color(0xFF5F6368)),
              const SizedBox(width: 10),
              Text(
                name,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF202124)),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '$stock $_unit',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: stock <= 3 ? const Color(0xFFBA1A1A) : const Color(0xFF202124),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onAdjust,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ajustar',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF1A73E8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
