import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF10B981);
const Color backgroundColor = Color(0xFF181B20);
const Color surfaceColor = Color(0xFF1E2126);

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      surface: Colors.white,
      surfaceContainerLow: const Color(0xFFF5F5F5),
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: surfaceColor,
      surfaceContainer: surfaceColor,
      surfaceContainerHigh: surfaceColor,
      surfaceContainerHighest: surfaceColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black54),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.blueGrey[50],
      focusColor: Colors.blueGrey[50],
      hoverColor: Colors.blueGrey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[300]!, width: 1),),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[300]!, width: 1),
        ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[300]!, width: 1),
        ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // colorSchemeSeed: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: primaryColor,
      onPrimaryContainer: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      secondaryContainer: primaryColor,
      onSecondaryContainer: Colors.white,
      tertiary: primaryColor,
      onTertiary: Colors.white,
      surface: surfaceColor,
      onSurface: Colors.white70,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: surfaceColor,
      surfaceContainerLow: surfaceColor,
      surfaceContainer: surfaceColor,
      surfaceContainerHigh: surfaceColor,
      surfaceContainerHighest: surfaceColor,
      onSurfaceVariant: Colors.white54,
      error: Color(0xFFEF4444),
      onError: Colors.white,
      outline: Colors.white24,
      outlineVariant: Colors.white12,
      onInverseSurface: Colors.white, 
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      modalBarrierColor: Colors.black54, // Overlay completamente neutro (gris/negro)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        overlayColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        overlayColor: primaryColor,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        overlayColor: primaryColor,
      ),
    ),
    
    textTheme: GoogleFonts.spaceGroteskTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white54),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: backgroundColor,
      
      // focusColor: surfaceColor,
      // hoverColor: surfaceColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: const BorderSide(color: Colors.white, width: 1),),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    ),
  );
}
