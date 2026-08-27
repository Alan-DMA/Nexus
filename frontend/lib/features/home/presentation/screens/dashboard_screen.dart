import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/sales/presentation/checkout_screen.dart';
import 'package:frontend/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:frontend/features/cash/presentation/screens/cash_count_wizard_screen.dart';
import 'package:frontend/features/purchases/presentation/screens/purchases_screen.dart';
import 'package:frontend/features/suppliers/presentation/screens/suppliers_screen.dart';
import 'package:frontend/features/catalog/presentation/screens/whatsapp_catalog_screen.dart';
import 'package:frontend/features/users/presentation/screens/users_screen.dart';
import 'package:frontend/features/home/presentation/widgets/app_drawer.dart';
import 'package:frontend/features/home/presentation/widgets/notifications_modal.dart';
import 'package:frontend/features/reports/presentation/screens/reports_screen.dart';
import 'package:frontend/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:frontend/features/inventory/presentation/screens/product_detail_screen.dart';

// Proveedor simple de estado para la moneda de visualización (Bimoneda Toggle)
// true = USD, false = VES
final currencyIsUsdProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  final double exchangeRate = 36.50;

  String _formatAmount(double usdAmount, bool isUsd) {
    if (isUsd) {
      return '\$${usdAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } else {
      final vesAmount = usdAmount * exchangeRate;
      return 'Bs. ${vesAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  String _getUserDisplayName() {
    try {
      final authBox = Hive.box('auth');
      final rawName = authBox.get('user_name') as String?;
      if (rawName != null && rawName.isNotEmpty) {
        return rawName[0].toUpperCase() + rawName.substring(1);
      }
    } catch (_) {}
    return 'Alan David';
  }

  @override
  Widget build(BuildContext context) {
    final isUsd = ref.watch(currencyIsUsdProvider);
    final userName = _getUserDisplayName();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: theme.colorScheme.primary,
              size: 26,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Text(
          'Nexus',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Selector de moneda en píldora
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PopupMenuButton<bool>(
              initialValue: isUsd,
              onSelected: (val) {
                ref.read(currencyIsUsdProvider.notifier).state = val;
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.colorScheme.surface,
              offset: const Offset(0, 42),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: true,
                  child: Text('USD - Dólares', style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
                PopupMenuItem(
                  value: false,
                  child: Text('VES - Bolívares', style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUsd ? 'USD' : 'VES',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Campana de notificaciones con badge
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: theme.colorScheme.onBackground,
                    size: 26,
                  ),
                  onPressed: () => NotificationsModal.show(context),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Saludo y contexto de tienda
            Row(
              children: [
                Text(
                  'Buenos días, $userName',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onBackground,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🌞', style: TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Martes 02 Jul · Almacén Principal',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Cuadrícula de Métricas 2x2
            Row(
              children: [
                // Ventas Hoy (Tarjeta Destacada con Degradado - Navega a Reportes)
                Expanded(
                  child: _buildGradientMetricCard(
                    context: context,
                    title: 'VENTAS HOY',
                    value: _formatAmount(1240.00, isUsd),
                    subtext: '↗ 12% vs ayer',
                    icon: Icons.payments_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                // Margen Hoy
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'MARGEN HOY',
                    value: _formatAmount(380.00, isUsd),
                    subtext: '↑ 5% vs ayer',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppTheme.primaryCian,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Transacciones (Navega a Historial de Operaciones)
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    title: 'TRANSACCIONES',
                    value: '34',
                    subtext: 'operaciones hoy',
                    icon: Icons.receipt_long_rounded,
                    iconColor: theme.colorScheme.onSurfaceVariant,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                // Stock Bajo (Con borde de alerta naranja - Navega a Inventario filtrado)
                Expanded(
                  child: _buildStockAlertCard(context),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 3. Sección "Acciones rápidas" (Carrusel con tarjetas 100% simétricas)
            Text(
              'Acciones rápidas',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickActionCard(
                    context: context,
                    title: 'Nueva Venta',
                    icon: Icons.shopping_cart_rounded,
                    isPrimary: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Arqueo de Caja',
                    icon: Icons.point_of_sale_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CashCountWizardScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Inventario',
                    icon: Icons.inventory_2_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InventoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Compras y Gastos',
                    icon: Icons.local_shipping_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PurchasesScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Proveedores',
                    icon: Icons.business_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SuppliersScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Catálogo Web',
                    icon: Icons.chat_bubble_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WhatsAppCatalogScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionCard(
                    context: context,
                    title: 'Usuarios',
                    icon: Icons.people_alt_rounded,
                    isPrimary: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 4. Sección "Alertas del Sistema" (Interactivas)
            Text(
              'Alertas del Sistema',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 14),
            // Alerta 1: Pepsi 2L (Abre Ficha de Producto)
            _buildAlertListItem(
              context: context,
              title: 'Pepsi 2L',
              subtitle: 'Stock: 3 uds (mín: 10)',
              icon: Icons.inventory_2_rounded,
              iconColor: AppTheme.warningOrange,
              iconBgColor: AppTheme.warningOrange.withOpacity(0.15),
              cardBgColor: theme.colorScheme.surface,
              subtitleColor: AppTheme.warningOrange,
              borderColor: AppTheme.warningOrange.withOpacity(0.4),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductDetailScreen(
                      product: {
                        'id': '1',
                        'name': 'Pepsi 2L',
                        'sku': '7591024100016',
                        'price_usd': 1.50,
                        'cost_usd': 1.10,
                        'stock': 3,
                        'category': 'Bebidas',
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Alerta 2: Azúcar 1kg (Abre Ficha de Producto)
            _buildAlertListItem(
              context: context,
              title: 'Azúcar 1kg',
              subtitle: 'Stock crítico: 1 ud',
              icon: Icons.error_outline_rounded,
              iconColor: AppTheme.errorRed,
              iconBgColor: AppTheme.errorRed.withOpacity(0.15),
              cardBgColor: theme.colorScheme.surface,
              subtitleColor: AppTheme.errorRed,
              borderColor: AppTheme.errorRed.withOpacity(0.4),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductDetailScreen(
                      product: {
                        'id': '4',
                        'name': 'Azúcar 1kg',
                        'sku': '7591024100099',
                        'price_usd': 1.10,
                        'cost_usd': 0.85,
                        'stock': 1,
                        'category': 'Alimentos',
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Alerta 3: OC-00012 (Abre Compras)
            _buildAlertListItem(
              context: context,
              title: 'OC-00012',
              subtitle: 'Orden pendiente de recepción',
              icon: Icons.access_time_rounded,
              iconColor: theme.colorScheme.onSurfaceVariant,
              iconBgColor: theme.colorScheme.surfaceContainerHighest,
              cardBgColor: theme.colorScheme.surface,
              subtitleColor: theme.colorScheme.onSurfaceVariant,
              borderColor: theme.colorScheme.outline,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PurchasesScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Enlace "Ver todo ->"
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => NotificationsModal.show(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver todas las alertas',
                        style: GoogleFonts.inter(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const InventoryScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            } else if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            }
          },
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: theme.colorScheme.secondary.withOpacity(0.3),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryCian),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryCian),
              label: 'Inventario',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: AppTheme.primaryCian),
              label: 'Reportes',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryCian),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildGradientMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary ?? const Color(0xFF8B5CF6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, size: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtext,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, size: 20, color: iconColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtext,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertCard(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InventoryScreen(initialFilter: '⚠️ Stock Bajo'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warningOrange.withOpacity(0.6), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STOCK BAJO',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warningOrange,
                    letterSpacing: 0.5,
                  ),
                ),
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: AppTheme.warningOrange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '8 prod',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.warningOrange,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ver alertas',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 112,
        height: 118,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrimary
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.primaryCian,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertListItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardBgColor,
    required Color subtitleColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
