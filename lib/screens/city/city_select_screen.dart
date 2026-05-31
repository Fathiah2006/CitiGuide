import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/city.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cg_photo.dart';

/// City selection — first run after login, and "Change city" from home.
class CitySelectScreen extends StatelessWidget {
  const CitySelectScreen({super.key});

  void _select(BuildContext context, String cityId) {
    context.read<AppState>().selectCity(cityId);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.main, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AppState>().selectedCityId;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CITIGUIDE',
                      style: AppTheme.body(13,
                          weight: FontWeight.w700, color: AppColors.primary300)),
                  const SizedBox(height: 8),
                  Text('Where to?', style: AppTheme.display(32)),
                  const SizedBox(height: 6),
                  Text('Pick a city to start exploring.',
                      style: AppTheme.body(15, color: AppColors.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  for (final city in SeedData.cities) ...[
                    _CityCard(
                      city: city,
                      selected: selected == city.id,
                      onTap: () => _select(context, city.id),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityCard extends StatelessWidget {
  final City city;
  final bool selected;
  final VoidCallback onTap;
  const _CityCard(
      {required this.city, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.sh2,
          border: selected
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CgPhoto(hue: city.hue, dim: true, radius: 22),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 14, color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 6),
                      Text(city.state,
                          style: AppTheme.body(12.5,
                              weight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(city.name,
                      style: AppTheme.display(26, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('${city.places} places · ${city.tagline}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(13,
                          color: Colors.white.withValues(alpha: 0.82))),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(Icons.check, size: 17, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
