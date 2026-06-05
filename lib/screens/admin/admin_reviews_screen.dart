import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/star_rating.dart';

/// Admin: moderate recent reviews and remove inappropriate ones.
class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.fetchAllReviews();
  }

  void _reload() =>
      setState(() => _future = SupabaseService.instance.fetchAllReviews());

  Future<void> _delete(String id) async {
    try {
      await SupabaseService.instance.deleteReview(id);
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: AppBar(title: Text('Reviews', style: AppTheme.title(18.5))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Couldn’t load reviews',
              body: '${snap.error}',
            );
          }
          final rows = snap.data ?? [];
          if (rows.isEmpty) {
            return const EmptyState(
              icon: Icons.reviews_outlined,
              title: 'No reviews yet',
              body: 'Reviews posted by users will appear here for moderation.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = rows[i];
              final listingName =
                  (r['listings'] as Map?)?['name'] as String? ?? 'Listing';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.sh1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((r['author_name'] ?? 'A user') as String,
                                  style: AppTheme.body(14.5,
                                      weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(listingName,
                                  style: AppTheme.body(12.5,
                                      color: AppColors.primary300,
                                      weight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        StarRow(
                            value: ((r['rating'] as num?)?.toDouble() ?? 0),
                            size: 13),
                        IconButton(
                          onPressed: () => _delete(r['id'] as String),
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.danger, size: 20),
                        ),
                      ],
                    ),
                    if ((r['comment'] ?? '').toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(r['comment'] as String,
                            style: AppTheme.body(13.5,
                                color: AppColors.ink2, height: 1.5)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
