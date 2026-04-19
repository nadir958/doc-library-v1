import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette de couleurs Stitch (Premium Vault)
  static const Color primaryColor = Color(0xFFC0C1FF); // Primary (Light Lavender)
  static const Color primaryContainerColor = Color(0xFF8083FF); // Primary Container (Indigo)
  static const Color secondaryColor = Color(0xFF4CD7F6); // Secondary (Cyan)
  static const Color tertiaryColor = Color(0xFF2FD9F4); // Tertiary (Bright Blue)
  static const Color backgroundColor = Color(0xFF0C1322); // Background (Deep Navy)
  static const Color surfaceColor = Color(0xFF191F2F); // Surface (Slate)
  static const Color surfaceVariantColor = Color(0xFF2E3545); // Surface Variant
  static const Color onSurfaceColor = Color(0xFFDCE2F7); // On Surface
  static const Color onSurfaceVariantColor = Color(0xFFC7C4D7); // On Surface Variant
  static const Color errorColor = Color(0xFFFFB4AB); // Error (Soft Red)

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    primaryColor: const Color(0xFF6366F1),
    
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6366F1), // Indigo
      primaryContainer: const Color(0xFFEEF2FF),
      onPrimaryContainer: const Color(0xFF4338CA),
      secondary: const Color(0xFF0EA5E9), // Sky
      secondaryContainer: const Color(0xFFF0F9FF),
      onSecondaryContainer: const Color(0xFF0369A1),
      surface: Colors.white,
      onSurface: const Color(0xFF0F172A),
      surfaceVariant: const Color(0xFFF1F5F9),
      onSurfaceVariant: const Color(0xFF64748B),
      error: const Color(0xFFEF4444),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        fontFamily: 'Manrope',
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF0F172A).withOpacity(0.05)),
      ),
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
      bodyLarge: const TextStyle(color: Color(0xFF0F172A)),
      bodyMedium: const TextStyle(color: Color(0xFF64748B)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      primaryContainer: primaryContainerColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: surfaceColor,
      surfaceVariant: surfaceVariantColor,
      onSurface: onSurfaceColor,
      onSurfaceVariant: onSurfaceVariantColor,
      error: errorColor,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xCC141B2B), // Blur equivalent handled in UI if possible
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: onSurfaceColor,
        fontFamily: 'Manrope',
      ),
    ),
    
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent, // Handled with gradient in UI
      foregroundColor: backgroundColor,
    ),
    
    textTheme: GoogleFonts.interTextTheme().copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: onSurfaceColor,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: onSurfaceColor,
      ),
      bodyLarge: const TextStyle(color: onSurfaceColor),
      bodyMedium: const TextStyle(color: onSurfaceVariantColor),
    ),
  );
}
