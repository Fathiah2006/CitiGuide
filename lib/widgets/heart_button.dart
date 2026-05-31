import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Circular save/favourite toggle. On a photo it uses a translucent dark
/// backing (`dark: true`); on light surfaces a white chip with a soft shadow.
class HeartButton extends StatelessWidget {
  final bool on;
  final VoidCallback onPressed;
  final bool dark;
  const HeartButton({
    super.key,
    required this.on,
    required this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? const Color(0x66081C2A) : Colors.white,
          boxShadow: dark ? null : AppShadows.sh1,
        ),
        child: Icon(
          on ? Icons.favorite : Icons.favorite_border,
          size: 19,
          color: on
              ? AppColors.coral
              : (dark ? Colors.white : AppColors.muted),
        ),
      ),
    );
  }
}
