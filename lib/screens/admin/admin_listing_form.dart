import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/listing.dart';
import '../../services/seed_data.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/buttons.dart';
import '../../widgets/toggle_switch.dart';
import 'widgets/admin_image_field.dart';

/// Create or edit a listing. When [listing] is null this is a "new" form.
class AdminListingForm extends StatefulWidget {
  final Listing? listing;
  const AdminListingForm({super.key, this.listing});

  @override
  State<AdminListingForm> createState() => _AdminListingFormState();
}

class _AdminListingFormState extends State<AdminListingForm> {
  late final TextEditingController _name;
  late final TextEditingController _short;
  late final TextEditingController _desc;
  late final TextEditingController _address;
  late final TextEditingController _price;
  late final TextEditingController _hours;
  late final TextEditingController _tags;
  late String _cityId;
  late String _categoryId;
  late bool _featured;
  late bool _openNow;
  String? _coverUrl;
  bool _busy = false;

  bool get _isEdit => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _name = TextEditingController(text: l?.name ?? '');
    _short = TextEditingController(text: l?.short ?? '');
    _desc = TextEditingController(text: l?.description ?? '');
    _address = TextEditingController(text: l?.address ?? '');
    _price = TextEditingController(text: l?.price ?? '');
    _hours = TextEditingController(
        text: l?.hours ?? 'Open · 9:00 AM – 10:00 PM');
    _tags = TextEditingController(text: l?.tags.join(', ') ?? '');
    _cityId = l?.cityId ?? SeedData.cities.first.id;
    _categoryId = l?.categoryId ?? SeedData.categories.first.id;
    _featured = l?.featured ?? false;
    _openNow = l?.openNow ?? true;
    _coverUrl = l?.coverImageUrl;
  }

  @override
  void dispose() {
    for (final c in [_name, _short, _desc, _address, _price, _hours, _tags]) {
      c.dispose();
    }
    super.dispose();
  }

  String _slugify(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'(^-|-$)'), '');

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'city_id': _cityId,
      'category_id': _categoryId,
      'short_description': _short.text.trim(),
      'description': _desc.text.trim(),
      'address': _address.text.trim(),
      'price': _price.text.trim(),
      'opening_hours': _hours.text.trim(),
      'is_featured': _featured,
      'open_now': _openNow,
      'tags': tags,
      'cover_image_url': _coverUrl,
      'is_active': true,
    };
    if (_isEdit) {
      data['id'] = widget.listing!.id;
    } else {
      data['slug'] =
          '${_slugify(_name.text)}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    }

    try {
      await SupabaseService.instance.upsertListing(data);
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
        title: Text(_isEdit ? 'Edit listing' : 'New listing',
            style: AppTheme.title(18.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          AdminImageField(
              initialUrl: _coverUrl,
              folder: 'listings',
              onChanged: (u) => _coverUrl = u),
          const SizedBox(height: 16),
          AppTextField(label: 'Name', controller: _name),
          const SizedBox(height: 16),
          _dropdown(
              'City',
              _cityId,
              {for (final c in SeedData.cities) c.id: c.name},
              (v) => setState(() => _cityId = v)),
          const SizedBox(height: 16),
          _dropdown(
              'Category',
              _categoryId,
              {for (final c in SeedData.categories) c.id: c.name},
              (v) => setState(() => _categoryId = v)),
          const SizedBox(height: 16),
          AppTextField(label: 'Short description', controller: _short),
          const SizedBox(height: 16),
          AppTextField(label: 'Full description', controller: _desc),
          const SizedBox(height: 16),
          AppTextField(label: 'Address', controller: _address),
          const SizedBox(height: 16),
          AppTextField(
              label: 'Price (e.g. ₦₦, Free)', controller: _price),
          const SizedBox(height: 16),
          AppTextField(label: 'Opening hours', controller: _hours),
          const SizedBox(height: 16),
          AppTextField(
              label: 'Tags (comma separated)', controller: _tags),
          const SizedBox(height: 18),
          _switchRow('Featured', _featured, (v) => setState(() => _featured = v)),
          const Divider(color: AppColors.line2),
          _switchRow('Open now', _openNow, (v) => setState(() => _openNow = v)),
          const SizedBox(height: 24),
          CgButton(
              label: _busy ? 'Saving…' : (_isEdit ? 'Save changes' : 'Create listing'),
              enabled: !_busy,
              onPressed: _save),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String value, Map<String, String> options,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTheme.body(13,
                weight: FontWeight.w600, color: AppColors.ink2)),
        const SizedBox(height: 8),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.containsKey(value) ? value : options.keys.first,
              isExpanded: true,
              items: options.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: AppTheme.body(15.5))))
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: AppTheme.body(15, weight: FontWeight.w600))),
          ToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
