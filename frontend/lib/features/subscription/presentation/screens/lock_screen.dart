import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class LockScreen extends StatelessWidget {
  final bool
  isHardLock; // true: Hard lock (bloqueo total), false: Soft lock (aviso)

  const LockScreen({super.key, this.isHardLock = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isHardLock
                      ? AppTheme.errorRed.withValues(alpha: 0.15)
                      : AppTheme.warningOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHardLock
                        ? AppTheme.errorRed
                        : AppTheme.warningOrange,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isHardLock ? Icons.lock_rounded : Icons.warning_rounded,
                  size: 40,
                  color: isHardLock
                      ? AppTheme.errorRed
                      : AppTheme.warningOrange,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isHardLock ? 'Acceso Suspendido' : 'Suscripción por Vencer',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isHardLock
                    ? 'Tu suscripción a Nexus ha vencido. Por favor renueva tu plan para reactivar la facturación y el inventario.'
                    : 'Te quedan 2 días de gracia en tu plan Nexus. Renueva ahora para evitar interrupciones en tu comercio.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.darkTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Card Métodos de Pago
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'Medios de Pago Disponibles',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPaymentBadge('Pago Móvil'),
                        _buildPaymentBadge('Zelle USD'),
                        _buildPaymentBadge('Binance Pay'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Redirigiendo a soporte para reporte de pago...',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Reportar Pago de Suscripción',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isHardLock) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Continuar al Sistema (Modo Gracia)',
                    style: TextStyle(color: AppTheme.cyanAccent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
