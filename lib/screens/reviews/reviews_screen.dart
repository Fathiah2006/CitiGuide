import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons.dart';
import '../../widgets/rating_summary.dart';
import '../../widgets/review_item.dart';

/// All reviews for a listing, with a sticky "Write a review" CTA.
class ReviewsScreen extends StatelessWidget {
  final String listingId;
  const ReviewsScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l = SeedData.listingById(listingId)!;
    final reviews = app.reviewsFor(l.id);

    void add() =>
        Navigator.of(context).pushNamed(Routes.addReview, arguments: l.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews', style: AppTheme.title(18.5)),
            Text(l.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(12.5, color: AppColors.muted)),
          ],
        ),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.line2)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
            children: [
              RatingSummary(listing: l, onAdd: add),
              const Divider(height: 12, color: AppColors.line),
              for (final r in reviews) ReviewItem(review: r),
            ],
          ),
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
              child: CgButton(
                  label: 'Write a review', icon: Icons.add, onPressed: add),
            ),
          ),
        ],
      ),
    );
  }
}
