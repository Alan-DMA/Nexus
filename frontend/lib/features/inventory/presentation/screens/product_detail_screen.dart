import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic> updatedProduct)? onSave;
  final VoidCallback? onDelete;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onSave,
    this.onDelete,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Map<String, dynamic> _product;
  final double _exchangeRate = 36.50;

  late int _stockAvailable;
  late int _stockReserved;
  late double _priceUsd;
  late double _costUsd;

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);

    final rawStock = (_product['stock'] as num?)?.toInt() ?? 48;
    _stockAvailable = rawStock;
    _stockReserved = 2; // Simulación de reservas por ventas pendientes
    _priceUsd = (_product['price_usd'] as num?)?.toDouble() ?? 1.50;
    _costUsd = (_product['cost_usd'] as num?)?.toDouble() ?? 0.90;
  }

  double get _marginPercent {
    if (_priceUsd <= 0) return 0.0;
    return ((_priceUsd - _costUsd) / _priceUsd) * 100;
  }

  void _openEditModal() {
    final nameCtrl = TextEditingController(text: _product['name']);
    final skuCtrl = TextEditingController(text: _product['sku']);
    final priceCtrl = TextEditingController(text: _priceUsd.toStringAsFixed(2));
    final costCtrl = TextEditingController(text: _costUsd.toStringAsFixed(2));
    String category = _product['category'] ?? 'Bebidas';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar Producto',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(labelText: 'Código / SKU'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(value: 'Bebidas', child: Text('Bebidas')),
                    DropdownMenuItem(
                      value: 'Alimentos',
                      child: Text('Alimentos'),
                    ),
                    DropdownMenuItem(value: 'Víveres', child: Text('Víveres')),
                    DropdownMenuItem(value: 'Combos', child: Text('Combos')),
                    DropdownMenuItem(value: 'General', child: Text('General')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Precio USD',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: costCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Costo USD',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _product['name'] = nameCtrl.text.trim();
                  _product['sku'] = skuCtrl.text.trim();
                  _product['category'] = category;
                  _priceUsd = double.tryParse(priceCtrl.text) ?? _priceUsd;
                  _costUsd = double.tryParse(costCtrl.text) ?? _costUsd;
                  _product['price_usd'] = _priceUsd;
                  _product['cost_usd'] = _costUsd;
                });
                if (widget.onSave != null) {
                  widget.onSave!(_product);
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto actualizado exitosamente'),
                    backgroundColor: Color(0xFF34A853),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _openStockAdjustModal() {
    final qtyCtrl = TextEditingController(text: '1');
    bool isAddition = true;
    String reason = 'Conteo físico';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ajustar Stock',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('+ Sumar'),
                      selected: isAddition,
                      selectedColor: const Color(0xFFD3E3FD),
                      onSelected: (val) =>
                          setDialogState(() => isAddition = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('— Restar'),
                      selected: !isAddition,
                      selectedColor: const Color(0xFFFADBD8),
                      onSelected: (val) =>
                          setDialogState(() => isAddition = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de unidades',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: reason,
                decoration: const InputDecoration(
                  labelText: 'Motivo del ajuste',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Conteo físico',
                    child: Text('Conteo físico'),
                  ),
                  DropdownMenuItem(
                    value: 'Merma / Daño',
                    child: Text('Merma / Daño'),
                  ),
                  DropdownMenuItem(
                    value: 'Devolución',
                    child: Text('Devolución'),
                  ),
                  DropdownMenuItem(
                    value: 'Ajuste manual',
                    child: Text('Ajuste manual'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => reason = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty > 0) {
                  setState(() {
                    _stockAvailable = isAddition
                        ? _stockAvailable + qty
                        : (_stockAvailable >= qty ? _stockAvailable - qty : 0);
                    _product['stock'] = _stockAvailable;
                    _product['is_low_stock'] = _stockAvailable <= 5;
                  });
                  if (widget.onSave != null) {
                    widget.onSave!(_product);
                  }
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock actualizado: $_stockAvailable uds'),
                    backgroundColor: const Color(0xFF34A853),
                  ),
                );
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  void _openPrintLabelModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.print_outlined, color: Color(0xFF1A73E8)),
            const SizedBox(width: 10),
            Text(
              'Imprimir Etiqueta',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAED), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    _product['name'],
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$ ${_priceUsd.toStringAsFixed(2)}  /  Bs. ${(_priceUsd * _exchangeRate).toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: const Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.qr_code_2,
                    size: 64,
                    color: Color(0xFF202124),
                  ),
                  Text(
                    _product['sku'],
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: const Color(0xFF5F6368),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Comando de impresión enviado a impresora de tickets',
                  ),
                  backgroundColor: Color(0xFF34A853),
                ),
              );
            },
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  void _openTransferModal() {
    final qtyCtrl = TextEditingController(text: '5');
    String dest = 'Depósito 2 (Secundario)';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Trasladar Stock',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mover ${_product['name']} desde Almacén Principal',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF5F6368),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: dest,
                decoration: const InputDecoration(labelText: 'Almacén Destino'),
                items: const [
                  DropdownMenuItem(
                    value: 'Depósito 2 (Secundario)',
                    child: Text('Depósito 2 (Secundario)'),
                  ),
                  DropdownMenuItem(
                    value: 'Bodega Central',
                    child: Text('Bodega Central'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => dest = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad a trasladar',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty > 0 && qty <= _stockAvailable) {
                  setState(() {
                    _stockAvailable -= qty;
                    _product['stock'] = _stockAvailable;
                  });
                  if (widget.onSave != null) widget.onSave!(_product);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trasladadas $qty uds a $dest'),
                      backgroundColor: const Color(0xFF1A73E8),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cantidad no válida o excede el stock'),
                    ),
                  );
                }
              },
              child: const Text('Confirmar Traslado'),
            ),
          ],
        ),
      ),
    );
  }

  void _openMovementsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Movimientos de Kardex',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Historial de ${_product['name']}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF5F6368),
              ),
            ),
            const Divider(height: 24),
            _buildMovementRow(
              'ENTRADA',
              '+24 uds',
              'Carga por Nota de Entrega #4501',
              'Hoy 10:30 AM',
              const Color(0xFF34A853),
            ),
            const SizedBox(height: 12),
            _buildMovementRow(
              'SALIDA',
              '-2 uds',
              'Venta comprobante VTA-000035',
              'Hoy 02:15 PM',
              const Color(0xFFBA1A1A),
            ),
            const SizedBox(height: 12),
            _buildMovementRow(
              'TRASLADO',
              '-5 uds',
              'Hacia Depósito 2 (Secundario)',
              'Ayer 04:00 PM',
              const Color(0xFF1A73E8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementRow(
    String type,
    String qty,
    String detail,
    String time,
    Color badgeColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            type,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF5F6368),
                ),
              ),
            ],
          ),
        ),
        Text(
          qty,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: badgeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductBanner() {
    final name = _product['name'].toString().toLowerCase();

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3547)),
      ),
      child: Center(
        child: name.contains('pepsi')
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF003087),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF0065C3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0065C3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Icon(Icons.circle, color: Colors.white, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'PEPSI',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : name.contains('harina')
            ? Container(
                width: 100,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE0B800),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.breakfast_dining,
                        size: 42,
                        color: Color(0xFF003087),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'P.A.N.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: const Color(0xFF003087),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
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
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          _product['name'],
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
            tooltip: 'Editar producto',
            onPressed: _openEditModal,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.onSurface,
            ),
            color: theme.colorScheme.surface,
            onSelected: (val) {
              if (val == 'desactivar') {
                if (widget.onDelete != null) widget.onDelete!();
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'desactivar',
                child: Text(
                  'Desactivar producto',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              PopupMenuItem(
                value: 'duplicar',
                child: Text(
                  'Duplicar producto',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.colorScheme.outline),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner de la Imagen del Producto
            _buildProductBanner(),
            const SizedBox(height: 16),

            // 2. Título y Fila de SKU / Categoría
            Text(
              _product['name'],
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Text(
                    _product['sku'],
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _product['category'] ?? 'Bebidas',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Sección "Precios"
            Row(
              children: [
                Text(
                  'Precios',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Precio Venta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precio venta',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_priceUsd.toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bs.  ${(_priceUsd * _exchangeRate).toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: theme.colorScheme.outline, height: 1),
            const SizedBox(height: 10),

            // Costo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Costo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${_costUsd.toStringAsFixed(2)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: theme.colorScheme.outline, height: 1),
            const SizedBox(height: 10),

            // Margen de Ganancia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Margen de ganancia',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${_marginPercent.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Sección "Stock"
            Row(
              children: [
                Text(
                  'Stock',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outline,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tarjetas KPI DISPONIBLE y RESERVADO
            Row(
              children: [
                // Disponible (Dark Green Card)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF059669).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DISPONIBLE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF34D399),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_stockAvailable',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF34D399),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Reservado (Dark Yellow/Orange Card)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF78350F).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD97706).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESERVADO',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_stockReserved',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Indicador Stock mínimo
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Stock mínimo: ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '10 uds',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 5. Cuadrícula de Acciones (2x2)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.fact_check_outlined,
                    label: 'Ajustar stock',
                    onTap: _openStockAdjustModal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.print_outlined,
                    label: 'Imprimir etiqueta',
                    onTap: _openPrintLabelModal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.sync_alt,
                    label: 'Trasladar',
                    onTap: _openTransferModal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.history,
                    label: 'Ver movimientos',
                    onTap: _openMovementsModal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
