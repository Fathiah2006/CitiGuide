import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

/// Stylised map-pin logo mark — a teardrop pin with an amber guiding star.
class LogoMark extends StatelessWidget {
  final double size;
  final bool light; // light variant for dark backgrounds
  const LogoMark({super.key, this.size = 48, this.light = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: size,
            color: light ? Colors.white : AppColors.primary,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.16),
            child: Icon(
              Icons.star_rounded,
              size: size * 0.4,
              color: AppColors.star,
            ),
          ),
        ],
      ),
    );
  }
}

/// "CitiGuide" wordmark + mark lockup.
class Logo extends StatelessWidget {
  final double size;
  final bool light;
  const Logo({super.key, this.size = 48, this.light = false});

  @override
  Widget build(BuildContext context) {
    final fg = light ? Colors.white : AppColors.primary;
    final accent =
        light ? Colors.white.withValues(alpha: 0.6) : AppColors.primary300;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: size, light: light),
        const SizedBox(width: 13),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Citi', style: AppTheme.display(size * 0.46, color: fg)),
              TextSpan(
                  text: 'Guide',
                  style: AppTheme.display(size * 0.46, color: accent)),
            ],
          ),
        ),
      ],
    );
  }
}
