import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';

// Proveedor simple de estado para la moneda de visualización (Bimoneda Toggle)
// true = USD, false = VES
final currencyIsUsdProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUsd = ref.watch(currencyIsUsdProvider);
    const double exchangeRate = 36.50; // Tasa del día simulación

    // Utilidades para conversión de moneda
    String formatCurrency(double amountUsd) {
      if (isUsd) {
        return '\$${amountUsd.toStringAsFixed(2)} USD';
      } else {
        final amountVes = amountUsd * exchangeRate;
        return 'Bs. ${amountVes.toStringAsFixed(2)} VES';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGlow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.blur_on, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            const Text('NEXUS'),
          ],
        ),
        actions: [
          // Toggle Bimoneda (SR-03 Alternador de Vista Bimoneda)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref.read(currencyIsUsdProvider.notifier).state = true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUsd ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('USD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(currencyIsUsdProvider.notifier).state = false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !isUsd ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('VES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo de Bienvenida
            const Text('¡Hola, Alan!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Bodega El Sol (Tenant #001) • Plan Comercio', style: TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(height: 24),

            // Tarjetas Financieras (Glassmorphic look)
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        title: 'Ventas de Hoy',
                        value: formatCurrency(350.50),
                        subtext: isUsd ? 'Tasa: 1 USD = Bs. $exchangeRate' : 'Tasa oficial congelada',
                        icon: Icons.trending_up,
                        accentColor: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        title: 'Comisiones Vendedor',
                        value: formatCurrency(35.05),
                        subtext: '10% de ganancia neta',
                        icon: Icons.percent,
                        accentColor: AppTheme.secondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Sección de Acciones Rápidas (SR-02 Action Cards)
            const Text('Acciones Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildActionCard(
                  title: 'Nueva Venta',
                  description: 'Checkout por cámara',
                  icon: Icons.qr_code_scanner,
                  color: AppTheme.primary,
                  onTap: () {
                    // Acción venta rápida
                  },
                ),
                _buildActionCard(
                  title: 'Inventario',
                  description: 'Ver y ajustar stock',
                  icon: Icons.inventory_2,
                  color: AppTheme.secondary,
                  onTap: () {
                    // Acción inventario
                  },
                ),
                _buildActionCard(
                  title: 'Registro al Vuelo',
                  description: 'Producto rápido',
                  icon: Icons.add_circle_outline,
                  color: AppTheme.accent,
                  onTap: () {
                    // Creación rápida sin IA
                  },
                ),
                _buildActionCard(
                  title: 'Cierre de Caja',
                  description: 'Arqueo multimoneda',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.success,
                  onTap: () {
                    // Arqueo
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Alertas y Notificaciones en tiempo real
            const Text('Alertas Críticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            _buildAlertCard(
              title: 'Stock Crítico de Harina PAN',
              description: 'Solo quedan 2 unidades en Almacén Principal. Umbral mínimo: 5.',
              icon: Icons.warning_amber_rounded,
              color: AppTheme.warning,
            ),
            const SizedBox(height: 10),
            _buildAlertCard(
              title: 'Pago Móvil Pendiente por Validar',
              description: 'El administrador tiene 1 pago de suscripción pendiente de aprobación manual.',
              icon: Icons.payment,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtext, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
