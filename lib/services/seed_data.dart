import '../models/category.dart';
import '../models/city.dart';
import '../models/listing.dart';
import '../models/profile.dart';
import '../models/review.dart';

/// In-memory seed dataset (Nigerian cities) ported from the design's
/// `data.jsx`. This stands in for the Supabase backend so the app is fully
/// functional offline; the public API here mirrors what a `SupabaseService`
/// would expose, making a later swap straightforward.
class SeedData {
  SeedData._();

  // Mutable catalogue — defaults to the bundled seed, but can be replaced at
  // runtime by data fetched from Supabase via [hydrate]. Screens read these
  // synchronously, so the live backend simply swaps the contents in place.
  static List<Category> categories = _seedCategories;
  static List<City> cities = _seedCities;

  static const List<Category> _seedCategories = [
    Category(id: 'attractions', name: 'Attractions', icon: 'landmark', hue: 188),
    Category(id: 'restaurants', name: 'Restaurants', icon: 'utensils', hue: 28),
    Category(id: 'hotels', name: 'Hotels', icon: 'bed', hue: 214),
    Category(id: 'events', name: 'Events', icon: 'ticket', hue: 280),
  ];

  static const List<City> _seedCities = [
    City(
      id: 'benin',
      name: 'Benin City',
      state: 'Edo State',
      hue: 168,
      tagline: 'Ancient kingdom of bronze & brotherhood',
      description:
          'The historic heart of the Benin Kingdom — home to world-famous bronze casting, the Oba’s royal palace and centuries of living heritage.',
      lat: 6.34,
      lng: 5.62,
      places: 7,
      imageUrl: 'https://loremflickr.com/800/600/benin,city?lock=11',
    ),
    City(
      id: 'ph',
      name: 'Port Harcourt',
      state: 'Rivers State',
      hue: 200,
      tagline: 'The Garden City on the Bonny River',
      description:
          'A lively riverside city known for its parks, pepper-soup joints and the colourful Carniriv carnival.',
      lat: 4.81,
      lng: 7.04,
      places: 6,
      imageUrl: 'https://loremflickr.com/800/600/river,city?lock=12',
    ),
    City(
      id: 'lagos',
      name: 'Lagos',
      state: 'Lagos State',
      hue: 32,
      tagline: 'Nigeria’s restless creative capital',
      description:
          'Beaches, art galleries and a nightlife that never sleeps — the cultural engine of West Africa.',
      lat: 6.45,
      lng: 3.39,
      places: 6,
      imageUrl: 'https://loremflickr.com/800/600/lagos,city?lock=13',
    ),
    City(
      id: 'abuja',
      name: 'Abuja',
      state: 'FCT',
      hue: 256,
      tagline: 'The green & orderly capital',
      description:
          'Planned, leafy and calm — rock formations, lakeside parks and modern dining beneath Aso Rock.',
      lat: 9.07,
      lng: 7.49,
      places: 5,
      imageUrl: 'https://loremflickr.com/800/600/abuja,city?lock=14',
    ),
  ];

  // Running index used to mirror the design's generated phone numbers.
  static int _seq = 0;

  /// Terse listing builder mirroring the design's `L()` helper, applying the
  /// same generated defaults (phone, website, description, hours).
  static Listing _l(
    String city,
    String cat,
    String name,
    double rating,
    int count,
    String short, {
    bool featured = false,
    String address = '',
    String? phone,
    String? website,
    String hours = 'Open · 9:00 AM – 10:00 PM',
    bool openNow = true,
    String price = '',
    String? desc,
    int images = 3,
    double? hue,
    List<String> tags = const [],
  }) {
    _seq++;
    final genPhone =
        '+234 80${(1000000 + _seq * 13337).toString().substring(0, 7)}';
    final genSite = '${name.toLowerCase().replaceAll(RegExp(r'[^a-z]+'), '')}.ng';
    const kw = {
      'attractions': 'landmark,monument',
      'restaurants': 'restaurant,food',
      'hotels': 'hotel,room',
      'events': 'festival,concert',
    };
    final coverImageUrl =
        'https://loremflickr.com/800/600/${kw[cat] ?? 'city'}?lock=${100 + _seq}';
    return Listing(
      id: 'l$_seq',
      cityId: city,
      categoryId: cat,
      name: name,
      rating: rating,
      ratingCount: count,
      short: short,
      description: desc ??
          '$short A favourite among locals and visitors alike, offering a genuine taste of the city’s character and warm hospitality.',
      address: address,
      phone: phone ?? genPhone,
      website: website ?? genSite,
      hours: hours,
      openNow: openNow,
      price: price,
      featured: featured,
      images: images,
      hue: hue,
      tags: tags,
      coverImageUrl: coverImageUrl,
    );
  }

  static List<Listing> listings = _buildListings();

  /// Replace the in-memory catalogue with data loaded from the backend.
  static void hydrate({
    List<Category>? categories,
    List<City>? cities,
    List<Listing>? listings,
  }) {
    if (categories != null && categories.isNotEmpty) {
      SeedData.categories = categories;
    }
    if (cities != null && cities.isNotEmpty) SeedData.cities = cities;
    if (listings != null) SeedData.listings = listings;
  }

  static List<Listing> _buildListings() {
    _seq = 0;
    return [
      // ── Benin City ──
      _l('benin', 'attractions', 'Benin National Museum', 4.6, 312,
          'Bronze plaques, ivory masks & royal regalia in Ring Road.',
          featured: true,
          address: 'Ring Road, Benin City',
          hours: 'Open · 9:00 AM – 5:00 PM',
          tags: ['History', 'Art', 'Family']),
      _l('benin', 'attractions', 'Oba’s Palace', 4.8, 540,
          'The living seat of the Benin monarchy and its court arts.',
          featured: true,
          address: 'Palace Road, Benin City',
          tags: ['Heritage', 'Guided tour']),
      _l('benin', 'attractions', 'Igun Bronze Casters Street', 4.5, 176,
          'A UNESCO-listed street where bronze is still cast by hand.',
          address: 'Igun Street, Benin City',
          hours: 'Open · 8:00 AM – 6:00 PM',
          tags: ['Craft', 'Shopping']),
      _l('benin', 'restaurants', 'Uyi Grand Kitchen', 4.4, 220,
          'Rich Edo black soup & pounded yam done right.',
          price: '₦₦',
          address: 'Sapele Road, Benin City',
          tags: ['Local', 'Dine-in']),
      _l('benin', 'restaurants', 'Royal Palms Bistro', 4.3, 98,
          'Garden dining with grills, jollof and chilled palm wine.',
          price: '₦₦',
          address: 'GRA, Benin City',
          tags: ['Outdoor', 'Bar']),
      _l('benin', 'hotels', 'Randekhi Royal Hotel', 4.5, 410,
          'Polished rooms, pool and conference suites in the GRA.',
          price: '₦₦₦',
          address: 'Ihama Road, GRA, Benin City',
          hours: 'Reception · 24 hours',
          featured: true,
          tags: ['Pool', 'Wi-Fi']),
      _l('benin', 'events', 'Igue Festival', 4.9, 89,
          'The royal renewal festival of the Benin Kingdom, every December.',
          hours: 'Dec 18 – Dec 27 · Annual',
          address: 'Oba’s Palace grounds',
          price: 'Free',
          tags: ['Culture', 'Annual']),

      // ── Port Harcourt ──
      _l('ph', 'attractions', 'Port Harcourt Pleasure Park', 4.4, 388,
          'Fountains, rides and lawns along the waterfront.',
          featured: true,
          address: 'Aba Road, Port Harcourt',
          tags: ['Family', 'Outdoor']),
      _l('ph', 'attractions', 'Isaac Boro Park', 4.1, 142,
          'Central green space and city landmark for an easy stroll.',
          address: 'Station Road, Port Harcourt',
          price: 'Free',
          tags: ['Park', 'Relax']),
      _l('ph', 'restaurants', 'Kilimanjaro PH', 4.2, 256,
          'Fast, fresh jollof, grilled chicken and meat pies.',
          price: '₦₦',
          address: 'Olu Obasanjo Rd, Port Harcourt',
          tags: ['Quick', 'Local']),
      _l('ph', 'restaurants', 'Cilantro Restaurant', 4.6, 174,
          'Upscale continental plates with a river view.',
          price: '₦₦₦',
          address: 'Aba Road, Port Harcourt',
          featured: true,
          tags: ['Fine dining']),
      _l('ph', 'hotels', 'Hotel Presidential', 4.0, 520,
          'A storied Garden City landmark with gardens & pool.',
          price: '₦₦₦',
          address: 'Aba Road, Port Harcourt',
          hours: 'Reception · 24 hours',
          tags: ['Pool', 'Classic']),
      _l('ph', 'events', 'Carniriv Carnival', 4.8, 64,
          'Rivers State’s riot of colour, music and masquerade.',
          hours: 'Dec · Annual',
          address: 'City-wide, Port Harcourt',
          price: 'Free',
          featured: true,
          tags: ['Carnival', 'Music']),

      // ── Lagos ──
      _l('lagos', 'attractions', 'Lekki Conservation Centre', 4.7, 980,
          'Canopy walkway and wildlife over coastal wetland.',
          featured: true,
          address: 'Lekki-Epe Expressway, Lagos',
          tags: ['Nature', 'Adventure']),
      _l('lagos', 'attractions', 'Nike Art Gallery', 4.6, 612,
          'Five floors of contemporary Nigerian art & textiles.',
          address: 'Lekki Phase 1, Lagos',
          price: 'Free',
          tags: ['Art', 'Culture']),
      _l('lagos', 'restaurants', 'Terra Kulture', 4.5, 430,
          'Nigerian cuisine, theatre and art under one roof.',
          price: '₦₦₦',
          address: 'Victoria Island, Lagos',
          featured: true,
          tags: ['Culture', 'Dine-in']),
      _l('lagos', 'restaurants', 'RSVP Lagos', 4.4, 358,
          'Chic rooftop dining and cocktails in VI.',
          price: '₦₦₦₦',
          address: 'Victoria Island, Lagos',
          tags: ['Rooftop', 'Bar']),
      _l('lagos', 'hotels', 'Eko Hotel & Suites', 4.3, 1240,
          'Lagoon-side icon with pools, spa and convention halls.',
          price: '₦₦₦₦',
          address: 'Victoria Island, Lagos',
          hours: 'Reception · 24 hours',
          featured: true,
          tags: ['Pool', 'Spa']),
      _l('lagos', 'events', 'Lagos Jazz Series', 4.6, 120,
          'Open-air evenings of jazz, soul and afrobeat.',
          hours: 'Apr · Annual',
          address: 'Muri Okunola Park, Lagos',
          price: '₦₦',
          tags: ['Music', 'Nightlife']),

      // ── Abuja ──
      _l('abuja', 'attractions', 'Millennium Park', 4.5, 470,
          'Abuja’s largest park — lawns, fountains and river.',
          featured: true,
          address: 'Maitama, Abuja',
          price: 'Free',
          tags: ['Park', 'Family']),
      _l('abuja', 'attractions', 'Jabi Lake & Boardwalk', 4.4, 388,
          'Lakeside boardwalk, boats and waterfront cafés.',
          address: 'Jabi, Abuja',
          tags: ['Lake', 'Relax']),
      _l('abuja', 'attractions', 'Zuma Rock Viewpoint', 4.7, 210,
          'The monolithic “Gateway to Abuja” at Niger State edge.',
          address: 'Madalla, near Abuja',
          price: 'Free',
          tags: ['Nature', 'Photo']),
      _l('abuja', 'restaurants', 'Wakkis', 4.5, 296,
          'Beloved North-Indian spot — rich curries and naan.',
          price: '₦₦₦',
          address: 'Wuse 2, Abuja',
          featured: true,
          tags: ['Indian', 'Dine-in']),
      _l('abuja', 'hotels', 'Transcorp Hilton Abuja', 4.4, 1560,
          'The capital’s flagship hotel — pools, spa & dining.',
          price: '₦₦₦₦',
          address: 'Maitama, Abuja',
          hours: 'Reception · 24 hours',
          featured: true,
          tags: ['Pool', 'Spa', 'Wi-Fi']),
    ];
  }

  /// Hand-seeded reviews keyed by listing id; other listings fall back to
  /// deterministically generated reviews (see [reviewsFor]).
  static const Map<String, List<Review>> _seeded = {
    'l1': [
      Review(
          user: 'Adaeze O.',
          rating: 5,
          date: '2 weeks ago',
          likes: 14,
          liked: false,
          text:
              'Incredible collection of bronzes. The guide was so knowledgeable about the kingdom’s history — worth every minute.'),
      Review(
          user: 'Tunde A.',
          rating: 4,
          date: '1 month ago',
          likes: 6,
          liked: false,
          text:
              'Fascinating exhibits. Wish the building was a little cooler inside, but the artefacts make up for it.'),
    ],
    'l2': [
      Review(
          user: 'Ngozi E.',
          rating: 5,
          date: '5 days ago',
          likes: 22,
          liked: true,
          text:
              'A profound experience. Seeing the court art in its living context is unlike any museum.'),
      Review(
          user: 'David M.',
          rating: 5,
          date: '3 weeks ago',
          likes: 9,
          liked: false,
          text:
              'Book the guided tour — the storytelling brings 600 years of history alive.'),
    ],
  };

  static const Profile defaultProfile = Profile(
    name: 'Amara Okonkwo',
    email: 'amara.okonkwo@gmail.com',
    phone: '+234 803 114 2200',
    joined: 'Joined March 2025',
  );

  // ── lightweight data helpers ──
  static Category? catById(String id) =>
      categories.where((c) => c.id == id).firstOrNull;

  static City? cityById(String id) =>
      cities.where((c) => c.id == id).firstOrNull;

  static Listing? listingById(String id) =>
      listings.where((l) => l.id == id).firstOrNull;

  static List<Listing> byCity(String cityId) =>
      listings.where((l) => l.cityId == cityId).toList();

  /// Deterministic reviews so every listing has some, matching the design.
  static List<Review> reviewsFor(String id) {
    final seeded = _seeded[id];
    if (seeded != null) return seeded;
    const names = ['Chidi N.', 'Funke B.', 'Emeka I.', 'Sade A.', 'Ibrahim K.', 'Grace U.'];
    const texts = [
      'Lovely spot — exactly what the city is about. Will definitely return.',
      'Good value and friendly staff. A solid choice for first-timers.',
      'Really enjoyed our visit. Got a bit busy in the afternoon, so go early.',
      'Clean, well-run and easy to find. Recommended.',
    ];
    const dates = ['1 week ago', '2 weeks ago', 'last month'];
    final seed = id.length > 1 ? id.codeUnitAt(1) : 3;
    return [0, 1].map((i) {
      return Review(
        user: names[(seed + i) % names.length],
        rating: 5 - ((seed + i) % 2),
        date: dates[(seed + i) % 3],
        likes: 2 + ((seed * (i + 2)) % 11),
        liked: false,
        text: texts[(seed + i) % texts.length],
      );
    }).toList();
  }
}
