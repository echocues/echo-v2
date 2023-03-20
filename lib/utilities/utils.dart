import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Utils {
  static double mapRange(double value, double inputStart, double inputEnd, double outputStart, double outputEnd) {
    return ((value - inputStart) / (inputEnd - inputStart)) * (outputEnd - outputStart) + outputStart;
  }
  
  static ThemeData defaultDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: const MaterialColor(0xffe0fbfc, {
          50: Color.fromRGBO(224, 251, 252, .1),
          100: Color.fromRGBO(224, 251, 252, .2),
          200: Color.fromRGBO(224, 251, 252, .3),
          300: Color.fromRGBO(224, 251, 252, .4),
          400: Color.fromRGBO(224, 251, 252, .5),
          500: Color.fromRGBO(224, 251, 252, .6),
          600: Color.fromRGBO(224, 251, 252, .7),
          700: Color.fromRGBO(224, 251, 252, .8),
          800: Color.fromRGBO(224, 251, 252, .9),
          900: Color.fromRGBO(224, 251, 252, 1),
        }),
        accentColor: const Color(0xffee6C4C),
        cardColor: const Color(0xff3d5a80),
        backgroundColor: const Color(0xff424242),
        errorColor: Colors.redAccent,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayMedium: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 20,
          ),
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.notoSans(
          textStyle: const TextStyle(
            fontSize: 14,
          ),
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.notoSans(
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.notoSans(
          textStyle: const TextStyle(
            fontSize: 14,
          ),
          color: Colors.white,
        ),
      )
    );
  }
}