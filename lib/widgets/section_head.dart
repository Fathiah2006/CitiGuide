import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

/// Section header with a title, optional sub-label and trailing action.
class SectionHead extends StatelessWidget {
  final String title;
  final String? sub;
  final Widget? action;
  final EdgeInsets padding;

  const SectionHead({
    super.key,
    required this.title,
    this.sub,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.title(20)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!,
                      style: AppTheme.body(13, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
