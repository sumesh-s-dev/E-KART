import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color deepBlue = Color(0xFF1A1A2E);
  static const Color cardBlue = Color(0xFF16213E);
  
  // Secondary Colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningOrange = Color(0xFFFF9500);
  static const Color infoBlue = Color(0xFF3182CE);
  
  // Utility Methods - Updated for Flutter 3.27+
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}