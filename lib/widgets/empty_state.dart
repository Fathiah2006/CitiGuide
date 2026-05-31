import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

/// Centred empty / error placeholder with icon, title, body and an action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.title(18)),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppTheme.body(14, color: AppColors.muted, height: 1.5),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: SizedBox(width: double.infinity, child: action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
