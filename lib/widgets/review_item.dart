import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/review.dart';
import '../utils/app_colors.dart';
import 'star_rating.dart';

/// A single review with avatar initials, stars, body and a "Helpful" like
/// toggle (the like is local UI state, matching the design prototype).
class ReviewItem extends StatefulWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  late bool _liked = widget.review.liked;
  late int _likes = widget.review.likes;

  String get _initials => widget.review.user
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .join();

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTint,
                ),
                child: Text(_initials,
                    style: AppTheme.body(14,
                        weight: FontWeight.w800, color: AppColors.primary)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.user,
                        style: AppTheme.body(14.5, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarRow(value: r.rating.toDouble(), size: 11),
                        const SizedBox(width: 7),
                        Text(r.date,
                            style:
                                AppTheme.body(12, color: AppColors.muted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(r.text,
              style: AppTheme.body(14, color: AppColors.ink2, height: 1.55)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() {
              _liked = !_liked;
              _likes += _liked ? 1 : -1;
            }),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_liked ? Icons.favorite : Icons.favorite_border,
                    size: 15,
                    color: _liked ? AppColors.primary : AppColors.muted),
                const SizedBox(width: 6),
                Text('Helpful · $_likes',
                    style: AppTheme.body(12.5,
                        weight: FontWeight.w700,
                        color: _liked ? AppColors.primary : AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
