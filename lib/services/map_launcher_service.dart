import 'package:url_launcher/url_launcher.dart';

/// Launches external apps for directions, calls and websites. For the MVP we
/// hand off to the device's map app rather than building custom navigation.
class MapLauncherService {
  MapLauncherService._();

  /// Open turn-by-turn directions to [lat],[lng] in Google Maps.
  static Future<bool> openGoogleMaps(double lat, double lng,
      {String? label}) {
    final query = label != null ? Uri.encodeComponent(label) : '$lat,$lng';
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$query');
    return _launch(uri);
  }

  /// Open the location in Apple Maps.
  static Future<bool> openAppleMaps(double lat, double lng, {String? label}) {
    final q = label != null ? '&q=${Uri.encodeComponent(label)}' : '';
    final uri = Uri.parse('https://maps.apple.com/?daddr=$lat,$lng$q');
    return _launch(uri);
  }

  static Future<bool> dial(String phone) =>
      _launch(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  static Future<bool> openWebsite(String url) {
    final normalised = url.startsWith('http') ? url : 'https://$url';
    return _launch(Uri.parse(normalised));
  }

  static Future<bool> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
