import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

/// Pill-shaped chip used for categories, filters and recent searches.
class CgChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const CgChip({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.ink2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.line,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 7),
            ],
            Text(label,
                style:
                    AppTheme.body(13.5, weight: FontWeight.w600, color: fg)),
          ],
        ),
      ),
    );
  }
}
