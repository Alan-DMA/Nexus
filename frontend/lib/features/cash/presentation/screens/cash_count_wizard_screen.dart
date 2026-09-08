import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class CashCountWizardScreen extends StatefulWidget {
  const CashCountWizardScreen({super.key});

  @override
  State<CashCountWizardScreen> createState() => _CashCountWizardScreenState();
}

class _CashCountWizardScreenState extends State<CashCountWizardScreen> {
  int _currentStep = 1; // 1: USD, 2: VES & Digital, 3: Resumen

  // USD Denominations
  final Map<int, int> _usdCounts = {100: 0, 50: 0, 20: 0, 10: 0, 5: 0, 1: 0};

  // VES Denominations
  final Map<int, int> _vesCounts = {
    500: 0,
    200: 0,
    100: 0,
    50: 0,
    20: 0,
    10: 0,
  };

  final TextEditingController _posVesController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _pagoMovilVesController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _notesController = TextEditingController();

  final double _exchangeRate = 36.50;
  final double _expectedUsdInDrawer = 350.00;
  final double _expectedVesInDrawer = 4200.00;

  double get _totalUsdCounted {
    double total = 0;
    _usdCounts.forEach((denom, count) {
      total += denom * count;
    });
    return total;
  }

  double get _totalVesCounted {
    double total = 0;
    _vesCounts.forEach((denom, count) {
      total += denom * count;
    });
    return total;
  }

  double get _posVes => double.tryParse(_posVesController.text) ?? 0.0;
  double get _pagoMovilVes =>
      double.tryParse(_pagoMovilVesController.text) ?? 0.0;

  double get _grandTotalUsdEquivalent {
    return _totalUsdCounted +
        ((_totalVesCounted + _posVes + _pagoMovilVes) / _exchangeRate);
  }

  double get _usdDifference => _totalUsdCounted - _expectedUsdInDrawer;

  @override
  void dispose() {
    _posVesController.dispose();
    _pagoMovilVesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _finishClose() {
    final isExact = _usdDifference.abs() < 0.01;
    final isSurplus = _usdDifference > 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isExact
                ? AppTheme.successGreen
                : isSurplus
                ? AppTheme.primaryBlue
                : AppTheme.errorRed,
            width: 1.5,
          ),
        ),
        title: Column(
          children: [
            Icon(
              isExact
                  ? Icons.check_circle_rounded
                  : isSurplus
                  ? Icons.arrow_circle_up_rounded
                  : Icons.warning_amber_rounded,
              size: 54,
              color: isExact
                  ? AppTheme.successGreen
                  : isSurplus
                  ? AppTheme.primaryBlue
                  : AppTheme.errorRed,
            ),
            const SizedBox(height: 12),
            Text(
              isExact
                  ? '¡Cierre de Caja Exitoso!'
                  : isSurplus
                  ? 'Cierre con Sobrante'
                  : 'Cierre con Descuadre',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExact
                  ? 'El arqueo físico coincide perfectamente con el balance del sistema Nexus.'
                  : isSurplus
                  ? 'Se detectó un sobrante de \$${_usdDifference.toStringAsFixed(2)} en efectivo.'
                  : 'Existe una diferencia faltante de \$${_usdDifference.abs().toStringAsFixed(2)}.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Arqueado:',
                    style: GoogleFonts.inter(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '\$${_grandTotalUsdEquivalent.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Cierra diálogo
              Navigator.pop(context); // Regresa a Dashboard
            },
            child: const Text(
              'Aceptar y Finalizar Turno',
              style: TextStyle(color: Colors.white),
            ),
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
          'Cierre de Caja - Arqueo',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Wizard Stepper Indicator Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.darkSurface,
            child: Row(
              children: [
                _buildStepBadge(1, 'USD', _currentStep >= 1),
                _buildStepDivider(_currentStep >= 2),
                _buildStepBadge(2, 'VES / Digital', _currentStep >= 2),
                _buildStepDivider(_currentStep >= 3),
                _buildStepBadge(3, 'Resumen', _currentStep >= 3),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: _currentStep == 1
                  ? _buildStepUsd()
                  : _currentStep == 2
                  ? _buildStepVes()
                  : _buildStepSummary(),
            ),
          ),

          // Bottom Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              border: Border(top: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: Row(
              children: [
                if (_currentStep > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppTheme.darkBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text(
                        'Anterior',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.secondaryRoyalBlue,
                          AppTheme.primaryBlue,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_currentStep < 3) {
                          setState(() => _currentStep++);
                        } else {
                          _finishClose();
                        }
                      },
                      child: Text(
                        _currentStep == 3
                            ? 'Finalizar Arqueo'
                            : 'Siguiente Paso →',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBadge(int step, String title, bool isActive) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.cyanAccent : AppTheme.darkSurfaceVariant,
          ),
          child: Center(
            child: Text(
              '$step',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black : AppTheme.darkTextSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : AppTheme.darkTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppTheme.cyanAccent : AppTheme.darkBorder,
      ),
    );
  }

  // Step 1: Billetes USD
  Widget _buildStepUsd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conteo de Efectivo USD',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ingresa la cantidad de billetes por denominación',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.darkTextSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.cyanAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Subtotal: \$${_totalUsdCounted.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.cyanAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        ..._usdCounts.keys.map((denom) {
          final count = _usdCounts[denom]!;
          final totalDenom = denom * count;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF059669)),
                  ),
                  child: Center(
                    child: Text(
                      '\$$denom',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billetes de \$$denom USD',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Subtotal: \$${totalDenom.toStringAsFixed(2)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Counter buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppTheme.darkTextSecondary,
                      ),
                      onPressed: count > 0
                          ? () => setState(() => _usdCounts[denom] = count - 1)
                          : null,
                    ),
                    Container(
                      width: 42,
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppTheme.cyanAccent,
                      ),
                      onPressed: () =>
                          setState(() => _usdCounts[denom] = count + 1),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Step 2: Efectivo VES & Digital
  Widget _buildStepVes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conteo Bolívares (VES)',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Billetes en efectivo y reportes de puntos de venta',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.darkTextSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Subtotal: Bs. ${(_totalVesCounted + _posVes + _pagoMovilVes).toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Efectivo en Bs.',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        ..._vesCounts.keys.map((denom) {
          final count = _vesCounts[denom]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                Text(
                  'Bs. $denom',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    color: AppTheme.darkTextSecondary,
                    size: 20,
                  ),
                  onPressed: count > 0
                      ? () => setState(() => _vesCounts[denom] = count - 1)
                      : null,
                ),
                Text(
                  '$count',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppTheme.cyanAccent,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _vesCounts[denom] = count + 1),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),
        Text(
          'Puntos y Ventas Digitales (Bs.)',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _posVesController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Punto de Venta / Biopago (Bs.)',
            prefixIcon: Icon(Icons.credit_card_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pagoMovilVesController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Pago Móvil / Transferencias (Bs.)',
            prefixIcon: Icon(Icons.phone_android_rounded),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // Step 3: Resumen Final y Discrepancias
  Widget _buildStepSummary() {
    final diff = _usdDifference;
    final isExact = diff.abs() < 0.01;
    final isSurplus = diff > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Arqueo y Balance',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Compara los totales físicos contados con los registros del sistema',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Discrepancy Card Indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isExact
                ? AppTheme.successGreen.withValues(alpha: 0.15)
                : isSurplus
                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                : AppTheme.errorRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExact
                  ? AppTheme.successGreen.withValues(alpha: 0.6)
                  : isSurplus
                  ? AppTheme.primaryBlue.withValues(alpha: 0.6)
                  : AppTheme.errorRed.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isExact
                    ? Icons.verified_rounded
                    : isSurplus
                    ? Icons.trending_up_rounded
                    : Icons.warning_rounded,
                size: 32,
                color: isExact
                    ? AppTheme.successGreen
                    : isSurplus
                    ? AppTheme.primaryBlue
                    : AppTheme.errorRed,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isExact
                          ? 'CUADRE PERFECTO'
                          : isSurplus
                          ? 'SOBRANTE EN EFECTIVO'
                          : 'DESCUADRE FALTANTE',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isExact
                            ? AppTheme.successGreen
                            : isSurplus
                            ? AppTheme.primaryBlue
                            : AppTheme.errorRed,
                      ),
                    ),
                    Text(
                      isExact
                          ? 'No hay ninguna diferencia reportada'
                          : 'Diferencia de \$${diff.abs().toStringAsFixed(2)} respecto al sistema',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Comparativa Tabla
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                'Efectivo USD Contado:',
                '\$${_totalUsdCounted.toStringAsFixed(2)}',
              ),
              const Divider(color: AppTheme.darkBorder, height: 16),
              _buildSummaryRow(
                'Efectivo VES Contado:',
                'Bs. ${_totalVesCounted.toStringAsFixed(2)}',
              ),
              const Divider(color: AppTheme.darkBorder, height: 16),
              _buildSummaryRow(
                'Punto de Venta / Pago Móvil:',
                'Bs. ${(_posVes + _pagoMovilVes).toStringAsFixed(2)}',
              ),
              const Divider(color: AppTheme.darkBorder, height: 16),
              _buildSummaryRow(
                'Total Arqueado (Equiv. USD):',
                '\$${_grandTotalUsdEquivalent.toStringAsFixed(2)}',
                isHighlight: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Text(
          'Observaciones o Notas del Cierre',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Añade cualquier nota justificativa para gerencia...',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? Colors.white : AppTheme.darkTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppTheme.cyanAccent : Colors.white,
          ),
        ),
      ],
    );
  }
}
