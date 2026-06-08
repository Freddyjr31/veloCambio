// import 'package:flutter/material.dart';
// import 'package:googlefonts/googlefonts.dart';

// const Color primaryColor = Color(0xFF001233); 
// const Color themeColor = Color(0xFF263238);

// class AppTheme {

//   // Opción: Puedes pasar un bool para saber si es modo oscuro
//   final bool isDarkmode;
  
//   AppTheme({this.isDarkmode = true});

//   ThemeData get themeData {
//     return ThemeData(
//         useMaterial3: true,
//         primaryColor: primaryColor,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: primaryColor,
//           brightness: isDarkmode ? Brightness.dark : Brightness.light,
//         ),
//         textTheme: GoogleFonts.nunitoTextTheme().copyWith(
//           bodyLarge: TextStyle(color: isDarkmode ? Colors.white : primaryColor),
//           bodyMedium: TextStyle(color: isDarkmode ? Colors.white : primaryColor),
//           bodySmall: TextStyle(color: isDarkmode ? Colors.white : primaryColor),
//         ),
//         colorSchemeSeed: primaryColor,
//         brightness: isDarkmode ? Brightness.dark : Brightness.light,
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: themeColor,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ),
//       );
//   }

// }


import 'package:flutter/material.dart';

// Colores base personalizados
const Color primaryColor = Color(0xFF2196F3); // Azul
const Color accentColor = Color(0xFF03DAC6);  // Teal
const Color themeColor = Color.fromARGB(255, 4, 21, 30);   // Gris

class AppTheme {
  // --- TEMA CLARO ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      surface: Colors.white,
      background: const Color(0xFFF5F5F5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Estilo para los textos
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.black),
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

  // --- TEMA OSCURO ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF1E1E1E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      surface: const Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E), // Gris oscuro para que resalte del fondo
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.blueGrey[50],
      focusColor: Colors.blueGrey[50],
      hoverColor: Colors.blueGrey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[100]!, width: 1),),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[100]!, width: 1),
        ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        gapPadding: 2,
        borderSide: BorderSide(color: Colors.blueGrey[100]!, width: 1),
        ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    ),
    
  );
}