import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Gravity Falls inspired palette
  static const Color deepBlue = Color(0xFF0F172A);
  static const Color lighterBlue = Color(0xFF1E293B);
  static const Color sunsetOrange = Color(0xFFF97316);
  static const Color burntOrange = Color(0xFFEA580C);
  static const Color mysticGold = Color(0xFFFFD700);
  static const Color forestGreen = Color(0xFF2E8B57); // For "Active" state

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: deepBlue,
      colorScheme: ColorScheme.dark(
        primary: sunsetOrange,
        secondary: mysticGold,
        surface: lighterBlue,
        background: deepBlue,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      fontFamily: GoogleFonts.pressStart2p().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.pressStart2p(
          fontSize: 24,
          color: sunsetOrange,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
          ],
        ),
        bodyLarge: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.pressStart2p(
          fontSize: 12,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.pressStart2p( // Button text
          fontSize: 16,
          color: Colors.white,
        )
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: burntOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Pixel art hard edges
            side: BorderSide(color: Colors.black, width: 2),
          ),
          elevation: 0,
          textStyle: GoogleFonts.pressStart2p(fontSize: 14),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lighterBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: sunsetOrange, width: 2),
        ),
        hintStyle: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white38),
      ),
    );
  }
}
