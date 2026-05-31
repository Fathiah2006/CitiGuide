import 'package:flutter/material.dart';

import '../utils/app_icons.dart';

/// Deterministic placeholder "photo" — a calm duotone wash + faint contour
/// texture + optional category glyph. Ported from the design's `Photo`
/// primitive so the app needs no external image assets.
class CgPhoto extends StatelessWidget {
  final double hue;
  final String? cat; // category icon-name for the centred glyph
  final double radius;
  final bool dim; // dark gradient at the bottom for text legibility
  final BoxFit fit;

  const CgPhoto({
    super.key,
    this.hue = 200,
    this.cat,
    this.radius = 0,
    this.dim = false,
    this.fit = BoxFit.cover,
  });

  Color get _a => HSLColor.fromAHSL(1, hue % 360, 0.26, 0.66).toColor();
  Color get _b =>
      HSLColor.fromAHSL(1, (hue + 22) % 360, 0.32, 0.43).toColor();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.7, -1),
                end: const Alignment(0.7, 1),
                colors: [_a, _b],
              ),
            ),
          ),
          // soft light from the top-left
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.64, -0.76),
                radius: 1.1,
                colors: [Color(0x57FFFFFF), Color(0x00FFFFFF)],
                stops: [0, 0.55],
              ),
            ),
          ),
          // faint contour texture
          CustomPaint(painter: _ContourPainter(), size: Size.infinite),
          // category glyph
          if (cat != null)
            Center(
              child: Icon(
                AppIcons.forName(cat),
                size: 46,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          // dim overlay for overlaid text
          if (dim)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00081C2A), Color(0x8C081C2A)],
                  stops: [0.38, 1],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.22);

    // Drawn in a 200×140 design space, then scaled to fill.
    final sx = size.width / 200;
    final sy = size.height / 140;
    canvas.save();
    canvas.scale(sx, sy);

    void contour(double y) {
      final path = Path()
        ..moveTo(-10, y)
        ..cubicTo(40, y - 20, 80, y + 30, 130, y + 8)
        ..cubicTo(180, y - 6, 220, y - 10, 230, y + 20);
      canvas.drawPath(path, paint);
    }

    contour(40);
    contour(70);
    contour(100);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ContourPainter oldDelegate) => false;
}
