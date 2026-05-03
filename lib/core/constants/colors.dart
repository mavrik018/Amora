import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE91E63);
  static const Color secondary = Color(0xFF007AFF);
  static const Color tertiary = Color(0xFF008C47);
  static const Color neutral = Color(0xFF8A7174);

  static const Color background = Color(0xFFFDF2F3);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF4081)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
}
