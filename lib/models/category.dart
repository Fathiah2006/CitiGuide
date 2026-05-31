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
}
