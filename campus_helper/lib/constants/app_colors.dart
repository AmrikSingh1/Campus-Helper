import 'package:flutter/material.dart';

class AppColors {
  // Theme Colors
  static const Color primary = Color(0xFF6946B2);
  static const Color secondary = Color(0xFFAA96D9);
  static const Color accent = Color(0xFFFF8E3B);
  static const Color darkPurple = Color(0xFF2B234F);
  static const Color white = Color(0xFFFFFFFF);

  // Background Gradient
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