import 'package:flutter/material.dart';

/// CitiGuide design tokens — ported from the design system (styles.css `:root`).
/// Clean / minimal · deep-navy primary · amber ratings · warm coral accent.
class AppColors {
  AppColors._();

  // ── brand ──
  static const Color primary = Color(0xFF0B3D5C); // deep navy
  static const Color primary700 = Color(0xFF082C43);
  static const Color primary600 = Color(0xFF114E73);
  static const Color primary300 = Color(0xFF5C8AA6);
  static const Color primaryTint = Color(0xFFEAF1F6); // navy wash for surfaces
  static const Color primaryTint2 = Color(0xFFDBE7EF);

  // ── neutrals (cool-warm balanced) ──
  static const Color ink = Color(0xFF15202B); // near-black, navy tinted
  static const Color ink2 = Color(0xFF3A4853);
  static const Color muted = Color(0xFF6A7A86); // slate
  static const Color muted2 = Color(0xFF9AA7B0);
  static const Color line = Color(0xFFE7ECEF); // hairline
  static const Color line2 = Color(0xFFF0F3F5);
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgAlt = Color(0xFFF6F8FA); // subtle off-white
  static const Color bgAlt2 = Color(0xFFEEF2F5);

  // ── accents ──
  static const Color star = Color(0xFFE8A23D); // amber, ratings
  static const Color coral = Color(0xFFE2603B); // warm CTA accent (sparing)
  static const Color success = Color(0xFF2F9E73);
  static const Color danger = Color(0xFFD8553F);
}

/// Corner radius scale.
class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
}

/// Soft elevation shadows matching --sh-1/2/3.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sh1 = [
    BoxShadow(color: Color(0x0D15202B), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A15202B), blurRadius: 1, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sh2 = [
    BoxShadow(color: Color(0x1415202B), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0D15202B), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> sh3 = [
    BoxShadow(color: Color(0x2915202B), blurRadius: 44, offset: Offset(0, 18)),
    BoxShadow(color: Color(0x1415202B), blurRadius: 16, offset: Offset(0, 6)),
  ];
}
