import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS System Grouped Background
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE5E5EA),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0C3866),
        secondary: Color(0xFF007AFF),
        surface: Colors.white,
        onSurface: Color(0xFF1C1C1E),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000), // iOS System Grouped Background Dark
      cardColor: const Color(0xFF1C1C1E),
      dividerColor: const Color(0xFF38383A),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0A84FF),
        secondary: Color(0xFF0A84FF),
        surface: Color(0xFF1C1C1E),
        onSurface: Colors.white,
      ),
    );
  }
}
