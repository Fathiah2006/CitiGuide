import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cg_photo.dart';

/// Write-a-review form: tap-to-rate stars + comment field.
class AddReviewScreen extends StatefulWidget {
  final String listingId;
  const AddReviewScreen({super.key, required this.listingId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 0;
  final _text = TextEditingController();

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) return;
    context
        .read<AppState>()
        .addReview(widget.listingId, _rating, _text.text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Review posted · thank you!')));
  }

  @override
  Widget build(BuildContext context) {
    final l = SeedData.listingById(widget.listingId)!;
    final cat = SeedData.catById(l.categoryId)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        titleSpacing: 0,
        title: Text('Write a review', style: AppTheme.title(18.5)),
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: AppColors.line2)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 56,
                        height: 56,
                        child: CgPhoto(
                            hue: l.hue ?? cat.hue,
                            cat: cat.icon,
                            radius: 14)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.name, style: AppTheme.title(16.5)),
                          const SizedBox(height: 2),
                          Text(l.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTheme.body(13, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, color: AppColors.line),
              Center(
                child: Column(
                  children: [
                    Text('How was your visit?',
                        style: AppTheme.body(15, weight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final n = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = n),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 40,
                              color: _rating >= n
                                  ? AppColors.star
                                  : const Color(0xFFE2E7EB),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 20,
                      child: Text(_labels[_rating],
                          style: AppTheme.body(15,
                              weight: FontWeight.w700, color: AppColors.star)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: TextField(
                  controller: _text,
                  maxLines: 5,
                  cursorColor: AppColors.primary,
                  style: AppTheme.body(15, height: 1.5),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText:
                        'Share details of your experience — what stood out?',
                    hintStyle: AppTheme.body(15, color: AppColors.muted2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo picker (demo)'))),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.line,
                        width: 1.5,
                        style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 7),
                      Text('Add photos',
                          style: AppTheme.body(13.5,
                              weight: FontWeight.w700,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
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
                  label: 'Post review',
                  enabled: _rating > 0,
                  onPressed: _submit),
            ),
          ),
        ],
      ),
    );
  }
}
