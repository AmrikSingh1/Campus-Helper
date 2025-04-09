import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color primary = Color(0xFF6946B2);     // Original purple
  static const Color secondary = Color(0xFF8F73D4);   // Lighter purple
  static const Color accent = Color(0xFFFF8E3B);      // Keeping the orange accent
  static const Color darkPurple = Color(0xFF383B60);  // Less intense dark purple
  static const Color white = Color(0xFFFFFFFF);
  static const Color teal = Color(0xFF4ECDC4);        // Teal accent color
  static const Color mint = Color(0xFFD1F0EA);        // Light mint for subtle backgrounds

  // Background Gradient - Using original purple colors
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // Additional UI Colors
  static const Color lightGrey = Color(0xFFF4F4F6);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFE57373);
  static const Color successGreen = Color(0xFF81C784);
} 