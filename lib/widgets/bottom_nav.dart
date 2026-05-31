import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const BottomNavItem(this.icon, this.activeIcon, this.label);
}

/// The frosted bottom navigation bar (Explore / Search / Saved / Profile).
class CgBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CgBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    BottomNavItem(Icons.home_outlined, Icons.home_rounded, 'Explore'),
    BottomNavItem(Icons.search, Icons.search, 'Search'),
    BottomNavItem(Icons.favorite_border, Icons.favorite, 'Saved'),
    BottomNavItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xEBFFFFFF),
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 26),
      child: Row(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final on = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      on ? item.activeIcon : item.icon,
                      size: 23,
                      color: on ? AppColors.primary : AppColors.muted2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: AppTheme.body(11,
                          weight: on ? FontWeight.w700 : FontWeight.w600,
                          color: on ? AppColors.primary : AppColors.muted2),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
