import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import 'admin_cities_screen.dart';
import 'admin_listings_screen.dart';
import 'admin_reviews_screen.dart';

/// Admin landing — quick stats and entry points to manage content. Only
/// reachable when the signed-in profile has role = 'admin'.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('Admin', style: AppTheme.title(18.5))),
        body: Center(
          child: Text('Admins only.',
              style: AppTheme.body(15, color: AppColors.muted)),
        ),
      );
    }

    final cards = [
      _AdminCard(
        icon: Icons.place_outlined,
        title: 'Listings',
        sub: '${SeedData.listings.length} places · add, edit, remove',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AdminListingsScreen())),
      ),
      _AdminCard(
        icon: Icons.location_city_outlined,
        title: 'Cities',
        sub: '${SeedData.cities.length} cities · manage destinations',
        color: AppColors.primary600,
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminCitiesScreen())),
      ),
      _AdminCard(
        icon: Icons.reviews_outlined,
        title: 'Reviews',
        sub: 'Moderate & remove inappropriate reviews',
        color: AppColors.coral,
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminReviewsScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: AppBar(
        title: Text('Admin dashboard', style: AppTheme.title(18.5)),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.line2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Manage content',
              style: AppTheme.body(13,
                  weight: FontWeight.w700, color: AppColors.muted)),
          const SizedBox(height: 12),
          for (final c in cards) ...[c, const SizedBox(height: 14)],
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.sh1,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.title(17)),
                  const SizedBox(height: 2),
                  Text(sub, style: AppTheme.body(13, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted2),
          ],
        ),
      ),
    );
  }
}
