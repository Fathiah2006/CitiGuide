import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/listing.dart';
import '../../services/seed_data.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cg_chip.dart';
import '../../widgets/cg_photo.dart';
import '../../widgets/cg_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_row.dart';
import '../../widgets/star_rating.dart';

const _sorts = [
  ('rating', 'Top rated'),
  ('reviews', 'Most reviewed'),
  ('name', 'A–Z'),
];

/// Search tab — query, category/rating filters (in a bottom sheet) and sort.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  Set<String> _cats = {};
  double _minR = 0;
  String _sort = 'rating';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _activeFilters => _cats.length + (_minR > 0 ? 1 : 0);

  List<Listing> _results(String cityId) {
    var list = SeedData.byCity(cityId);
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((l) => ('${l.name} ${l.short} ${l.tags.join(' ')}')
              .toLowerCase()
              .contains(q))
          .toList();
    }
    if (_cats.isNotEmpty) {
      list = list.where((l) => _cats.contains(l.categoryId)).toList();
    }
    if (_minR > 0) list = list.where((l) => l.rating >= _minR).toList();
    list.sort((a, b) => switch (_sort) {
          'rating' => b.rating.compareTo(a.rating),
          'reviews' => b.ratingCount.compareTo(a.ratingCount),
          _ => a.name.compareTo(b.name),
        });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final city =
        SeedData.cityById(app.selectedCityId ?? '') ?? SeedData.cities.first;
    final hasQuery = _query.trim().isNotEmpty;
    final results = _results(city.id);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // search bar + filter button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 19, color: AppColors.muted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            cursorColor: AppColors.primary,
                            onChanged: (v) => setState(() => _query = v),
                            style: AppTheme.body(15.5),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Search ${city.name}…',
                              hintStyle:
                                  AppTheme.body(15.5, color: AppColors.muted2),
                            ),
                          ),
                        ),
                        if (hasQuery)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openFilters,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _activeFilters > 0
                          ? AppColors.primary
                          : AppColors.bgAlt2,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.tune,
                            size: 21,
                            color: _activeFilters > 0
                                ? Colors.white
                                : AppColors.ink),
                        if (_activeFilters > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 19),
                              decoration: const BoxDecoration(
                                color: AppColors.coral,
                                shape: BoxShape.circle,
                              ),
                              child: Text('$_activeFilters',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.body(11,
                                      weight: FontWeight.w800,
                                      color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasQuery && _activeFilters == 0
                ? _Suggest(
                    city: city.name,
                    onPick: (q) {
                      _controller.text = q;
                      setState(() => _query = q);
                    },
                    onCat: (id) => setState(() => _cats = {id}),
                  )
                : results.isEmpty
                    ? EmptyState(
                        icon: Icons.search,
                        title: 'No matches',
                        body:
                            'We couldn’t find anything for “$_query” in ${city.name}. Try a different word or clear your filters.',
                        action: TextButton(
                          onPressed: _clear,
                          child: Text('Clear search',
                              style: AppTheme.body(15,
                                  weight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      )
                    : _resultsList(context, app, results),
          ),
        ],
      ),
    );
  }

  Widget _resultsList(
      BuildContext context, AppState app, List<Listing> results) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${results.length} result${results.length > 1 ? 's' : ''}',
                  style: AppTheme.body(13.5,
                      weight: FontWeight.w600, color: AppColors.muted)),
              GestureDetector(
                onTap: _openFilters,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_vert,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(_sorts.firstWhere((s) => s.$1 == _sort).$2,
                        style: AppTheme.body(13.5,
                            weight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final l in results) ...[
          ListingRow(
            listing: l,
            isFav: app.isFavourite(l.id),
            onFav: () => app.toggleFavourite(l.id),
            onOpen: () => Navigator.of(context)
                .pushNamed(Routes.details, arguments: l.id),
          ),
          const Divider(height: 9, color: AppColors.line),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _cats = {};
      _minR = 0;
    });
  }

  Future<void> _openFilters() async {
    // local working copy
    var cats = {..._cats};
    var minR = _minR;
    var sort = _sort;
    await showCgBottomSheet(
      context: context,
      title: 'Filters',
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            Widget chips() => Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: SeedData.categories
                      .map((c) => CgChip(
                            label: c.name,
                            active: cats.contains(c.id),
                            onTap: () => setSheet(() => cats.contains(c.id)
                                ? cats.remove(c.id)
                                : cats.add(c.id)),
                          ))
                      .toList(),
                );

            Widget ratingChips() => Row(
                  children: [for (final r in [0.0, 3.0, 4.0, 4.5])
                    Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: GestureDetector(
                        onTap: () => setSheet(() => minR = r),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: minR == r ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                color: minR == r
                                    ? AppColors.primary
                                    : AppColors.line,
                                width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: r == 0
                                ? [
                                    Text('Any',
                                        style: AppTheme.body(13.5,
                                            weight: FontWeight.w600,
                                            color: minR == r
                                                ? Colors.white
                                                : AppColors.ink2))
                                  ]
                                : [
                                    StarSolid(
                                        size: 13,
                                        color: minR == r
                                            ? Colors.white
                                            : AppColors.star),
                                    const SizedBox(width: 4),
                                    Text('$r+',
                                        style: AppTheme.body(13.5,
                                            weight: FontWeight.w600,
                                            color: minR == r
                                                ? Colors.white
                                                : AppColors.ink2)),
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 11, top: 8),
                  child: Text('Category', style: AppTheme.title(13.5)),
                ),
                chips(),
                const SizedBox(height: 24),
                Text('Minimum rating', style: AppTheme.title(13.5)),
                const SizedBox(height: 11),
                ratingChips(),
                const SizedBox(height: 24),
                Text('Sort by', style: AppTheme.title(13.5)),
                const SizedBox(height: 6),
                for (final s in _sorts)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setSheet(() => sort = s.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.$2,
                              style: AppTheme.body(15,
                                  weight: FontWeight.w600)),
                          if (sort == s.$1)
                            const Icon(Icons.check,
                                size: 20, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheet(() {
                          cats = {};
                          minR = 0;
                          sort = 'rating';
                        }),
                        child: Container(
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.bgAlt2,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('Clear all',
                              style: AppTheme.body(16,
                                  weight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Navigator.of(sheetContext).pop(true),
                        child: Container(
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text('Show results',
                              style: AppTheme.body(16,
                                  weight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
    // commit working copy
    setState(() {
      _cats = cats;
      _minR = minR;
      _sort = sort;
    });
  }
}

class _Suggest extends StatelessWidget {
  final String city;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onCat;
  const _Suggest(
      {required this.city, required this.onPick, required this.onCat});

  @override
  Widget build(BuildContext context) {
    const recents = ['Museum', 'Jollof', 'Pool', 'Carnival'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        Text('Recent searches',
            style: AppTheme.body(13,
                weight: FontWeight.w700, color: AppColors.ink2)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: recents
              .map((r) => CgChip(
                  label: r, icon: Icons.search, onTap: () => onPick(r)))
              .toList(),
        ),
        const SizedBox(height: 26),
        Text('Browse by category',
            style: AppTheme.body(13,
                weight: FontWeight.w700, color: AppColors.ink2)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.85,
          children: SeedData.categories
              .map((c) => GestureDetector(
                    onTap: () => onCat(c.id),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CgPhoto(hue: c.hue, cat: c.icon, dim: true, radius: 16),
                        Positioned(
                          left: 14,
                          bottom: 12,
                          child: Text(c.name,
                              style: AppTheme.body(15.5,
                                  weight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
