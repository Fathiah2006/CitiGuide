import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/listing.dart';
import '../../services/map_launcher_service.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cg_photo.dart';
import '../../widgets/heart_button.dart';
import '../../widgets/mini_map.dart';
import '../../widgets/rating_summary.dart';
import '../../widgets/review_item.dart';
import '../../widgets/star_rating.dart';

class ListingDetailsScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailsScreen({super.key, required this.listingId});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  int _img = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = SeedData.listingById(widget.listingId)!;
    final cat = SeedData.catById(l.categoryId)!;
    final baseHue = l.hue ?? cat.hue;
    final reviews = app.reviewsFor(l.id);
    final isFav = app.isFavourite(l.id);

    void openMap() =>
        Navigator.of(context).pushNamed(Routes.map, arguments: l.id);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // ── hero gallery ──
              SizedBox(
                height: 320,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CgPhoto(hue: baseHue + _img * 14, cat: cat.icon, dim: true),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _GlassCircle(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            Row(
                              children: [
                                _GlassCircle(
                                    icon: Icons.ios_share,
                                    onTap: () => _share(context)),
                                const SizedBox(width: 10),
                                HeartButton(
                                  on: isFav,
                                  dark: true,
                                  onPressed: () => app.toggleFavourite(l.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 36,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          l.images.clamp(1, 4),
                          (i) => GestureDetector(
                            onTap: () => setState(() => _img = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _img ? 22 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _img
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── body sheet ──
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(l, cat),
                      const SizedBox(height: 10),
                      _addressRow(l),
                      const SizedBox(height: 20),
                      _quickActions(l, openMap),
                      const Divider(height: 40, color: AppColors.line),
                      Text('About', style: AppTheme.title(17)),
                      const SizedBox(height: 8),
                      Text(l.description,
                          style: AppTheme.body(14.5,
                              color: AppColors.ink2, height: 1.6)),
                      if (l.tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: l.tags
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgAlt,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(t,
                                        style: AppTheme.body(12.5,
                                            weight: FontWeight.w600,
                                            color: AppColors.ink2)),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _InfoRow(
                          icon: Icons.schedule,
                          label: 'Opening hours',
                          value: l.hours),
                      _InfoRow(
                          icon: Icons.call_outlined,
                          label: 'Phone',
                          value: l.phone,
                          actionLabel: 'Call',
                          onAction: () => MapLauncherService.dial(l.phone)),
                      _InfoRow(
                          icon: Icons.public,
                          label: 'Website',
                          value: l.website,
                          actionLabel: 'Visit',
                          last: true,
                          onAction: () =>
                              MapLauncherService.openWebsite(l.website)),
                      const SizedBox(height: 20),
                      Text('Location', style: AppTheme.title(17)),
                      const SizedBox(height: 12),
                      MiniMap(onTap: openMap, label: 'Directions'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 15, color: AppColors.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(l.address,
                                style: AppTheme.body(13.5,
                                    color: AppColors.muted)),
                          ),
                        ],
                      ),
                      const Divider(height: 44, color: AppColors.line),
                      RatingSummary(
                        listing: l,
                        onAdd: () => Navigator.of(context)
                            .pushNamed(Routes.addReview, arguments: l.id),
                      ),
                      const SizedBox(height: 6),
                      for (final r in reviews.take(2)) ReviewItem(review: r),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(Routes.reviews, arguments: l.id),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          side: const BorderSide(
                              color: AppColors.line, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('See all ${l.ratingCount} reviews',
                            style: AppTheme.body(16,
                                weight: FontWeight.w700,
                                color: AppColors.primary)),
                      ),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── sticky CTA ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              decoration: const BoxDecoration(
                color: Color(0xF0FFFFFF),
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.price.isNotEmpty ? 'Price' : 'Entry',
                          style: AppTheme.body(12,
                              weight: FontWeight.w600, color: AppColors.muted)),
                      Text(
                          l.price.isNotEmpty
                              ? l.price
                              : (l.categoryId == 'attractions' ||
                                      l.categoryId == 'events'
                                  ? 'Free'
                                  : 'Varies'),
                          style: AppTheme.title(17)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: openMap,
                      child: Container(
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x380B3D5C),
                                blurRadius: 20,
                                offset: Offset(0, 8)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.navigation_outlined,
                                size: 19, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Get directions',
                                style: AppTheme.body(16,
                                    weight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(Listing l, cat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(cat.name.toUpperCase(),
                      style: AppTheme.body(11.5,
                          weight: FontWeight.w700,
                          color: AppColors.primary300)),
                  if (l.price.isNotEmpty)
                    Text(' · ${l.price}',
                        style: AppTheme.body(12.5,
                            weight: FontWeight.w600, color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.name, style: AppTheme.display(25, height: 1.12)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const StarSolid(size: 17),
                const SizedBox(width: 4),
                Text(l.rating.toStringAsFixed(1), style: AppTheme.title(18)),
              ],
            ),
            const SizedBox(height: 1),
            Text('${l.ratingCount} reviews',
                style: AppTheme.body(12, color: AppColors.muted)),
          ],
        ),
      ],
    );
  }

  Widget _addressRow(Listing l) {
    return Row(
      children: [
        const Icon(Icons.place_outlined, size: 15, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(l.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.body(13.5, color: AppColors.muted)),
        ),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: l.openNow ? AppColors.success : AppColors.danger,
              ),
            ),
            const SizedBox(width: 5),
            Text(l.openNow ? 'Open now' : 'Closed',
                style: AppTheme.body(13,
                    weight: FontWeight.w700,
                    color: l.openNow ? AppColors.success : AppColors.danger)),
          ],
        ),
      ],
    );
  }

  Widget _quickActions(Listing l, VoidCallback openMap) {
    return Row(
      children: [
        _QuickAction(
            icon: Icons.navigation_outlined,
            label: 'Directions',
            primary: true,
            onTap: openMap),
        _QuickAction(
            icon: Icons.call_outlined,
            label: 'Call',
            onTap: () => MapLauncherService.dial(l.phone)),
        _QuickAction(
            icon: Icons.public,
            label: 'Website',
            onTap: () => MapLauncherService.openWebsite(l.website)),
        _QuickAction(
            icon: Icons.ios_share,
            label: 'Share',
            onTap: () => _share(context)),
      ],
    );
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Sharing link copied')));
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      this.primary = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primary ? AppColors.primary : AppColors.primaryTint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  size: 22,
                  color: primary ? Colors.white : AppColors.primary),
            ),
            const SizedBox(height: 7),
            Text(label,
                style: AppTheme.body(12,
                    weight: FontWeight.w600, color: AppColors.ink2)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool last;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.actionLabel,
    this.onAction,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.line2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bgAlt,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.body(12,
                        weight: FontWeight.w600, color: AppColors.muted)),
                const SizedBox(height: 1),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(14.5, weight: FontWeight.w600)),
              ],
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(actionLabel!,
                    style: AppTheme.body(13.5,
                        weight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x57081C2A),
        ),
        child: Icon(icon, size: 22, color: Colors.white),
      ),
    );
  }
}
