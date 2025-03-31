import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constants {
  static String appName = "DecorHome";

  // Colors from new palette
  static Color lightestColor = Color(0xFFDAD7CD); // Light sage - for backgrounds
  static Color lightAccentColor = Color(0xFFA3B18A); // Sage - for secondary elements
  static Color midColor = Color(0xFF588157); // Fern green - for primary elements
  static Color darkAccentColor = Color(0xFF3A5A40); // Hunter green - for accents
  static Color darkestColor = Color(0xFF344E41); // Brunswick green - for dark elements

  //Colors for theme
  static Color lightPrimary = lightestColor;
  static Color darkPrimary = darkestColor;
  static Color lightAccent = midColor;
  static Color darkAccent = midColor;
  static Color lightBG = lightestColor;
  static Color darkBG = darkestColor;
  static Color ratingBG = midColor;
  static Color errorColor = Colors.red.shade700;
  static String placeholderImage = "https://images.pexels.com/photos/1571458/pexels-photo-1571458.jpeg";

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
    colorScheme: ColorScheme.light(
      primary: midColor,
      secondary: lightAccentColor,
      background: lightBG,
      error: errorColor,
      surface: lightestColor,
      onBackground: darkestColor,
      onSurface: darkestColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        bodyLarge: TextStyle(color: darkestColor),
        bodyMedium: TextStyle(color: darkestColor),
        titleMedium: TextStyle(color: darkestColor),
      )
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.poppins(
        color: darkestColor,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: lightestColor,
      iconTheme: IconThemeData(color: midColor),
      elevation: 0,
    ),
    iconTheme: IconThemeData(
      color: midColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: midColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: midColor,
      foregroundColor: lightestColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: midColor,
        foregroundColor: lightestColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: midColor,
        side: BorderSide(color: midColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: midColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: midColor),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: TextStyle(color: lightestColor),
      backgroundColor: midColor,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBG,
    colorScheme: ColorScheme.dark(
      primary: midColor,
      secondary: lightAccentColor,
      background: darkestColor,
      error: errorColor,
      surface: darkAccentColor,
      onBackground: lightestColor,
      onSurface: lightestColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        bodyLarge: TextStyle(color: lightestColor),
        bodyMedium: TextStyle(color: lightestColor),
        titleMedium: TextStyle(color: lightestColor),
      )
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.poppins(
        color: lightestColor,
        fontSize: 18.0,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: darkestColor,
      iconTheme: IconThemeData(color: lightAccentColor),
      elevation: 0,
    ),
    iconTheme: IconThemeData(
      color: lightAccentColor,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: midColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: midColor,
      foregroundColor: lightestColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: midColor,
        foregroundColor: lightestColor,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightAccentColor,
        side: BorderSide(color: lightAccentColor),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightAccentColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: lightAccentColor),
        borderRadius: BorderRadius.circular(8),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkAccentColor),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    cardTheme: CardTheme(
      color: darkAccentColor,
      elevation: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: TextStyle(color: lightestColor),
      backgroundColor: midColor,
    ),
  );
}
