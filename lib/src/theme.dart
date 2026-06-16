import 'package:flutter/material.dart';

/// Flat, geometric palette - deliberately clean so the casual UI reads at a glance.
class AppColors {
  static const bg = Color(0xFF0E1116);
  static const surface = Color(0xFF1A1F29);
  static const surfaceAlt = Color(0xFF232A36);
  static const primary = Color(0xFF5B8DEF);
  static const accent = Color(0xFF2DD4A7);
  static const warn = Color(0xFFF2B84B);
  static const danger = Color(0xFFE2566B);
  static const text = Color(0xFFE8EDF4);
  static const textDim = Color(0xFF8A93A3);

  static const shapeColors = <Color>[
    Color(0xFF5B8DEF), // blue
    Color(0xFF2DD4A7), // teal
    Color(0xFFF2B84B), // amber
    Color(0xFFE2566B), // rose
    Color(0xFFB07CF6), // violet
    Color(0xFF6FC8E8), // sky
  ];
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
  );
}

/// The six geometric shape kinds the match game uses (flat vectors, no assets).
enum ShapeKind { circle, square, triangle, star, hexagon, diamond }

extension ShapeKindColor on ShapeKind {
  Color get color => AppColors.shapeColors[index];
  String get label => switch (this) {
        ShapeKind.circle => 'Circle',
        ShapeKind.square => 'Square',
        ShapeKind.triangle => 'Triangle',
        ShapeKind.star => 'Star',
        ShapeKind.hexagon => 'Hexagon',
        ShapeKind.diamond => 'Diamond',
      };
}
