import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'cg_photo.dart';

/// Renders a real (network) photo when [imageUrl] is available, falling back to
/// the deterministic [CgPhoto] placeholder while loading or on error. This lets
/// listings/cities show actual imagery while never looking broken.
class CgImage extends StatelessWidget {
  final String? imageUrl;
  final double hue;
  final String? cat; // category glyph for the placeholder fallback
  final double radius;
  final bool dim; // dark gradient at the bottom for overlaid text
  final BoxFit fit;

  const CgImage({
    super.key,
    this.imageUrl,
    this.hue = 200,
    this.cat,
    this.radius = 0,
    this.dim = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = CgPhoto(hue: hue, cat: cat);
    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final Widget base = hasUrl
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 250),
            placeholder: (_, __) => placeholder,
            errorWidget: (_, __, ___) => placeholder,
          )
        : placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          base,
          if (dim)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00081C2A), Color(0x8C081C2A)],
                  stops: [0.38, 1],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
