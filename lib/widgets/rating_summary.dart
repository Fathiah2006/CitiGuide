import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/listing.dart';
import '../utils/app_colors.dart';
import 'star_rating.dart';

/// Average rating, distribution bars and a "Write" shortcut.
class RatingSummary extends StatelessWidget {
  final Listing listing;
  final VoidCallback onAdd;
  const RatingSummary({super.key, required this.listing, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    const dist = [0.72, 0.18, 0.06, 0.02, 0.02]; // 5..1
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews & ratings', style: AppTheme.title(17)),
            GestureDetector(
              onTap: onAdd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text('Write',
                      style: AppTheme.body(13.5,
                          weight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(listing.rating.toStringAsFixed(1),
                    style: AppTheme.display(42, height: 1)),
                const SizedBox(height: 6),
                StarRow(value: listing.rating, size: 13),
                const SizedBox(height: 4),
                Text('${listing.ratingCount} reviews',
                    style: AppTheme.body(12, color: AppColors.muted)),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < dist.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10,
                            child: Text('${5 - i}',
                                style: AppTheme.body(11.5,
                                    color: AppColors.muted)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: dist[i],
                                minHeight: 6,
                                backgroundColor: AppColors.bgAlt2,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.star),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
