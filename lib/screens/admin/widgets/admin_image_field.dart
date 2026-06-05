import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme.dart';
import '../../../services/supabase_service.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/cg_image.dart';

/// Pick an image from the gallery and upload it to Supabase Storage, reporting
/// the resulting public URL back via [onChanged].
class AdminImageField extends StatefulWidget {
  final String? initialUrl;
  final String folder; // e.g. 'listings' or 'cities'
  final ValueChanged<String> onChanged;

  const AdminImageField({
    super.key,
    this.initialUrl,
    required this.folder,
    required this.onChanged,
  });

  @override
  State<AdminImageField> createState() => _AdminImageFieldState();
}

class _AdminImageFieldState extends State<AdminImageField> {
  String? _url;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 82);
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final path =
          '${widget.folder}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final url = await SupabaseService.instance.uploadImage(
        path,
        bytes,
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );
      if (!mounted) return;
      setState(() {
        _url = url;
        _busy = false;
      });
      widget.onChanged(url);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cover image',
            style:
                AppTheme.body(13, weight: FontWeight.w600, color: AppColors.ink2)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _busy ? null : _pick,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line, width: 1.5),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CgImage(imageUrl: _url, radius: 16),
                Container(color: const Color(0x33081C2A)),
                Center(
                  child: _busy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_camera_outlined,
                                color: Colors.white, size: 28),
                            const SizedBox(height: 6),
                            Text(_url == null ? 'Upload image' : 'Replace image',
                                style: AppTheme.body(13.5,
                                    weight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
