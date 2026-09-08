import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/home/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:frontend/features/sales/presentation/checkout_screen.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:frontend/features/home/presentation/widgets/app_drawer.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'Hoy';
  int _selectedIndex = 2; // Reportes tab activo
  final double exchangeRate = 36.50;

  String _formatAmount(double usdAmount, bool isUsd) {
    if (isUsd) {
      return '\$${usdAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } else {
      final vesAmount = usdAmount * exchangeRate;
      return 'Bs. ${vesAmount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUsd = ref.watch(currencyIsUsdProvider);
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

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
              canPop ? Icons.arrow_back_rounded : Icons.menu_rounded,
              color: canPop ? theme.colorScheme.onSurface : theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              if (canPop) {
                Navigator.of(ctx).pop();
              } else {
                Scaffold.of(ctx).openDrawer();
              }
            },
          ),
        ),
        title: Text(
          'Analítica',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? theme.colorScheme.onBackground : const Color(0xFF1E40AF),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          // Selector de período tipo chip (Píldora "Hoy ▾")
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: PopupMenuButton<String>(
              initialValue: _selectedPeriod,
              onSelected: (val) => setState(() => _selectedPeriod = val),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.colorScheme.surface,
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Hoy', child: Text('Hoy')),
                const PopupMenuItem(value: 'Esta semana', child: Text('Esta semana')),
                const PopupMenuItem(value: 'Este mes', child: Text('Este mes')),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? theme.colorScheme.outline : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Botón Descargar / Exportar Reporte
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Generando reporte PDF/Excel...', style: GoogleFonts.inter()),
                  backgroundColor: AppTheme.secondaryRoyalBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjetas KPI Métricas de Resumen (Stack vertical de 3 tarjetas idénticas al boceto)
            _buildAnalyticaKpiCard(
              context: context,
              title: 'Ventas',
              value: _formatAmount(4820.00, isUsd),
              badgeText: '↑ 18% mes',
              badgeColor: const Color(0xFF16A34A),
              icon: Icons.trending_up_rounded,
              iconBgColor: isDark
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 12),

            _buildAnalyticaKpiCard(
              context: context,
              title: 'Margen',
              value: _formatAmount(1240.00, isUsd),
              badgeText: '25.7% del total',
              badgeColor: theme.colorScheme.onSurfaceVariant,
              icon: Icons.account_balance_wallet_outlined,
              iconBgColor: isDark
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 12),

            _buildAnalyticaKpiCard(
              context: context,
              title: 'Transac.',
              value: '128',
              badgeText: '↑ 9% mes',
              badgeColor: const Color(0xFF16A34A),
              icon: Icons.receipt_long_outlined,
              iconBgColor: isDark
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 20),

            // 2. Gráfico "Ventas por Día"
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ventas por Día',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Barras verticales de ventas por día (L, M, M, J, V, S, D)
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarColumn(context, label: 'L', heightFactor: 0.35, isSelected: false),
                        _buildBarColumn(context, label: 'M', heightFactor: 0.50, isSelected: false),
                        _buildBarColumn(context, label: 'M', heightFactor: 0.40, isSelected: false),
                        _buildBarColumn(context, label: 'J', heightFactor: 0.65, isSelected: false),
                        _buildBarColumn(context, label: 'V', heightFactor: 0.90, isSelected: true),
                        _buildBarColumn(context, label: 'S', heightFactor: 0.75, isSelected: false),
                        _buildBarColumn(context, label: 'D', heightFactor: 0.30, isSelected: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Sección "Top 5 Productos"
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top 5 Productos',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const InventoryScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Ver todos',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ítem 1: Pepsi 2L
                  _buildTopProductItem(
                    context: context,
                    name: 'Pepsi 2L',
                    subtitle: '560 uds vendidas',
                    amount: _formatAmount(840.00, isUsd),
                    iconData: Icons.local_drink_rounded,
                    imagePath: 'assets/images/pepsi.png',
                  ),
                  Divider(height: 20, color: theme.colorScheme.outline.withOpacity(0.5)),

                  // Ítem 2: Harina PAN
                  _buildTopProductItem(
                    context: context,
                    name: 'Harina PAN',
                    subtitle: '600 uds vendidas',
                    amount: _formatAmount(720.00, isUsd),
                    iconData: Icons.rice_bowl_rounded,
                    imagePath: 'assets/images/harina_pan.png',
                  ),
                  Divider(height: 20, color: theme.colorScheme.outline.withOpacity(0.5)),

                  // Ítem 3: Azúcar 1kg
                  _buildTopProductItem(
                    context: context,
                    name: 'Azúcar 1kg',
                    subtitle: '600 uds vendidas',
                    amount: _formatAmount(480.00, isUsd),
                    iconData: Icons.blur_on_rounded,
                    imagePath: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Sección "Alertas Predictivas" (Fiel al boceto)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alertas Predictivas',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Alerta 1: Stock Crítico (Rosa/Rojo suave)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF450A0A)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF991B1B)
                            : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFDC2626),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock Crítico',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pepsi 2L — se agota en ~2 días basado en tendencia actual.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? const Color(0xFFFCA5A5)
                                      : const Color(0xFF7F1D1D),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Alerta 2: Baja Rotación (Crema/Amarillo suave)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF451A03)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF92400E)
                            : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFD97706),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Baja Rotación',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Galletas Oreo — 60 días sin ventas registradas.',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFF78350F),
                                  height: 1.3,
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
            setState(() => _selectedIndex = index);
            if (index == 0) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              );
            } else if (index == 3) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }
          },
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: theme.colorScheme.secondary.withOpacity(0.3),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined, color: theme.colorScheme.onSurfaceVariant),
              selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppTheme.primaryCian),
              label: 'Ventas',
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

  Widget _buildAnalyticaKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(
    BuildContext context, {
    required String label,
    required double heightFactor,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final barColor = isSelected
        ? const Color(0xFF2563EB)
        : theme.colorScheme.primary.withOpacity(0.3);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 110 * heightFactor,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductItem({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String amount,
    required IconData iconData,
    String? imagePath,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Icon(
            iconData,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
