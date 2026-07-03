import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF1A73E8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD3E3FD);
  static const Color onPrimaryContainer = Color(0xFF041E49);

  static const Color secondary = Color(0xFF34A853);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFCEEAD6);
  static const Color onSecondaryContainer = Color(0xFF0B3D16);

  static const Color tertiary = Color(0xFFFBBC04);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFF2B0);
  static const Color onTertiaryContainer = Color(0xFF3F2E00);

  static const Color error = Color(0xFFEA4335);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFADBD8);
  static const Color onErrorContainer = Color(0xFF410002);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF202124);
  
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF202124);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  static const Color onSurfaceVariant = Color(0xFF5F6368);
  
  static const Color outline = Color(0xFFE8EAED);
  static const Color outlineVariant = Color(0xFFC4C7C5);

  // Spacing (8dp Grid)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;

  // Shapes
  static const double radiusSmall = 8.0; // Text fields
  static const double radiusMedium = 12.0; // Cards, dialogs
  static const double radiusLarge = 16.0; // FABs
  static const double radiusPill = 999.0; // Chips

  // Typography - Inter for UI, JetBrains Mono for Data
  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
      displayMedium: base.displayMedium?.copyWith(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: base.displaySmall?.copyWith(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w600), // SemiBold
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w600), // SemiBold
      headlineSmall: base.headlineSmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w600), // SemiBold
      titleLarge: base.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w600), // SemiBold
      titleMedium: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500), // Medium
      titleSmall: base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500), // Medium
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w400), // Regular
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400), // Regular
      bodySmall: base.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400), // Regular
      labelLarge: base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500), // Medium
      labelMedium: base.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500), // Medium
      labelSmall: base.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w500), // Medium
    );
  }

  // Helper for Numeric Typography
  static TextStyle numericLg(BuildContext context) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle numericMd(BuildContext context) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle numericSm(BuildContext context) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: onSurfaceVariant),
        titleTextStyle: _textTheme.titleLarge?.copyWith(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium), // Specified 12dp rectangular CTA
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outline),
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 48), // touch target
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: onSurfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusSmall),
            topRight: Radius.circular(radiusSmall),
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: onSurfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusSmall),
            topRight: Radius.circular(radiusSmall),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: primary, width: 2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusSmall),
            topRight: Radius.circular(radiusSmall),
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: error),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusSmall),
            topRight: Radius.circular(radiusSmall),
          ),
        ),
        labelStyle: _textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
        floatingLabelStyle: _textTheme.bodySmall?.copyWith(color: primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryContainer,
        foregroundColor: onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
    );
  }
}
