import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/home/presentation/screens/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _storeNameController = TextEditingController(
    text: 'Abasto La Estrella',
  );
  final TextEditingController _rifController = TextEditingController(
    text: 'J-12345678-0',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+58 414-1234567',
  );

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _rifController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Brand Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/nexus_brand_logo.png',
                        height: 32,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.bolt,
                          color: AppTheme.cyanAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NEXUS',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Omitir',
                      style: TextStyle(color: AppTheme.darkTextSecondary),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),

            // Page Indicator & Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.cyanAccent
                              : AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2
                            ? 'Comenzar a Usar Nexus'
                            : 'Siguiente Paso',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Paso 1 de 3',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenido a Nexus',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Configura los datos principales de tu comercio',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _storeNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre del Negocio',
              prefixIcon: Icon(Icons.store_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rifController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'RIF / Registro Fiscal',
              prefixIcon: Icon(Icons.badge_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Teléfono Comercial',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Paso 2 de 3',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestión Bimoneda USD/VES',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Define tu tasa de cambio de preferencia',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.currency_exchange_rounded,
                  color: AppTheme.cyanAccent,
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasa Oficial BCV Activa',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Sincronización automática diaria',
                        style: GoogleFonts.inter(
                          color: AppTheme.darkTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '36.50 Bs.',
                  style: GoogleFonts.jetBrainsMono(
                    color: AppTheme.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Paso 3 de 3',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Todo Listo para Vender!',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Tu punto de venta está 100% listo para facturar y controlar stock.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Icon(
              Icons.rocket_launch_rounded,
              size: 84,
              color: AppTheme.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }
}
