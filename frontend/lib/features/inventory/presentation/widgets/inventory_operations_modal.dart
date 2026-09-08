import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryOperationsModal extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Function({
    required String type,
    required String productName,
    required int quantity,
    required String warehouse,
    String? documentNumber,
    String? supplier,
  }) onOperationComplete;

  final Function({
    required String productName,
    required int quantity,
    required String originWarehouse,
    required String targetWarehouse,
  }) onTransferComplete;

  const InventoryOperationsModal({
    super.key,
    required this.products,
    required this.onOperationComplete,
    required this.onTransferComplete,
  });

  @override
  State<InventoryOperationsModal> createState() => _InventoryOperationsModalState();
}

class _InventoryOperationsModalState extends State<InventoryOperationsModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Formulario de Carga
  String _documentType = 'Nota de Entrega';
  final _docNumberController = TextEditingController(text: 'NE-4501');
  final _supplierController = TextEditingController(text: 'Alimentos Polar C.A.');
  final _loadQtyController = TextEditingController(text: '24');
  final _loadCostController = TextEditingController(text: '1.10');
  String _loadWarehouse = 'Almacén Principal';
  late String _selectedLoadProduct;

  // Formulario de Traslado
  String _originWarehouse = 'Almacén Principal';
  String _targetWarehouse = 'Depósito 2 (Secundario)';
  final _transferQtyController = TextEditingController(text: '10');
  final _transferNotesController = TextEditingController(text: 'Reabastecimiento de mostrador');
  late String _selectedTransferProduct;

  final List<String> _warehouses = ['Almacén Principal', 'Depósito 2 (Secundario)'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedLoadProduct = widget.products.isNotEmpty ? widget.products.first['name'] : 'Pepsi 2L';
    _selectedTransferProduct = widget.products.isNotEmpty ? widget.products.first['name'] : 'Pepsi 2L';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _docNumberController.dispose();
    _supplierController.dispose();
    _loadQtyController.dispose();
    _loadCostController.dispose();
    _transferQtyController.dispose();
    _transferNotesController.dispose();
    super.dispose();
  }

  void _submitLoad() {
    final qty = int.tryParse(_loadQtyController.text) ?? 0;
    if (qty <= 0) return;

    widget.onOperationComplete(
      type: _documentType,
      productName: _selectedLoadProduct,
      quantity: qty,
      warehouse: _loadWarehouse,
      documentNumber: _docNumberController.text.trim(),
      supplier: _supplierController.text.trim(),
    );

    Navigator.of(context).pop();
  }

  void _submitTransfer() {
    final qty = int.tryParse(_transferQtyController.text) ?? 0;
    if (qty <= 0) return;
    if (_originWarehouse == _targetWarehouse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El almacén origen y destino deben ser diferentes')),
      );
      return;
    }

    widget.onTransferComplete(
      productName: _selectedTransferProduct,
      quantity: qty,
      originWarehouse: _originWarehouse,
      targetWarehouse: _targetWarehouse,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de arrastre
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
          const SizedBox(height: 14),

          // Título y selector de pestañas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operaciones de Inventario',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202124),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF5F6368)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF5F6368),
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '📥 Cargar Inventario'),
                Tab(text: '🔄 Traslado entre Almacenes'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // PESTAÑA 1: Carga de Inventario
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo de Documento
                      Text('Tipo de Ingreso', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildDocTypeChip('Nota de Entrega'),
                          const SizedBox(width: 8),
                          _buildDocTypeChip('Factura Proveedor'),
                          const SizedBox(width: 8),
                          _buildDocTypeChip('Manual'),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Número y Proveedor
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _docNumberController,
                              decoration: InputDecoration(
                                labelText: 'N° Documento',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _supplierController,
                              decoration: InputDecoration(
                                labelText: 'Proveedor',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Almacén de Destino
                      Text('Almacén de Destino', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _loadWarehouse,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _loadWarehouse = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Producto a Cargar
                      Text('Producto', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLoadProduct,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: widget.products
                            .map((p) => DropdownMenuItem<String>(
                                  value: p['name'] as String,
                                  child: Text(p['name']),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLoadProduct = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Cantidad y Costo
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _loadQtyController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cantidad que ingresa',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _loadCostController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Costo unitario (\$)',
                                prefixText: '\$ ',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _submitLoad,
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text('Registrar Entrada de Inventario'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PESTAÑA 2: Traslado entre Almacenes
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Producto a Trasladar
                      Text('Producto a Trasladar', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTransferProduct,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: widget.products
                            .map((p) => DropdownMenuItem<String>(
                                  value: p['name'] as String,
                                  child: Text(p['name']),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTransferProduct = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Origen y Destino
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Almacén Origen', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  initialValue: _originWarehouse,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w, overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _originWarehouse = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 20),
                            child: Icon(Icons.arrow_forward, size: 20, color: Color(0xFF1A73E8)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Almacén Destino', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  initialValue: _targetWarehouse,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w, overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _targetWarehouse = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Cantidad
                      Text('Cantidad a transferir', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _transferQtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Unidades',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nota
                      Text('Nota de traslado', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _transferNotesController,
                        decoration: InputDecoration(
                          labelText: 'Motivo o referencia',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _submitTransfer,
                          icon: const Icon(Icons.sync_alt, size: 20),
                          label: const Text('Confirmar Traslado'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTypeChip(String type) {
    final isSelected = _documentType == type;
    return Expanded(
      child: ChoiceChip(
        label: Text(
          type == 'Factura Proveedor' ? 'Factura' : (type == 'Nota de Entrega' ? 'Nota Entr.' : 'Manual'),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        ),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _documentType = type);
        },
        selectedColor: const Color(0xFFD3E3FD),
      ),
    );
  }
}
