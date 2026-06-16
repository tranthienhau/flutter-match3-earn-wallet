import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Draws a single flat-vector geometric shape - circles, squares, stars, etc.
/// Pure [CustomPainter], so there are zero image assets and it scales crisply.
class ShapePainter extends CustomPainter {
  ShapePainter(this.kind, {this.faded = false});

  final ShapeKind kind;
  final bool faded;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kind.color.withValues(alpha: faded ? 0.25 : 1)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.34;

    switch (kind) {
      case ShapeKind.circle:
        canvas.drawCircle(c, r, paint);
      case ShapeKind.square:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.8, height: r * 1.8),
            const Radius.circular(6),
          ),
          paint,
        );
      case ShapeKind.triangle:
        canvas.drawPath(_polygon(c, r, 3, -math.pi / 2), paint);
      case ShapeKind.hexagon:
        canvas.drawPath(_polygon(c, r, 6, 0), paint);
      case ShapeKind.diamond:
        canvas.drawPath(_polygon(c, r, 4, 0), paint);
      case ShapeKind.star:
        canvas.drawPath(_star(c, r, r * 0.45, 5), paint);
    }
  }

  Path _polygon(Offset c, double r, int sides, double rot) {
    final p = Path();
    for (var i = 0; i < sides; i++) {
      final a = rot + i * 2 * math.pi / sides;
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  Path _star(Offset c, double outer, double inner, int points) {
    final p = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      final pt = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(ShapePainter old) =>
      old.kind != kind || old.faded != faded;
}

/// A flippable memory card. Face-down shows a neutral panel; face-up paints the shape.
class ShapeCard extends StatelessWidget {
  const ShapeCard({
    super.key,
    required this.kind,
    required this.revealed,
    required this.matched,
    required this.hinted,
    this.onTap,
  });

  final ShapeKind kind;
  final bool revealed;
  final bool matched;
  final bool hinted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final faceUp = revealed || matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: faceUp ? AppColors.surfaceAlt : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hinted
                ? AppColors.warn
                : matched
                    ? AppColors.accent
                    : Colors.white10,
            width: hinted || matched ? 2 : 1,
          ),
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: matched ? 0.45 : 1,
          child: faceUp
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomPaint(painter: ShapePainter(kind)),
                )
              : const Center(
                  child: Icon(Icons.help_outline,
                      color: AppColors.textDim, size: 22),
                ),
        ),
      ),
    );
  }
}
