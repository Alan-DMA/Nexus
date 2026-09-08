import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class WhatsAppCatalogScreen extends StatefulWidget {
  const WhatsAppCatalogScreen({super.key});

  @override
  State<WhatsAppCatalogScreen> createState() => _WhatsAppCatalogScreenState();
}

class _WhatsAppCatalogScreenState extends State<WhatsAppCatalogScreen> {
  bool _isCatalogActive = true;
  bool _showPricesInVes = true;
  bool _allowDirectOrders = true;
  final String _catalogUrl = 'https://nexus.pos/c/abasto-la-estrella';

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
          'Catálogo Web & WhatsApp',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Color(0xFF25D366),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catálogo Digital Activo',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Tus clientes pueden pedir por WhatsApp',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isCatalogActive,
                        activeThumbColor: const Color(0xFF25D366),
                        onChanged: (val) =>
                            setState(() => _isCatalogActive = val),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _catalogUrl,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AppTheme.cyanAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          color: AppTheme.cyanAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enlace del catálogo copiado al portapapeles',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Configuración General',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Mostrar precios en Bs. (Tasa oficial)',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Conversión automática en tiempo real',
                      style: GoogleFonts.inter(
                        color: AppTheme.darkTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    value: _showPricesInVes,
                    activeThumbColor: AppTheme.cyanAccent,
                    onChanged: (val) => setState(() => _showPricesInVes = val),
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  SwitchListTile(
                    title: Text(
                      'Permitir pedidos directos a WhatsApp',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Genera un carrito formateado en el chat',
                      style: GoogleFonts.inter(
                        color: AppTheme.darkTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                    value: _allowDirectOrders,
                    activeThumbColor: AppTheme.cyanAccent,
                    onChanged: (val) =>
                        setState(() => _allowDirectOrders = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Vista Previa del Catálogo Web',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 84,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Escanea para abrir en el celular',
                      style: GoogleFonts.inter(
                        color: AppTheme.darkTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
