import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';

/// The design's `.field` text input with leading icon and optional label.
class AppTextField extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.icon,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.trailing,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppTheme.body(13,
                  weight: FontWeight.w600, color: AppColors.ink2)),
          const SizedBox(height: 8),
        ],
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.bgAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: enabled ? AppColors.line : AppColors.line2, width: 1.5),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 19,
                    color: enabled ? AppColors.muted : AppColors.muted2),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  enabled: enabled,
                  onChanged: onChanged,
                  cursorColor: AppColors.primary,
                  style: AppTheme.body(15.5,
                      color: enabled ? AppColors.ink : AppColors.muted),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle:
                        AppTheme.body(15.5, color: AppColors.muted2),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}

/// Password field with a show/hide toggle.
class AppPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  const AppPasswordField({
    super.key,
    this.label = 'Password',
    this.hint = '••••••••',
    this.controller,
    this.onChanged,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      icon: Icons.lock_outline,
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      obscureText: !_show,
      onChanged: widget.onChanged,
      trailing: GestureDetector(
        onTap: () => setState(() => _show = !_show),
        child: Icon(
          _show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 19,
          color: AppColors.muted,
        ),
      ),
    );
  }
}
