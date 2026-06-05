/// A listing category (Attractions, Restaurants, Hotels, Events).
/// Mirrors the `categories` table in the Supabase schema.
class Category {
  final String id;
  final String name;
  final String icon; // design icon-name string
  final double hue; // duotone hue for placeholder imagery

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.hue,
  });

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        name: m['name'] as String,
        icon: (m['icon'] ?? 'landmark') as String,
        hue: (m['hue'] as num?)?.toDouble() ?? 200,
      );
}
