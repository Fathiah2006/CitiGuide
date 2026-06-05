import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/listing.dart';
import '../../services/seed_data.dart';
import '../../services/supabase_service.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cg_image.dart';
import 'admin_listing_form.dart';

/// Admin: browse every listing with edit / delete and an add button.
class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen> {
  bool _working = false;

  Future<void> _openForm([Listing? listing]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminListingForm(listing: listing)),
    );
    if (saved == true && mounted) {
      await context.read<AppState>().refreshCatalog();
      setState(() {});
    }
  }

  Future<void> _delete(Listing l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('“${l.name}” will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _working = true);
    try {
      await SupabaseService.instance.deleteListing(l.id);
      if (mounted) await context.read<AppState>().refreshCatalog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
    if (mounted) setState(() => _working = false);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    final listings = [...SeedData.listings]
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: AppBar(title: Text('Listings', style: AppTheme.title(18.5))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add listing',
            style: AppTheme.body(15, weight: FontWeight.w700, color: Colors.white)),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final l = listings[i];
              final cat = SeedData.catById(l.categoryId);
              final city = SeedData.cityById(l.cityId);
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.sh1,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CgImage(
                          imageUrl: l.coverImageUrl,
                          hue: l.hue ?? cat?.hue ?? 200,
                          cat: cat?.icon,
                          radius: 12),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.title(15)),
                          const SizedBox(height: 2),
                          Text('${cat?.name ?? ''} · ${city?.name ?? ''}',
                              style:
                                  AppTheme.body(12.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () => _openForm(l),
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary, size: 20)),
                    IconButton(
                        onPressed: () => _delete(l),
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20)),
                  ],
                ),
              );
            },
          ),
          if (_working)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
