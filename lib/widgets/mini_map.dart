import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app/theme.dart';
import '../utils/app_colors.dart';
import 'map_marker.dart';

/// A real OpenStreetMap map (no API key required). Used as a non-interactive
/// preview on the listing detail screen — tapping opens the full map screen.
class MiniMap extends StatelessWidget {
  final double lat;
  final double lng;
  final double height;
  final double radius;
  final VoidCallback? onTap;
  final String? label; // e.g. "Directions" pill in the corner

  const MiniMap({
    super.key,
    required this.lat,
    required this.lng,
    this.height = 150,
    this.radius = 16,
    this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(lat, lng);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The preview ignores pointer events so the parent tap fires.
              IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                    backgroundColor: const Color(0xFFE8EEF1),
                    interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.citiguide.app',
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: center,
                        width: 40,
                        height: 40,
                        child: const MapMarkerPin(),
                      ),
                    ]),
                  ],
                ),
              ),
              if (label != null)
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: AppShadows.sh1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.navigation_outlined,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(label!,
                            style: AppTheme.body(12.5,
                                weight: FontWeight.w700,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
