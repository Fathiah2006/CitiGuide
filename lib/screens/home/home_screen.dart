import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/listing.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cg_chip.dart';
import '../../widgets/cg_image.dart';
import '../../widgets/featured_card.dart';
import '../../widgets/listing_row.dart';
import '../../widgets/section_head.dart';

/// Home / Explore tab — city hero, search shortcut, category chips, featured
/// carousel and a popular listings list.
class HomeScreen extends StatefulWidget {
  final VoidCallback onSearchTap;
  const HomeScreen({super.key, required this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cat = 'all';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final city =
        SeedData.cityById(app.selectedCityId ?? '') ?? SeedData.cities.first;
    final all = SeedData.byCity(city.id);
    final featured = all.where((l) => l.featured).toList();
    final list = _cat == 'all'
        ? all
        : all.where((l) => l.categoryId == _cat).toList();

    final cats = [
      ('all', 'All', Icons.home_outlined),
      ...SeedData.categories.map((c) => (c.id, c.name, _catIcon(c.icon))),
    ];

    void open(Listing l) =>
        Navigator.of(context).pushNamed(Routes.details, arguments: l.id);

    return Container(
      color: AppColors.bgAlt,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── hero ──
          SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CgImage(imageUrl: city.imageUrl, hue: city.hue, dim: true),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _GlassButton(
                              onTap: () => Navigator.of(context)
                                  .pushNamed(Routes.city),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.place_outlined,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(city.name,
                                      style: AppTheme.body(13.5,
                                          weight: FontWeight.w700,
                                          color: Colors.white)),
                                  const Icon(Icons.keyboard_arrow_down,
                                      size: 18, color: Colors.white),
                                ],
                              ),
                            ),
                            _GlassButton(
                              circle: true,
                              onTap: () => ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(const SnackBar(
                                    content: Text('No new notifications'))),
                              child: const Icon(Icons.notifications_outlined,
                                  size: 20, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Explore',
                                  style: AppTheme.body(13.5,
                                      weight: FontWeight.w600,
                                      color:
                                          Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 3),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                child: Text(city.tagline,
                                    style: AppTheme.display(26,
                                        color: Colors.white, height: 1.12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── search shortcut (overlapping) ──
          Transform.translate(
            offset: const Offset(0, -26),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: widget.onSearchTap,
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.sh2,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: AppColors.muted),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text('Search ${city.name}…',
                            style: AppTheme.body(15, color: AppColors.muted)),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.tune,
                            size: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── category chips ──
          Transform.translate(
            offset: const Offset(0, -14),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 9),
                itemBuilder: (context, i) {
                  final (id, name, icon) = cats[i];
                  return CgChip(
                    label: name,
                    icon: icon,
                    active: _cat == id,
                    onTap: () => setState(() => _cat = id),
                  );
                },
              ),
            ),
          ),
          // ── featured ──
          if (_cat == 'all' && featured.isNotEmpty) ...[
            const SectionHead(title: 'Featured', sub: 'Hand-picked highlights'),
            SizedBox(
              height: 262,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                itemCount: featured.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final l = featured[i];
                  return FeaturedCard(
                    listing: l,
                    isFav: app.isFavourite(l.id),
                    onFav: () => _fav(context, l.id),
                    onOpen: () => open(l),
                  );
                },
              ),
            ),
          ],
          // ── popular list ──
          SectionHead(
            title: _cat == 'all'
                ? 'Popular in ${city.name}'
                : SeedData.catById(_cat)!.name,
            sub: '${list.length} places',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                for (final l in list) ...[
                  ListingRow(
                    listing: l,
                    isFav: app.isFavourite(l.id),
                    onFav: () => _fav(context, l.id),
                    onOpen: () => open(l),
                  ),
                  const Divider(height: 9, color: AppColors.line),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _fav(BuildContext context, String id) {
    final added = context.read<AppState>().toggleFavourite(id);
    if (added) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Saved to favourites')));
    }
  }

  static IconData _catIcon(String name) => switch (name) {
        'landmark' => Icons.account_balance_outlined,
        'utensils' => Icons.restaurant_outlined,
        'bed' => Icons.king_bed_outlined,
        'ticket' => Icons.confirmation_number_outlined,
        _ => Icons.place_outlined,
      };
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool circle;
  const _GlassButton(
      {required this.child, required this.onTap, this.circle = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: circle ? 40 : null,
        padding: circle ? null : const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x52081C2A),
          borderRadius: BorderRadius.circular(circle ? 999 : 100),
        ),
        child: child,
      ),
    );
  }
}
