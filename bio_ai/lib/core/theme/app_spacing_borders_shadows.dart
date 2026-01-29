import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacings {
  // Tiny
  static const double xs = 4;
  static const double sm = 8;

  // Small
  static const double md = 12;
  static const double base = 16;

  // Medium
  static const double lg = 20;
  static const double xl = 24;

  // Large
  static const double xxl = 32;
  static const double xxxl = 48;

  // Edge Insets (Horizontal & Vertical)
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets h12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: 24);

  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets v12 = EdgeInsets.symmetric(vertical: 12);
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets v20 = EdgeInsets.symmetric(vertical: 20);
  static const EdgeInsets v24 = EdgeInsets.symmetric(vertical: 24);

  // All sides
  static const EdgeInsets all8 = EdgeInsets.all(8);
  static const EdgeInsets all12 = EdgeInsets.all(12);
  static const EdgeInsets all16 = EdgeInsets.all(16);
  static const EdgeInsets all20 = EdgeInsets.all(20);
  static const EdgeInsets all24 = EdgeInsets.all(24);

  // Common combinations
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 10,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets dialogPadding = EdgeInsets.all(24);
}

class AppBorderRadius {
  static const Radius none = Radius.circular(0);
  static const Radius xs = Radius.circular(4);
  static const Radius sm = Radius.circular(8);
  static const Radius md = Radius.circular(12);
  static const Radius base = Radius.circular(16);
  static const Radius lg = Radius.circular(20);
  static const Radius xl = Radius.circular(24);

  // BorderRadius objects
  static const BorderRadius bNone = BorderRadius.all(none);
  static const BorderRadius bXs = BorderRadius.all(xs);
  static const BorderRadius bSm = BorderRadius.all(sm);
  static const BorderRadius bMd = BorderRadius.all(md);
  static const BorderRadius bBase = BorderRadius.all(base);
  static const BorderRadius bLg = BorderRadius.all(lg);
  static const BorderRadius bXl = BorderRadius.all(xl);
}

class AppShadows {
  // Elevation shadows
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadow4 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> shadow5 = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Color-specific shadows
  static List<BoxShadow> shadowColor(Color color, double blurRadius) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.4),
        blurRadius: blurRadius,
        spreadRadius: 2,
      ),
    ];
  }
}
