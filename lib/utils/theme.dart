import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------
  // 1. Visual Token Foundations - Calm Workspace Edition
  // ---------------------------------------------------------
  
  // Backgrounds
  static const Color baseBackground = Color(0xFFF2F5F9); // Soft neutral grey (No pure white)
  static const Color surfaceBackground = Color(0xFFF7F9FC); // Cards, sections
  static const Color elevatedSurface = Color(0xFFFFFFFF); // Active cards, dialogs
  static const Color border = Color(0xFFE8EDF3); // Dividers, inputs

  // Typography Colors (Soft Contrast)
  static const Color textPrimary = Color(0xFF111827); // Not pure black
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Accents
  static const Color primaryAccent = Color(0xFF5C7CFA); // Active tabs, primary button
  static const Color successAccent = Color(0xFF6FCF97); // Positive statistics
  static const Color warningAccent = Color(0xFFF2C94C); // Warnings
  static const Color errorAccent = Color(0xFFEB5757);   // Errors

  // ---------------------------------------------------------
  // Backward compatibility tokens (To prevent breaking views during transition)
  // ---------------------------------------------------------
  static const Color primaryColor = primaryAccent;
  static const Color secondaryColor = successAccent;
  static const Color accentColor = warningAccent;
  static const Color errorColor = errorAccent;
  static const Color backgroundColor = baseBackground;
  static const Color cardColor = surfaceBackground;
  static const Color surfaceColor = elevatedSurface;
  static const Color textColorPrimary = textPrimary;
  static const Color textColorSecondary = textSecondary;
  static const Color borderHighlightColor = border;

  // ---------------------------------------------------------
  // 4. Elevation System (Extremely Low Visual Noise)
  // ---------------------------------------------------------
  static final List<BoxShadow> level1Shadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 20,
      offset: const Offset(0, 4),
    )
  ];
  
  static final List<BoxShadow> level2Shadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 8),
    )
  ];

  // ---------------------------------------------------------
  // Main ThemeData Config
  // ---------------------------------------------------------
  static ThemeData get calmTheme {
    // 2. Typography System (Inter, weight 400-600 mostly)
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: baseBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryAccent,
        secondary: successAccent,
        surface: elevatedSurface,
        error: errorAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      // Card radius 24
      cardTheme: CardThemeData(
        color: surfaceBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: border,
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: baseBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600, // Not w800/w900 as requested
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      // Input radius 16
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorAccent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0, // No thick shadows
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      // Typography scaling mapped to Inter
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      iconTheme: const IconThemeData(
        color: textSecondary,
      ),
    );
  }

  // Alias just in case older code still points to darkTheme
  static ThemeData get darkTheme => calmTheme;
}
