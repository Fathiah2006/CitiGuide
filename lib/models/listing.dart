/// An attraction / restaurant / hotel / event. Mirrors the `listings` table.
class Listing {
  final String id;
  final String cityId;
  final String categoryId;
  final String name;
  final double rating;
  final int ratingCount;
  final String short;
  final String description;
  final String address;
  final String phone;
  final String website;
  final String hours;
  final bool openNow;
  final String price; // e.g. ₦₦ , 'Free' , ''
  final bool featured;
  final int images;
  final double? hue; // overrides category hue when set
  final List<String> tags;
  final String? coverImageUrl;

  const Listing({
    required this.id,
    required this.cityId,
    required this.categoryId,
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.short,
    required this.description,
    required this.address,
    required this.phone,
    required this.website,
    required this.hours,
    required this.openNow,
    required this.price,
    required this.featured,
    required this.images,
    required this.hue,
    required this.tags,
    this.coverImageUrl,
  });

  factory Listing.fromMap(Map<String, dynamic> m) => Listing(
        id: m['id'] as String,
        cityId: m['city_id'] as String,
        categoryId: m['category_id'] as String,
        name: m['name'] as String,
        rating: (m['rating_average'] as num?)?.toDouble() ?? 0,
        ratingCount: (m['rating_count'] as num?)?.toInt() ?? 0,
        short: (m['short_description'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        address: (m['address'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        website: (m['website_url'] ?? '') as String,
        hours: (m['opening_hours'] ?? '') as String,
        openNow: (m['open_now'] ?? true) as bool,
        price: (m['price'] ?? '') as String,
        featured: (m['is_featured'] ?? false) as bool,
        images: 3,
        hue: (m['hue'] as num?)?.toDouble(),
        tags: ((m['tags'] as List?)?.cast<String>()) ?? const [],
        coverImageUrl: m['cover_image_url'] as String?,
      );
}
