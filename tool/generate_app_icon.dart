// Generates the CitiGuide launcher icon (navy field + white map-pin + amber
// star) entirely in Dart — run with:  dart run tool/generate_app_icon.dart
// Produces assets/icon/app_icon.png (full-bleed) and app_icon_foreground.png
// (transparent, padded for Android adaptive icons). flutter_launcher_icons
// then turns these into platform icons + the web favicon.
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

final navyA = img.ColorRgba8(11, 61, 92, 255); // #0B3D5C
final white = img.ColorRgba8(255, 255, 255, 255);
final amber = img.ColorRgba8(232, 162, 61, 255); // #E8A23D

void drawStar(img.Image im, double cx, double cy, double outer, double inner) {
  final pts = <img.Point>[];
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outer : inner;
    final a = (-90 + i * 36) * pi / 180.0;
    pts.add(img.Point(cx + r * cos(a), cy + r * sin(a)));
  }
  img.fillPolygon(im, vertices: pts, color: amber);
}

/// Draws a white teardrop pin (with an amber star) centred horizontally at [cx]
/// with its circle centred at [circleCy] and circle radius [r].
void drawPin(img.Image im, double cx, double circleCy, double r) {
  // pin point (triangle blending into the circle's lower half)
  img.fillPolygon(im, vertices: [
    img.Point(cx - 0.74 * r, circleCy + 0.55 * r),
    img.Point(cx + 0.74 * r, circleCy + 0.55 * r),
    img.Point(cx, circleCy + r + 0.9 * r),
  ], color: white);
  img.fillCircle(im,
      x: cx.round(), y: circleCy.round(), radius: r.round(), color: white, antialias: true);
  drawStar(im, cx, circleCy, 0.48 * r, 0.20 * r);
}

void main() {
  Directory('assets/icon').createSync(recursive: true);

  // ── full-bleed icon (iOS / web / legacy Android) ──
  final full = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(full, color: navyA);
  drawPin(full, 512, 420, 210);
  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(full));

  // ── adaptive foreground (transparent, padded into the safe zone) ──
  final fg = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.fill(fg, color: img.ColorRgba8(0, 0, 0, 0));
  drawPin(fg, 512, 430, 150);
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(img.encodePng(fg));

  // ignore: avoid_print
  print('Wrote assets/icon/app_icon.png and app_icon_foreground.png');
}
