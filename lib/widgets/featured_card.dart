import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/listing.dart';
import '../services/seed_data.dart';
import '../utils/app_colors.dart';
import 'cg_image.dart';
import 'heart_button.dart';
import 'star_rating.dart';

/// A 246px-wide featured card for the Home horizontal carousel.
class FeaturedCard extends StatelessWidget {
  final Listing listing;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onOpen;

  const FeaturedCard({
    super.key,
    required this.listing,
    required this.isFav,
    required this.onFav,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cat = SeedData.catById(listing.categoryId)!;
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: 246,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.sh2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 152,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    child: CgImage(
                        imageUrl: listing.coverImageUrl,
                        hue: listing.hue ?? cat.hue,
                        cat: cat.icon,
                        dim: true),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: RatingBadge(value: listing.rating, dark: true),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: HeartButton(
                        on: isFav, onPressed: onFav, dark: true),
                  ),
                  if (listing.price.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Text(listing.price,
                          style: AppTheme.body(13,
                              weight: FontWeight.w700, color: Colors.white)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name.toUpperCase(),
                      style: AppTheme.body(11,
                          weight: FontWeight.w700,
                          color: AppColors.primary300)),
                  const SizedBox(height: 3),
                  Text(listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.title(16.5)),
                  const SizedBox(height: 4),
                  Text(listing.short,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(13, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
