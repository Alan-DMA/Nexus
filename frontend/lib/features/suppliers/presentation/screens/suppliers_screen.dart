import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _suppliers = [
    {
      'id': '1',
      'name': 'Empresas Polar C.A.',
      'rif': 'J-00004455-0',
      'phone': '+58 414-555-0192',
      'contact_person': 'Carlos Mendoza',
      'balance_usd': 280.00,
      'is_credit': true,
    },
    {
      'id': '2',
      'name': 'Pepsico de Venezuela S.C.',
      'rif': 'J-30129482-1',
      'phone': '+58 412-888-4321',
      'contact_person': 'Ana Gutiérrez',
      'balance_usd': 0.00,
      'is_credit': false,
    },
    {
      'id': '3',
      'name': 'Distribuidora Alimentos Central',
      'rif': 'J-40918234-9',
      'phone': '+58 424-333-1122',
      'contact_person': 'José Luis Rodríguez',
      'balance_usd': 150.50,
      'is_credit': true,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddSupplierModal() {
    final nameCtrl = TextEditingController();
    final rifCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.darkBorder),
        ),
        title: Text(
          'Registrar Proveedor',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Razón Social / Nombre',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rifCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'RIF / Documento Fiscal',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Teléfono de Contacto',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.darkTextSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _suppliers.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameCtrl.text.trim(),
                    'rif': rifCtrl.text.trim().isEmpty
                        ? 'J-00000000-0'
                        : rifCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'contact_person': 'Contacto Directo',
                    'balance_usd': 0.00,
                    'is_credit': false,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
          'Directorio de Proveedores',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppTheme.cyanAccent,
            ),
            onPressed: _openAddSupplierModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o RIF...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _suppliers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = _suppliers[index];
                final hasDebt = (s['balance_usd'] as num) > 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasDebt
                          ? AppTheme.warningOrange.withValues(alpha: 0.5)
                          : AppTheme.darkBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryRoyalBlue.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['name'],
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'RIF: ${s['rif']} • ${s['phone']}',
                              style: GoogleFonts.jetBrainsMono(
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
                            hasDebt
                                ? 'Deuda: \$${(s['balance_usd'] as num).toStringAsFixed(2)}'
                                : 'Al día',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: hasDebt
                                  ? AppTheme.warningOrange
                                  : AppTheme.successGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.darkTextSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
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
