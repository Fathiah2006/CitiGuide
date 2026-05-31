import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/toggle_switch.dart';

/// Profile tab — header card with stats, menu, notification toggle, log out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.profile;

    final menu = <_MenuEntry>[
      _MenuEntry(Icons.edit_outlined, 'Edit profile',
          onTap: () => Navigator.of(context).pushNamed(Routes.editProfile)),
      _MenuEntry(Icons.star_outline, 'My reviews', meta: '${app.reviewCount}'),
      _MenuEntry(Icons.place_outlined, 'Change city',
          onTap: () => Navigator.of(context).pushNamed(Routes.city)),
      _MenuEntry(Icons.info_outline, 'Help & support',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & support (demo)')))),
    ];

    return Container(
      color: AppColors.bgAlt,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // header card
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Avatar(initials: p.initials, size: 72, fontSize: 26),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTheme.title(21)),
                              const SizedBox(height: 2),
                              Text(p.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.body(13.5,
                                      color: AppColors.muted)),
                              const SizedBox(height: 3),
                              Text(p.joined,
                                  style: AppTheme.body(12.5,
                                      color: AppColors.muted2)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.editProfile),
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgAlt,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _Stat(label: 'Saved', value: '${app.favouriteCount}'),
                          _Stat(
                              label: 'Reviews',
                              value: '${app.reviewCount}',
                              border: true),
                          _Stat(
                              label: 'Cities',
                              value: '${SeedData.cities.length}',
                              border: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // menu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.sh1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (int i = 0; i < menu.length; i++)
                        _MenuRow(entry: menu[i], last: i == menu.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.sh1,
                  ),
                  child: Row(
                    children: [
                      _IconTile(icon: Icons.notifications_outlined),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notifications',
                                style: AppTheme.body(15.5,
                                    weight: FontWeight.w600)),
                            const SizedBox(height: 1),
                            Text('Events & new places',
                                style: AppTheme.body(12.5,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                      ToggleSwitch(
                        value: app.notificationsEnabled,
                        onChanged: app.setNotifications,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    app.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.login, (_) => false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.sh1,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0x1AD8553F),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.logout,
                              size: 19, color: AppColors.danger),
                        ),
                        const SizedBox(width: 14),
                        Text('Log out',
                            style: AppTheme.body(15.5,
                                weight: FontWeight.w700,
                                color: AppColors.danger)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('CitiGuide v1.0 · MVP',
                    style: AppTheme.body(12, color: AppColors.muted2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String label;
  final String? meta;
  final VoidCallback? onTap;
  _MenuEntry(this.icon, this.label, {this.meta, this.onTap});
}

class _MenuRow extends StatelessWidget {
  final _MenuEntry entry;
  final bool last;
  const _MenuRow({required this.entry, required this.last});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: entry.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.line2)),
        ),
        child: Row(
          children: [
            _IconTile(icon: entry.icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(entry.label,
                  style: AppTheme.body(15.5, weight: FontWeight.w600)),
            ),
            if (entry.meta != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(entry.meta!,
                    style: AppTheme.body(13.5,
                        weight: FontWeight.w600, color: AppColors.muted)),
              ),
            const Icon(Icons.chevron_right, size: 19, color: AppColors.muted2),
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final IconData icon;
  const _IconTile({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 19, color: AppColors.primary),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool border;
  const _Stat({required this.label, required this.value, this.border = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: border
            ? const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.line)))
            : null,
        child: Column(
          children: [
            Text(value, style: AppTheme.title(21, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTheme.body(12,
                    weight: FontWeight.w600, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  const _Avatar(
      {required this.initials, required this.size, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Text(initials,
          style: AppTheme.body(fontSize,
              weight: FontWeight.w800, color: Colors.white)),
    );
  }
}
