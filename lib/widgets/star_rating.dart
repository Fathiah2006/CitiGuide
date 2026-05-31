import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

const Color _emptyStar = Color(0xFFE2E7EB);

/// A single solid amber star (the design's `StarSolid`).
class StarSolid extends StatelessWidget {
  final double size;
  final Color color;
  const StarSolid({super.key, this.size = 14, this.color = AppColors.star});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.star_rounded, size: size, color: color);
}

/// A row of five stars filled up to [value] (rounded).
class StarRow extends StatelessWidget {
  final double value;
  final double size;
  final double gap;
  const StarRow({super.key, required this.value, this.size = 14, this.gap = 2});

  @override
  Widget build(BuildContext context) {
    final full = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < 4 ? gap : 0),
          child: Icon(
            Icons.star_rounded,
            size: size,
            color: i < full ? AppColors.star : _emptyStar,
          ),
        );
      }),
    );
  }
}

/// Compact rating pill (the design's `RatingBadge`).
class RatingBadge extends StatelessWidget {
  final double value;
  final bool dark;
  const RatingBadge({super.key, required this.value, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: dark ? const Color(0x80081C2A) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: dark ? null : AppShadows.sh1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StarSolid(size: 12),
          const SizedBox(width: 4),
          Text(
            value.toStringAsFixed(1),
            style: AppTheme.body(12.5,
                weight: FontWeight.w700,
                color: dark ? Colors.white : AppColors.ink),
          ),
        ],
      ),
    );
  }
}
