import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/sales/presentation/checkout_screen.dart';

// Proveedor simple de estado para la moneda de visualización (Bimoneda Toggle)
// true = USD, false = VES
final currencyIsUsdProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUsd = ref.watch(currencyIsUsdProvider);
    const double exchangeRate = 36.50; // Tasa del día simulación
    final theme = Theme.of(context);

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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.storefront, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            const Text('NEXUS'),
          ],
        ),
        actions: [
          // Toggle Bimoneda
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => ref.read(currencyIsUsdProvider.notifier).state = true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUsd ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('USD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUsd ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(currencyIsUsdProvider.notifier).state = false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: !isUsd ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('VES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !isUsd ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface)),
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
            Text('¡Hola, Alan!', style: theme.textTheme.headlineSmall),
            Text('Bodega El Sol (Tenant #001) • Plan Comercio', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Tarjetas Financieras
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        context: context,
                        title: 'Ventas de Hoy',
                        value: formatCurrency(350.50),
                        subtext: isUsd ? 'Tasa: 1 USD = Bs. $exchangeRate' : 'Tasa oficial congelada',
                        icon: Icons.trending_up,
                        accentColor: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        context: context,
                        title: 'Comisiones Vendedor',
                        value: formatCurrency(35.05),
                        subtext: '10% de ganancia neta',
                        icon: Icons.percent,
                        accentColor: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Sección de Acciones Rápidas
            Text('Acciones Rápidas', style: theme.textTheme.titleLarge),
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
                  context: context,
                  title: 'Nueva Venta',
                  description: 'Checkout por cámara',
                  icon: Icons.qr_code_scanner,
                  color: theme.colorScheme.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  context: context,
                  title: 'Inventario',
                  description: 'Ver y ajustar stock',
                  icon: Icons.inventory_2,
                  color: theme.colorScheme.secondary,
                  onTap: () {},
                ),
                _buildActionCard(
                  context: context,
                  title: 'Registro al Vuelo',
                  description: 'Producto rápido',
                  icon: Icons.add_circle_outline,
                  color: theme.colorScheme.tertiary,
                  onTap: () {},
                ),
                _buildActionCard(
                  context: context,
                  title: 'Cierre de Caja',
                  description: 'Arqueo multimoneda',
                  icon: Icons.account_balance_wallet,
                  color: theme.colorScheme.secondary,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Alertas y Notificaciones
            Text('Alertas Críticas', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildAlertCard(
              context: context,
              title: 'Stock Crítico de Harina PAN',
              description: 'Solo quedan 2 unidades en Almacén Principal. Umbral mínimo: 5.',
              icon: Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 10),
            _buildAlertCard(
              context: context,
              title: 'Pago Móvil Pendiente por Validar',
              description: 'El administrador tiene 1 pago de suscripción pendiente de aprobación manual.',
              icon: Icons.payment,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTheme.numericLg(context)),
            const SizedBox(height: 4),
            Text(subtext, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
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
                Text(title, style: theme.textTheme.titleSmall?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
