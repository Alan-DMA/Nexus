import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/theme_provider.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _rateController = TextEditingController(text: '36.50');

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

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
          'Configuración',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. Sección Apariencia y Tema Visual
          Text(
            'Apariencia y Tema',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
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
                    Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : themeMode == ThemeMode.light
                              ? Icons.light_mode_rounded
                              : Icons.brightness_auto_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Visual de Interfaz',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Selecciona el tema que prefieras para la app',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOptionCard(
                        context: context,
                        title: 'Oscuro 🌙',
                        icon: Icons.dark_mode_outlined,
                        selectedIcon: Icons.dark_mode_rounded,
                        mode: ThemeMode.dark,
                        currentMode: themeMode,
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOptionCard(
                        context: context,
                        title: 'Claro ☀️',
                        icon: Icons.light_mode_outlined,
                        selectedIcon: Icons.light_mode_rounded,
                        mode: ThemeMode.light,
                        currentMode: themeMode,
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildThemeOptionCard(
                        context: context,
                        title: 'Sistema 💻',
                        icon: Icons.brightness_auto_outlined,
                        selectedIcon: Icons.brightness_auto_rounded,
                        mode: ThemeMode.system,
                        currentMode: themeMode,
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Sección Bimoneda y Moneda Base
          Text(
            'Gestión Bimoneda',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.currency_exchange_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tasa Oficial BCV (VES / USD)',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Datos de Comercio
          Text(
            'Información del Comercio',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.store_rounded, color: theme.colorScheme.primary),
                  title: Text('Nombre de la Tienda', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('Bodega El Sol (Almacén Principal)', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                  trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                ),
                Divider(height: 1, color: theme.colorScheme.outline),
                ListTile(
                  leading: Icon(Icons.badge_rounded, color: theme.colorScheme.primary),
                  title: Text('RIF / Registro Fiscal', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text('J-12345678-0', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. Botón Cerrar Sesión
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error.withOpacity(0.12),
              foregroundColor: theme.colorScheme.error,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
              ),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required IconData selectedIcon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentMode == mode;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
