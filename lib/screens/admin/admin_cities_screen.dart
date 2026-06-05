import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../models/city.dart';
import '../../services/seed_data.dart';
import '../../services/supabase_service.dart';
import '../../state/app_state.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cg_image.dart';
import 'widgets/admin_image_field.dart';

/// Admin: manage the list of cities.
class AdminCitiesScreen extends StatefulWidget {
  const AdminCitiesScreen({super.key});

  @override
  State<AdminCitiesScreen> createState() => _AdminCitiesScreenState();
}

class _AdminCitiesScreenState extends State<AdminCitiesScreen> {
  Future<void> _openForm([City? city]) async {
    final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => _CityForm(city: city)));
    if (saved == true && mounted) {
      await context.read<AppState>().refreshCatalog();
      setState(() {});
    }
  }

  Future<void> _delete(City c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete city?'),
        content: Text('“${c.name}” and its listings will be removed.'),
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
    try {
      await SupabaseService.instance.deleteCity(c.id);
      if (mounted) await context.read<AppState>().refreshCatalog();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.bgAlt,
      appBar: AppBar(title: Text('Cities', style: AppTheme.title(18.5))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add city',
            style: AppTheme.body(15, weight: FontWeight.w700, color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        itemCount: SeedData.cities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = SeedData.cities[i];
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
                        imageUrl: c.imageUrl, hue: c.hue, radius: 12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: AppTheme.title(15)),
                      const SizedBox(height: 2),
                      Text('${c.state} · ${c.places} places',
                          style: AppTheme.body(12.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () => _openForm(c),
                    icon: const Icon(Icons.edit_outlined,
                        color: AppColors.primary, size: 20)),
                IconButton(
                    onPressed: () => _delete(c),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger, size: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CityForm extends StatefulWidget {
  final City? city;
  const _CityForm({this.city});

  @override
  State<_CityForm> createState() => _CityFormState();
}

class _CityFormState extends State<_CityForm> {
  late final TextEditingController _name;
  late final TextEditingController _state;
  late final TextEditingController _tagline;
  late final TextEditingController _desc;
  String? _imageUrl;
  bool _busy = false;

  bool get _isEdit => widget.city != null;

  @override
  void initState() {
    super.initState();
    final c = widget.city;
    _name = TextEditingController(text: c?.name ?? '');
    _state = TextEditingController(text: c?.state ?? '');
    _tagline = TextEditingController(text: c?.tagline ?? '');
    _desc = TextEditingController(text: c?.description ?? '');
    _imageUrl = c?.imageUrl;
  }

  @override
  void dispose() {
    for (final c in [_name, _state, _tagline, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  String _slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'state': _state.text.trim(),
      'tagline': _tagline.text.trim(),
      'description': _desc.text.trim(),
      'image_url': _imageUrl,
      'is_active': true,
    };
    if (_isEdit) {
      data['id'] = widget.city!.id;
    } else {
      data['slug'] =
          '${_slugify(_name.text)}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    }
    try {
      await SupabaseService.instance.upsertCity(data);
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit city' : 'New city',
              style: AppTheme.title(18.5))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          AdminImageField(
              initialUrl: _imageUrl,
              folder: 'cities',
              onChanged: (u) => _imageUrl = u),
          const SizedBox(height: 16),
          AppTextField(label: 'Name', controller: _name),
          const SizedBox(height: 16),
          AppTextField(label: 'State', controller: _state),
          const SizedBox(height: 16),
          AppTextField(label: 'Tagline', controller: _tagline),
          const SizedBox(height: 16),
          AppTextField(label: 'Description', controller: _desc),
          const SizedBox(height: 24),
          CgButton(
              label: _busy ? 'Saving…' : (_isEdit ? 'Save changes' : 'Create city'),
              enabled: !_busy,
              onPressed: _save),
        ],
      ),
    );
  }
}
