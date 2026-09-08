import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _invoiceNumController = TextEditingController();
  final _amountUsdController = TextEditingController();
  final _expenseDetailController = TextEditingController();
  String _selectedSupplier = 'Distribuidora Polar C.A.';
  final String _selectedExpenseCategory = 'Alquiler y Servicios';

  final List<Map<String, dynamic>> _purchaseHistory = [
    {
      'id': 'CMP-0042',
      'supplier': 'Distribuidora Polar C.A.',
      'date': 'Hoy 09:15 AM',
      'total_usd': 450.00,
      'status': 'Pagado',
      'items_count': 12,
    },
    {
      'id': 'CMP-0041',
      'supplier': 'Pepsico Venezuela',
      'date': 'Ayer 03:20 PM',
      'total_usd': 280.50,
      'status': 'Crédito (15d)',
      'items_count': 8,
    },
  ];

  final List<Map<String, dynamic>> _expenseHistory = [
    {
      'id': 'GST-0102',
      'category': 'Alquiler y Servicios',
      'detail': 'Pago de Electricidad Corpoelec',
      'date': 'Hoy 11:00 AM',
      'total_usd': 35.00,
    },
    {
      'id': 'GST-0101',
      'category': 'Mantenimiento',
      'detail': 'Reparación de Santamaría local',
      'date': '24/08/2026',
      'total_usd': 60.00,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invoiceNumController.dispose();
    _amountUsdController.dispose();
    _expenseDetailController.dispose();
    super.dispose();
  }

  void _openAddPurchaseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registrar Nueva Compra',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSupplier,
                decoration: const InputDecoration(labelText: 'Proveedor'),
                dropdownColor: AppTheme.darkSurface,
                items: const [
                  DropdownMenuItem(
                    value: 'Distribuidora Polar C.A.',
                    child: Text(
                      'Distribuidora Polar C.A.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Pepsico Venezuela',
                    child: Text(
                      'Pepsico Venezuela',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Nestlé Venezuela',
                    child: Text(
                      'Nestlé Venezuela',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSupplier = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _invoiceNumController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Número de Factura / Control',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountUsdController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Monto Total Compra (USD)',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final amount =
                        double.tryParse(_amountUsdController.text) ?? 0.0;
                    if (amount > 0) {
                      setState(() {
                        _purchaseHistory.insert(0, {
                          'id': 'CMP-00${_purchaseHistory.length + 43}',
                          'supplier': _selectedSupplier,
                          'date': 'Justo ahora',
                          'total_usd': amount,
                          'status': 'Pagado',
                          'items_count': 5,
                        });
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compra registrada exitosamente'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar Compra',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compras y Gastos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.cyanAccent,
          labelColor: AppTheme.cyanAccent,
          unselectedLabelColor: AppTheme.darkTextSecondary,
          tabs: const [
            Tab(text: 'Compras a Proveedores'),
            Tab(text: 'Gastos Operativos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Compras
          ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: _purchaseHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _purchaseHistory[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['supplier'],
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item['id']} • ${item['items_count']} productos • ${item['date']}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${(item['total_usd'] as num).toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['status'],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab 2: Gastos Operativos
          ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: _expenseHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _expenseHistory[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.warningOrange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['detail'],
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item['category']} • ${item['date']}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-\$${(item['total_usd'] as num).toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva Compra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _openAddPurchaseModal,
      ),
    );
  }
}
