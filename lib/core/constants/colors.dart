import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors from design
  static const Color primary = Color(0xFFE91E63); // Rose-pink
  static const Color secondary = Color(0xFF007AFF); // SealCheck blue
  static const Color tertiary = Color(0xFF008C47); // Success Green
  static const Color neutral = Color(0xFF8A7174); // Muted mauve

  // Background & Surfaces
  static const Color background = Color(0xFFFDF2F3); // Soft pink background
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF4081)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
}
