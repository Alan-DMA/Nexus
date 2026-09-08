import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/home/presentation/screens/dashboard_screen.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final double exchangeRate = 36.50;

  final List<Map<String, dynamic>> _todaySales = [
    {
      'receipt': 'VTA-000034',
      'time': '04:15 PM',
      'client': 'Cliente Contado',
      'items_count': 3,
      'items_summary': '2x Pepsi 2L, 1x Harina PAN',
      'total_usd': 4.20,
      'payment_method': 'Efectivo USD',
      'status': 'COMPLETADA',
    },
    {
      'receipt': 'VTA-000033',
      'time': '03:40 PM',
      'client': 'María Pérez',
      'items_count': 5,
      'items_summary': '1x Combo Desayuno, 2x Harina PAN',
      'total_usd': 6.90,
      'payment_method': 'Punto de Venta',
      'status': 'COMPLETADA',
    },
    {
      'receipt': 'VTA-000032',
      'time': '02:10 PM',
      'client': 'Juan Gómez',
      'items_count': 1,
      'items_summary': '1x Pepsi 2L',
      'total_usd': 1.50,
      'payment_method': 'Pago Móvil',
      'status': 'COMPLETADA',
    },
    {
      'receipt': 'VTA-000031',
      'time': '11:25 AM',
      'client': 'Cliente Contado',
      'items_count': 4,
      'items_summary': '4x Harina PAN',
      'total_usd': 4.80,
      'payment_method': 'Efectivo VES',
      'status': 'COMPLETADA',
    },
  ];

  String _formatAmount(double usdAmount, bool isUsd) {
    if (isUsd) {
      return '\$${usdAmount.toStringAsFixed(2)}';
    } else {
      final vesAmount = usdAmount * exchangeRate;
      return 'Bs. ${vesAmount.toStringAsFixed(2)}';
    }
  }

  void _showReceiptDetail(Map<String, dynamic> sale, bool isUsd) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comprobante ${sale['receipt']}',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sale['status'],
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Hora: ${sale['time']}', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            Text('Cliente: ${sale['client']}', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            Text('Método de Pago: ${sale['payment_method']}', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            const Divider(height: 24),
            Text('Detalle de Ítems:', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 6),
            Text(sale['items_summary'], style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total de Venta:', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                Text(
                  _formatAmount(sale['total_usd'] as double, isUsd),
                  style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryCian),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUsd = ref.watch(currencyIsUsdProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Historial de Operaciones Hoy',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _todaySales.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sale = _todaySales[index];
          return InkWell(
            onTap: () => _showReceiptDetail(sale, isUsd),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              sale['receipt'],
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${sale['time']}',
                              style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${sale['client']} (${sale['items_count']} ítems)',
                          style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(sale['total_usd'] as double, isUsd),
                        style: GoogleFonts.jetBrainsMono(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryCian),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        sale['payment_method'],
                        style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
