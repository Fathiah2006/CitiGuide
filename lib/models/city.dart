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
  final String? imageUrl;

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
    this.imageUrl,
  });

  factory City.fromMap(Map<String, dynamic> m, {int places = 0}) => City(
        id: m['id'] as String,
        name: m['name'] as String,
        state: (m['state'] ?? '') as String,
        hue: (m['hue'] as num?)?.toDouble() ?? 200,
        tagline: (m['tagline'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        lat: (m['latitude'] as num?)?.toDouble() ?? 0,
        lng: (m['longitude'] as num?)?.toDouble() ?? 0,
        places: places,
        imageUrl: m['image_url'] as String?,
      );
}
