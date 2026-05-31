import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_row.dart';

/// Saved tab — lists the user's favourite places, with an empty state.
class FavouritesScreen extends StatelessWidget {
  final VoidCallback onBrowse;
  const FavouritesScreen({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.favouriteListings;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saved', style: AppTheme.display(30)),
                const SizedBox(height: 4),
                Text(
                    list.isEmpty
                        ? 'Your favourite places, in one spot'
                        : '${list.length} place${list.length > 1 ? 's' : ''} you love',
                    style: AppTheme.body(14.5, color: AppColors.muted)),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.favorite_border,
                    title: 'No favourites yet',
                    body:
                        'Tap the heart on any place to save it here for quick access later.',
                    action: CgButton(
                        label: 'Explore places', onPressed: onBrowse),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                    children: [
                      for (final l in list) ...[
                        ListingRow(
                          listing: l,
                          isFav: true,
                          onFav: () => app.toggleFavourite(l.id),
                          onOpen: () => Navigator.of(context)
                              .pushNamed(Routes.details, arguments: l.id),
                        ),
                        const Divider(height: 9, color: AppColors.line),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
