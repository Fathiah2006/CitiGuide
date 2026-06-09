import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme.dart';
import '../../models/city.dart';
import '../../models/listing.dart';
import '../../services/map_launcher_service.dart';
import '../../services/seed_data.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cg_image.dart';
import '../../widgets/map_marker.dart';

/// Full interactive map (OpenStreetMap, no API key) with a directions card that
/// hands off to Google or Apple Maps for real turn-by-turn navigation.
class MapScreen extends StatefulWidget {
  final String listingId;
  const MapScreen({super.key, required this.listingId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _controller = MapController();
  late final Listing _listing;
  late final City _city;
  late final LatLng _center;

  @override
  void initState() {
    super.initState();
    _listing = SeedData.listingById(widget.listingId)!;
    _city = SeedData.cityById(_listing.cityId)!;
    _center = LatLng(
      _listing.latitude ?? _city.lat,
      _listing.longitude ?? _city.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = SeedData.catById(_listing.categoryId)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F2),
      // SizedBox.expand forces the Stack to fill the screen. Without it the
      // Scaffold gives loose height constraints and the Stack collapses to its
      // only non-positioned child (the top button row), leaving the map ~90px
      // tall with a huge blank area below.
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 14,
                  backgroundColor: const Color(0xFFE8EEF1),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.citiguide.app',
                    tileProvider: NetworkTileProvider(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 44,
                        height: 44,
                        child: const MapMarkerPin(size: 44),
                      ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _WhiteCircle(
                      icon: Icons.arrow_back,
                      color: AppColors.ink,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _WhiteCircle(
                      icon: Icons.my_location,
                      color: AppColors.primary,
                      onTap: () => _controller.move(_center, 15),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 30,
              child: _DirectionsCard(
                listing: _listing,
                cat: cat.name,
                city: _city,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionsCard extends StatelessWidget {
  final Listing listing;
  final String cat;
  final City city;
  const _DirectionsCard({
    required this.listing,
    required this.cat,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final hue = listing.hue ?? SeedData.catById(listing.categoryId)!.hue;
    final lat = listing.latitude ?? city.lat;
    final lng = listing.longitude ?? city.lng;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.sh3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CgImage(
                  imageUrl: listing.coverImageUrl,
                  hue: hue,
                  cat: SeedData.catById(listing.categoryId)!.icon,
                  radius: 14,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.title(16.5),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            listing.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.body(13, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.line2),
                bottom: BorderSide(color: AppColors.line2),
              ),
            ),
            child: Row(
              children: [
                _Stat(
                  icon: Icons.navigation_outlined,
                  value: '12 min',
                  label: 'Driving',
                ),
                _Stat(
                  icon: Icons.place_outlined,
                  value: '4.2 km',
                  label: 'Distance',
                ),
                _Stat(
                  icon: Icons.schedule,
                  value: listing.openNow ? 'Open' : 'Closed',
                  label: 'Status',
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CgButton(
                  label: 'Google Maps',
                  icon: Icons.navigation_outlined,
                  onPressed: () => MapLauncherService.openGoogleMaps(
                    lat,
                    lng,
                    label: listing.name,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CgButton(
                  label: 'Apple Maps',
                  variant: CgButtonVariant.outline,
                  onPressed: () => MapLauncherService.openAppleMaps(
                    lat,
                    lng,
                    label: listing.name,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTheme.body(14, weight: FontWeight.w700)),
              Text(label, style: AppTheme.body(11.5, color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WhiteCircle({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: AppShadows.sh2,
        ),
        child: Icon(icon, size: 21, color: color),
      ),
    );
  }
}
