import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF4B7BFF);
  static const Color secondary = Color(0xFF10B981);
  static const Color tertiary = Color(0xFF8B5CF6);

  // Backgrounds
  static const Color bgBody = Color(0xFFF2F5F9);
  static const Color bgSurface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Accent Colors
  static const Color accentBlue = Color(0xFF4B7BFF);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFEAB308);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF4B7BFF);

  // Border & Divider
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFCBD5E1);

  // Shadow
  static const Color shadowColor = Color(0x1F000000);

  // Deprecated: Use primary, secondary, etc. instead
  @deprecated
  static const kBgBody = bgBody;
  @deprecated
  static const kTextMain = textMain;
  @deprecated
  static const kTextSecondary = textSecondary;
  @deprecated
  static const kAccentBlue = accentBlue;
  @deprecated
  static const kAccentGreen = accentGreen;
  @deprecated
  static const kAccentOrange = accentOrange;
  @deprecated
  static const kAccentPurple = accentPurple;
}
