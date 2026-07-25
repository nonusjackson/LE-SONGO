import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SongoColors {
  static const woodDark = Color(0xFF4A2C17);
  static const woodMid = Color(0xFF6B4226);
  static const seedBase = Color(0xFFC89B6B);
  static const accentGold = Color(0xFFD4A017);
  static const captureFlash = Color(0xFFC1652F);
  static const hintBlue = Color(0xFF4FA6D8);
  static const background = Color(0xFFF5EAD9);
  static const surface = Color(0xFFFFF8ED);
  static const textDark = Color(0xFF2B1B12);
  static const pitCenter = Color(0xFF2B1B12);
  static const seedLight = Color(0xFFE8D4B8);
  static const seedDark = Color(0xFF8B6238);
}

class SongoTextStyles {
  static TextStyle score = GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: SongoColors.textDark,
  );

  static TextStyle title = GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: SongoColors.textDark,
  );

  static TextStyle label = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: SongoColors.textDark,
  );

  static TextStyle labelMuted = GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: SongoColors.textDark.withOpacity(0.65),
  );

  static TextStyle button = GoogleFonts.manrope(fontWeight: FontWeight.w700);

  static TextStyle seedCount = GoogleFonts.manrope(
    fontWeight: FontWeight.w800,
    color: SongoColors.background,
  );
}

ThemeData buildSongoTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: SongoColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SongoColors.woodDark,
      brightness: Brightness.light,
    ).copyWith(
      primary: SongoColors.woodDark,
      secondary: SongoColors.accentGold,
      surface: SongoColors.surface,
    ),
    textTheme: TextTheme(
      titleLarge: SongoTextStyles.title,
      bodyLarge: SongoTextStyles.label,
      bodyMedium: SongoTextStyles.label,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SongoColors.woodDark,
        foregroundColor: SongoColors.background,
        textStyle: SongoTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SongoColors.woodDark,
        side: const BorderSide(color: SongoColors.woodMid, width: 1.5),
        textStyle: SongoTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: SongoColors.background,
      foregroundColor: SongoColors.textDark,
      elevation: 0,
      titleTextStyle: SongoTextStyles.title,
    ),
  );
}
