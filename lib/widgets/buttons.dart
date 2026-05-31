import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

enum CgButtonVariant { primary, ghost, outline }

/// The design's `.btn` family — a 54px pill button in three tones.
class CgButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CgButtonVariant variant;
  final IconData? icon;
  final bool enabled;

  const CgButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = CgButtonVariant.primary,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == CgButtonVariant.primary;
    final isOutline = variant == CgButtonVariant.outline;

    final Color bg = switch (variant) {
      CgButtonVariant.primary => AppColors.primary,
      CgButtonVariant.ghost => AppColors.bgAlt2,
      CgButtonVariant.outline => Colors.white,
    };
    final Color fg = isPrimary ? Colors.white : AppColors.ink;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onPressed : null,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: isOutline
                  ? Border.all(color: AppColors.line, width: 1.5)
                  : null,
              boxShadow: isPrimary
                  ? const [
                      BoxShadow(
                          color: Color(0x380B3D5C),
                          blurRadius: 20,
                          offset: Offset(0, 8)),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 19,
                      color: isOutline ? AppColors.primary : fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTheme.body(16,
                      weight: FontWeight.w700,
                      color: isOutline ? AppColors.primary : fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
