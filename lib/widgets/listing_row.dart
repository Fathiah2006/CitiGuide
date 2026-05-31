import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/listing.dart';
import '../services/seed_data.dart';
import '../utils/app_colors.dart';
import 'cg_photo.dart';
import 'heart_button.dart';
import 'star_rating.dart';

/// A horizontal listing row used in lists (Home popular, Search, Favourites).
class ListingRow extends StatelessWidget {
  final Listing listing;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onOpen;

  const ListingRow({
    super.key,
    required this.listing,
    required this.isFav,
    required this.onFav,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cat = SeedData.catById(listing.categoryId)!;
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              height: 92,
              child: CgPhoto(
                  hue: listing.hue ?? cat.hue, cat: cat.icon, radius: 16),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.name.toUpperCase(),
                    style: AppTheme.body(11.5,
                        weight: FontWeight.w700,
                        color: AppColors.primary300),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.title(16),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const StarSolid(size: 13),
                      const SizedBox(width: 5),
                      Text(listing.rating.toStringAsFixed(1),
                          style: AppTheme.body(13, weight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Text('(${listing.ratingCount})',
                          style:
                              AppTheme.body(12.5, color: AppColors.muted)),
                      if (listing.price.isNotEmpty)
                        Text(' · ${listing.price}',
                            style:
                                AppTheme.body(12.5, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 13, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.address.isNotEmpty
                              ? listing.address
                              : listing.short,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.body(12.5, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            HeartButton(on: isFav, onPressed: onFav),
          ],
        ),
      ),
    );
  }
}
