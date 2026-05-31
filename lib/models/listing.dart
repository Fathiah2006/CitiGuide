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
  });
}
