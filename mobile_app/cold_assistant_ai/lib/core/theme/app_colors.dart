import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryLight = Color(0xFF818CF8);
  static const secondary = Color(0xFF10B981); // Emerald
  static const accent = Color(0xFFF59E0B); // Amber

  // Neutral Colors
  static const background = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const text = Color(0xFF0F172A); // Slate 900
  static const textMuted = Color(0xFF64748B); // Slate 500
  static const border = Color(0xFFE2E8F0); // Slate 200
  static const fieldFill = Color(0xFFF1F5F9); // Slate 100

  // Semantic Colors
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceGradient = LinearGradient(
    colors: [background, Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
