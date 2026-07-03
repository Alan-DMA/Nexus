import 'package:flutter/material.dart';

class AppTheme {
  // Colores Base (Paleta HSL/Slate de alta gama)
  static const Color darkBackground = Color(0xFF0B0F19); // Azul oscuro noche profundo
  static const Color darkSurface = Color(0xFF161D30);    // Gris azulado vidrio card
  static const Color darkSurfaceLight = Color(0xFF222C47); // Superficies secundarias
  
  // Colores de Acento (Vibrantes y Contrastantes)
  static const Color primary = Color(0xFF6366F1);       // Indigo Eléctrico
  static const Color primaryGlow = Color(0x3D6366F1);   // Resplandor Indigo
  static const Color secondary = Color(0xFF06B6D4);     // Cían Neo
  static const Color accent = Color(0xFFF97316);        // Naranja Hetzner / Alerta
  
  // Colores de Estado
  static const Color success = Color(0xFF10B981);       // Esmeralda Éxito
  static const Color warning = Color(0xFFF59E0B);       // Ambar Advertencia
  static const Color error = Color(0xFFEF4444);         // Rojo Error

  // Tema Oscuro Premium
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        background: darkBackground,
        error: error,
      ),
      
      // Estilo de Tipografía
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)), // Slate 400
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF64748B)), // Slate 500
      ),

      // Estilo de Tarjetas (Cards)
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1), // Slate 800
        ),
      ),

      // Estilo de Inputs y Formularios
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E293B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),

      // Estilo de Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Estilo de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
