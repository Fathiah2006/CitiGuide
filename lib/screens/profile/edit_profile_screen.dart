import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/toggle_switch.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppState>().profile;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    context
        .read<AppState>()
        .updateProfile(name: _name.text.trim(), phone: _phone.text.trim());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.profile;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        titleSpacing: 0,
        title: Text('Edit profile', style: AppTheme.title(18.5)),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: AppTheme.body(15,
                    weight: FontWeight.w800, color: AppColors.primary)),
          ),
        ],
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.line2)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 14),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Text(p.initials,
                          style: AppTheme.body(34,
                              weight: FontWeight.w800, color: Colors.white)),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: AppShadows.sh2,
                        ),
                        child: const Icon(Icons.photo_camera_outlined,
                            size: 17, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Change photo',
                    style: AppTheme.body(13.5,
                        weight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
              icon: Icons.person_outline,
              label: 'Full name',
              controller: _name),
          const SizedBox(height: 16),
          AppTextField(
              icon: Icons.call_outlined, label: 'Phone', controller: _phone),
          const SizedBox(height: 16),
          AppTextField(
            icon: Icons.mail_outline,
            label: 'Email',
            controller: TextEditingController(text: p.email),
            enabled: false,
            trailing:
                const Icon(Icons.lock_outline, size: 16, color: AppColors.muted2),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Push notifications',
                        style: AppTheme.body(15, weight: FontWeight.w600)),
                    const SizedBox(height: 1),
                    Text('Events & recommendations',
                        style: AppTheme.body(12.5, color: AppColors.muted)),
                  ],
                ),
              ),
              ToggleSwitch(
                value: app.notificationsEnabled,
                onChanged: app.setNotifications,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
