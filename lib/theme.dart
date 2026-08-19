import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // SafeSenior Stitch Design Tokens
  static const Color primaryTeal = Color(0xFF006565);          // Primary Brand Teal
  static const Color primaryContainer = Color(0xFF008080);     // Medium Teal Container
  static const Color onPrimaryContainer = Color(0xFFE3FFFE);   // On Teal Container
  static const Color primaryFixed = Color(0xFF93F2F2);         // Light Teal Fixed
  static const Color primaryFixedDim = Color(0xFF76D6D5);

  static const Color secondary = Color(0xFFAA361F);            // Terracotta Alert / Danger
  static const Color terracottaRed = Color(0xFFAA361F);
  static const Color secondaryContainer = Color(0xFFFE7356);
  static const Color onSecondaryContainer = Color(0xFF6D0F00);
  static const Color secondaryFixed = Color(0xFFFFDAD3);

  static const Color tertiaryGold = Color(0xFF735C00);         // Warm Gold for badges
  static const Color tertiaryContainer = Color(0xFFCCA830);

  static const Color backgroundColor = Color(0xFFFBF9F9);      // Warm Off-White
  static const Color cardColor = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFF5F3F3);
  static const Color surfaceContainer = Color(0xFFEFEDED);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E7);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E2);

  static const Color textDark = Color(0xFF1B1C1C);             // On Surface
  static const Color textBody = Color(0xFF1B1C1C);             // Primary Body Text
  static const Color textLight = Color(0xFF3E4949);            // Muted Variant
  static const Color outline = Color(0xFF6E7979);              // Border / Outline
  static const Color outlineVariant = Color(0xFFBDC9C8);

  // Backward compatibility aliases
  static const Color primaryDarkBlue = primaryTeal;
  static const Color primaryLightBlue = primaryContainer;
  static const Color errorRed = secondary;
  static const Color dangerRed = secondary;
  static const Color celebrationGold = tertiaryContainer;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textLight;
  static const Color dividerColor = Color(0xFFE3E2E2);

  static TextStyle headlineLg({double fontSize = 32, FontWeight fontWeight = FontWeight.w700, Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle headlineMd({double fontSize = 24, FontWeight fontWeight = FontWeight.w600, Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: 1.25,
    );
  }

  static TextStyle headlineSm({double fontSize = 20, FontWeight fontWeight = FontWeight.w600, Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: 1.3,
    );
  }

  static TextStyle bodyLg({double fontSize = 18, FontWeight fontWeight = FontWeight.w400, Color? color}) {
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textBody,
      height: 1.5,
    );
  }

  static TextStyle bodyMd({double fontSize = 16, FontWeight fontWeight = FontWeight.w400, Color? color}) {
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textLight,
      height: 1.45,
    );
  }

  static TextStyle labelLg({double fontSize = 18, FontWeight fontWeight = FontWeight.w600, Color? color}) {
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textDark,
      height: 1.3,
    );
  }

  static TextStyle labelMd({double fontSize = 14, FontWeight fontWeight = FontWeight.w700, Color? color}) {
    return GoogleFonts.atkinsonHyperlegible(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? primaryTeal,
      letterSpacing: 0.5,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryTeal,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryTeal,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        error: secondary,
        onError: Colors.white,
        surface: backgroundColor,
        onSurface: textDark,
        onSurfaceVariant: textLight,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w700, color: textDark),
        displayMedium: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w600, color: textDark),
        headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.atkinsonHyperlegible(fontSize: 18, color: textBody),
        bodyMedium: GoogleFonts.atkinsonHyperlegible(fontSize: 16, color: textLight),
        labelLarge: GoogleFonts.atkinsonHyperlegible(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        labelMedium: GoogleFonts.atkinsonHyperlegible(fontSize: 14, fontWeight: FontWeight.w700, color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: outlineVariant, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.atkinsonHyperlegible(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        labelStyle: GoogleFonts.atkinsonHyperlegible(color: textLight, fontSize: 16, fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.atkinsonHyperlegible(color: const Color(0xFF717171), fontSize: 16),
        prefixIconColor: textLight,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
