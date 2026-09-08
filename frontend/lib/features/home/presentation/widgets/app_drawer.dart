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
import 'package:frontend/features/reports/presentation/screens/reports_screen.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  String _getUserName() {
    try {
      final authBox = Hive.box('auth');
      final name = authBox.get('user_name') as String?;
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}
    return 'Alan David';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userName = _getUserName();

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: Column(
        children: [
          // Header de usuario
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.tertiary ?? AppTheme.accentPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName[0].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            accountName: Text(
              userName,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              'Administrador · Bodega El Sol',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
            ),
          ),

          // Enlaces de Navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Inicio / Dashboard',
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_cart_rounded,
                  title: 'Nueva Venta (Checkout)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: 'Inventario & Productos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.point_of_sale_rounded,
                  title: 'Arqueo de Caja',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CashCountWizardScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_shipping_rounded,
                  title: 'Compras & Gastos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.business_rounded,
                  title: 'Directorio de Proveedores',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat_bubble_rounded,
                  title: 'Catálogo Web & WhatsApp',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WhatsAppCatalogScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: 'Usuarios & Permisos (RBAC)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen()));
                  },
                ),
                const Divider(height: 16),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Reportes & Métricas',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Configuración & Tema',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
          ),

          // Botón Cerrar Sesión Footer
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text(
              'Cerrar Sesión',
              style: GoogleFonts.inter(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}
