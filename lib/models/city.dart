/// A city the user can explore. Mirrors the `cities` table.
class City {
  final String id;
  final String name;
  final String state;
  final double hue; // duotone hue for the city hero placeholder
  final String tagline;
  final String description;
  final double lat;
  final double lng;
  final int places;

  const City({
    required this.id,
    required this.name,
    required this.state,
    required this.hue,
    required this.tagline,
    required this.description,
    required this.lat,
    required this.lng,
    required this.places,
  });
}
