import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- CORE PALETTE ---
  static const Color primaryDb = Color(0xFF030303); // Deep Black
  static const Color charcoal = Color(0xFF0F0F0F); // Elegant Charcoal
  static const Color champagneGold = Color(0xFFE2D1B3); // Sophisticated Gold
  static const Color accentGold = Color(0xFFD4AF37); // Classic Gold
  static const Color pearlWhite = Color(0xFFF5F5F7); // Apple-style white
  // Increased contrast for muted text to improve readability
  static const Color mutedSilver = Color(
    0xFFA0A0A0,
  ); // Muted luxury text (brightened for contrast)

  // --- LUXURY PERFUME PALETTE ---
  static const Color ivoryBackground = Color(
    0xFFF5F1ED,
  ); // Soft cream background
  static const Color creamWhite = Color(0xFFFAF8F5); // Warm white
  static const Color parchment = Color(
    0xFFFCF5E5,
  ); // Sophisticated parchment for AI
  static const Color softTaupe = Color(0xFFE8E0D5); // Subtle border color
  // Make deepCharcoal darker so body text is more readable on light backgrounds
  static const Color deepCharcoal = Color(
    0xFF0D0D0D,
  ); // Rich text color (stronger)

  // --- GLASSMORPHISM ---
  static const Color glassWhite = Color(0x0DFFFFFF); // 5% White
  static const Color glassBorder = Color(0x1AFFFFFF); // 10% White

  // --- DYNAMIC UTILS ---
  static LinearGradient getLuxuryGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [charcoal, primaryDb],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), pearlWhite],
          );
  }

  static LinearGradient getGoldGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [champagneGold, accentGold],
    );
  }

  static ThemeData darkTheme = _buildTheme(Brightness.dark);
  static ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData midnightGoldTheme = _buildMidnightGoldTheme();

  // --- STAFF-SPECIFIC THEMES (more readable fonts & slightly larger sizes) ---
  static ThemeData staffDarkTheme = _buildStaffTheme(Brightness.dark);
  static ThemeData staffLightTheme = _buildStaffTheme(Brightness.light);

  static ThemeData _buildMidnightGoldTheme() {
    Color bg = const Color(0xFF0A0A0A);
    Color surface = const Color(0xFF141414);
    Color textColor = pearlWhite;
    Color subTextColor = mutedSilver;
    Color gold = accentGold;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: gold,
      colorScheme: ColorScheme.dark(
        primary: gold,
        onPrimary: Colors.black,
        secondary: gold,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textColor,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.montserrat(fontSize: 16, color: textColor),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: subTextColor),
      ),
      // Glassmorphism adjustment for Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  static ThemeData _buildTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;

    // Core dynamic colors
    Color bg = isDark ? primaryDb : ivoryBackground;
    Color surface = isDark ? charcoal : creamWhite;
    Color textColor = isDark ? pearlWhite : deepCharcoal;
    Color subTextColor = isDark ? mutedSilver : const Color(0xFF6B6B6B);

    // Glass effect refinement
    Color glassBg = isDark
        ? const Color(0x0DFFFFFF)
        : const Color(0xCCFFFFFF); // 5% vs 80%
    Color glassBorderColor = isDark
        ? const Color(0x1AFFFFFF)
        : const Color(0x1A000000); // 10% white vs 10% black

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      primaryColor: champagneGold,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: champagneGold,
        onPrimary: primaryDb,
        secondary: accentGold,
        onSecondary: Colors.white,
        error: const Color(0xFFFF453A),
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
        outline: glassBorderColor,
      ),

      // Custom Page Transitions for a premium feel
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // --- TYPOGRAPHY ---
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: textColor,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: champagneGold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: subTextColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
          color: champagneGold,
        ),
      ),

      // --- BUTTONS ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: champagneGold,
          foregroundColor: primaryDb,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // --- INPUTS ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassBg,
        hintStyle: GoogleFonts.montserrat(
          color: subTextColor.withValues(alpha: 0.5),
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: glassBorderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: glassBorderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: champagneGold, width: 0.5),
        ),
      ),
    );
  }

  static ThemeData _buildStaffTheme(Brightness brightness) {
    // Build on top of the regular theme but increase base sizes and use
    // a highly readable sans-serif (Inter) for body text.
    final base = _buildTheme(brightness);
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? pearlWhite : deepCharcoal;
    final Color subTextColor = isDark ? mutedSilver : const Color(0xFF6B6B6B);

    return base.copyWith(
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: textColor,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: champagneGold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: textColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: subTextColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: champagneGold,
        ),
      ),
    );
  }
}
