import 'package:flutter/material.dart';

/// Maps the design's icon-name strings (from `icons.jsx`) to Material icons,
/// so seed data referring to e.g. `'landmark'` renders a sensible glyph.
class AppIcons {
  AppIcons._();

  static const Map<String, IconData> _map = {
    'landmark': Icons.account_balance_outlined,
    'utensils': Icons.restaurant_outlined,
    'bed': Icons.king_bed_outlined,
    'ticket': Icons.confirmation_number_outlined,
    'home': Icons.home_outlined,
    'search': Icons.search,
    'heart': Icons.favorite_border,
    'user': Icons.person_outline,
    'mapPin': Icons.place_outlined,
    'star': Icons.star_rounded,
    'bell': Icons.notifications_outlined,
    'sliders': Icons.tune,
    'nav': Icons.navigation_outlined,
    'phone': Icons.call_outlined,
    'globe': Icons.public,
    'clock': Icons.schedule,
    'camera': Icons.photo_camera_outlined,
    'edit': Icons.edit_outlined,
    'info': Icons.info_outline,
  };

  static IconData forName(String? name) =>
      _map[name] ?? Icons.place_outlined;
}
