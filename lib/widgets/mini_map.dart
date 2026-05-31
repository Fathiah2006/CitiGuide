import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';
import 'star_rating.dart';

/// Abstract, minimal map illustration with a teardrop pin — used on the
/// listing detail card and as the full-bleed backdrop on the map screen.
/// (For the MVP, real directions hand off to an external map app.)
class MiniMap extends StatelessWidget {
  final double height;
  final double radius;
  final VoidCallback? onTap;
  final bool marker;
  final String? label; // e.g. "Directions" pill in the corner

  const MiniMap({
    super.key,
    this.height = 150,
    this.radius = 16,
    this.onTap,
    this.marker = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final map = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height == double.infinity ? null : height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MapPainter()),
            if (marker)
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -19),
                  child: Transform.rotate(
                    angle: -0.785398, // -45°
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(19),
                          topRight: Radius.circular(19),
                          bottomLeft: Radius.circular(19),
                        ),
                        boxShadow: AppShadows.sh2,
                      ),
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: const Center(
                            child: StarSolid(size: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            if (label != null)
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: AppShadows.sh1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.navigation_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(label!,
                          style: AppTheme.body(12.5,
                              weight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return map;
    return GestureDetector(onTap: onTap, child: map);
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 200;
    canvas.save();
    canvas.scale(sx, sy);

    // base
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, 320, 200), Paint()..color = const Color(0xFFEAF0F2));

    // city blocks
    final block = Paint()..color = const Color(0xFFDDE6E9);
    for (final r in const [
      Rect.fromLTWH(20, 18, 70, 52),
      Rect.fromLTWH(200, 30, 90, 44),
      Rect.fromLTWH(40, 130, 80, 50),
      Rect.fromLTWH(230, 120, 70, 64),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(4)), block);
    }

    // main roads (white)
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 95), const Offset(320, 95), road);
    canvas.drawLine(const Offset(150, 0), const Offset(150, 200), road);
    final diag = Path()
      ..moveTo(0, 160)
      ..lineTo(120, 160)
      ..lineTo(150, 200);
    canvas.drawPath(diag, road);

    // road hairlines
    final hair = Paint()
      ..color = const Color(0xFFCFDADE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, 95), const Offset(320, 95), hair);
    canvas.drawLine(const Offset(150, 0), const Offset(150, 200), hair);

    // water
    final water = Path()
      ..moveTo(250, 0)
      ..quadraticBezierTo(300, 40, 320, 30)
      ..lineTo(320, 0)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFCBE0E6));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
