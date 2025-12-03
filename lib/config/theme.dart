import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider<bool>((ref) => true); // Default to Dark Mode

class AppTheme {
  // Orange & Black Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF9800), // Orange
      onPrimary: Colors.black,
      secondary: Color(0xFFFFB74D), // Lighter Orange
      surface: Color(0xFF121212),
      background: Color(0xFF000000),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
  );

  // Orange & White Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF9800), // Orange
      onPrimary: Colors.white,
      secondary: Color(0xFFE65100), // Dark Orange
      surface: Colors.white,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
  );
}