import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'star_rating.dart';

/// The CitiGuide map pin — a navy teardrop with a star, used on all maps.
class MapMarkerPin extends StatelessWidget {
  final double size;
  const MapMarkerPin({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -size / 2),
      child: Transform.rotate(
        angle: -0.785398, // -45°
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size / 2),
              topRight: Radius.circular(size / 2),
              bottomLeft: Radius.circular(size / 2),
            ),
            boxShadow: AppShadows.sh2,
          ),
          child: Transform.rotate(
            angle: 0.785398,
            child: Center(child: StarSolid(size: size * 0.42, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
