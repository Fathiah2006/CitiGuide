import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/category.dart';
import '../models/city.dart';
import '../models/listing.dart';
import '../models/profile.dart';
import '../models/review.dart';

/// All Supabase access lives here. The rest of the app talks to this service
/// (or to [SeedData] when Supabase isn't configured), so the data source is a
/// single, swappable seam.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  static bool _ready = false;

  SupabaseClient get _db => Supabase.instance.client;

  /// Initialise the SDK. Returns false (and no-ops) when not configured.
  static Future<bool> initialize() async {
    if (!SupabaseConfig.isConfigured) return false;
    // The classic JWT "anon public" key (what users copy from the dashboard)
    // is accepted by anonKey; keep it for compatibility with existing projects.
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
    );
    _ready = true;
    return true;
  }

  /// True only when configured AND successfully initialised — so code paths
  /// that never called [initialize] (e.g. widget tests) fall back to seed data
  /// instead of touching an uninitialised client.
  bool get enabled => SupabaseConfig.isConfigured && _ready;

  // ── auth ──────────────────────────────────────────────────────────────────
  Session? get session => _db.auth.currentSession;
  bool get isSignedIn => session != null;
  String? get userId => _db.auth.currentUser?.id;
  String? get userEmail => _db.auth.currentUser?.email;

  Future<void> signUp(String name, String email, String password) async {
    await _db.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
    // With email confirmation disabled, a session is returned immediately.
  }

  Future<void> signIn(String email, String password) =>
      _db.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _db.auth.signOut();

  // ── password reset (OTP code flow) ──
  /// Sends a recovery email. With the dashboard template including
  /// `{{ .Token }}`, the user receives a 6-digit code.
  Future<void> sendPasswordResetCode(String email) =>
      _db.auth.resetPasswordForEmail(email);

  /// Verifies the 6-digit recovery code; on success the user is signed in.
  Future<void> verifyRecoveryCode(String email, String code) =>
      _db.auth.verifyOTP(type: OtpType.recovery, email: email, token: code);

  Future<void> updatePassword(String newPassword) =>
      _db.auth.updateUser(UserAttributes(password: newPassword));

  // ── profile ─────────────────────────────────────────────────────────────
  Future<(Profile, String role)?> fetchProfile() async {
    final id = userId;
    if (id == null) return null;
    final row = await _db.from('profiles').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    final created = DateTime.tryParse((row['created_at'] ?? '') as String? ?? '');
    final joined = created != null
        ? 'Joined ${_month(created.month)} ${created.year}'
        : 'Member';
    final profile = Profile(
      name: (row['full_name'] ?? 'New User') as String,
      email: userEmail ?? '',
      phone: (row['phone'] ?? '') as String,
      joined: joined,
    );
    return (profile, (row['role'] ?? 'user') as String);
  }

  Future<bool> isNotificationEnabled() async {
    final id = userId;
    if (id == null) return true;
    final row = await _db
        .from('profiles')
        .select('notification_enabled')
        .eq('id', id)
        .maybeSingle();
    return (row?['notification_enabled'] ?? true) as bool;
  }

  Future<void> updateProfile({String? name, String? phone, bool? notif}) async {
    final id = userId;
    if (id == null) return;
    final patch = <String, dynamic>{};
    if (name != null) patch['full_name'] = name;
    if (phone != null) patch['phone'] = phone;
    if (notif != null) patch['notification_enabled'] = notif;
    if (patch.isEmpty) return;
    await _db.from('profiles').update(patch).eq('id', id);
  }

  // ── catalogue ─────────────────────────────────────────────────────────────
  Future<({List<Category> categories, List<City> cities, List<Listing> listings})>
      loadCatalog() async {
    final catRows = await _db.from('categories').select();
    final cityRows =
        await _db.from('cities').select().eq('is_active', true).order('sort_order');
    final listRows =
        await _db.from('listings').select().eq('is_active', true);

    final categories = (catRows as List)
        .map((r) => Category.fromMap(r as Map<String, dynamic>))
        .toList();
    final listings = (listRows as List)
        .map((r) => Listing.fromMap(r as Map<String, dynamic>))
        .toList();

    // place counts per city
    final counts = <String, int>{};
    for (final l in listings) {
      counts[l.cityId] = (counts[l.cityId] ?? 0) + 1;
    }
    final cities = (cityRows as List).map((r) {
      final m = r as Map<String, dynamic>;
      return City.fromMap(m, places: counts[m['id']] ?? 0);
    }).toList();

    return (categories: categories, cities: cities, listings: listings);
  }

  // ── reviews ───────────────────────────────────────────────────────────────
  Future<List<Review>> fetchReviews(String listingId) async {
    final rows = await _db
        .from('reviews')
        .select()
        .eq('listing_id', listingId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => Review.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> addReview(String listingId, int rating, String comment) =>
      _db.rpc('add_review', params: {
        'p_listing_id': listingId,
        'p_rating': rating,
        'p_comment': comment,
      });

  Future<void> deleteReview(String reviewId) =>
      _db.from('reviews').delete().eq('id', reviewId);

  Future<int> countMyReviews() async {
    final id = userId;
    if (id == null) return 0;
    final rows = await _db.from('reviews').select('id').eq('user_id', id);
    return (rows as List).length;
  }

  /// Recent reviews across all listings (for admin moderation), with listing name.
  Future<List<Map<String, dynamic>>> fetchAllReviews() async {
    final rows = await _db
        .from('reviews')
        .select('*, listings(name)')
        .order('created_at', ascending: false)
        .limit(100);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  // ── favourites ──────────────────────────────────────────────────────────
  Future<Set<String>> fetchFavouriteIds() async {
    final id = userId;
    if (id == null) return {};
    final rows =
        await _db.from('favourites').select('listing_id').eq('user_id', id);
    return (rows as List).map((r) => r['listing_id'] as String).toSet();
  }

  Future<void> addFavourite(String listingId) async {
    final id = userId;
    if (id == null) return;
    await _db.from('favourites').insert({'listing_id': listingId, 'user_id': id});
  }

  Future<void> removeFavourite(String listingId) async {
    final id = userId;
    if (id == null) return;
    await _db
        .from('favourites')
        .delete()
        .eq('listing_id', listingId)
        .eq('user_id', id);
  }

  // ── admin: cities ─────────────────────────────────────────────────────────
  Future<void> upsertCity(Map<String, dynamic> data) =>
      _db.from('cities').upsert(data);

  Future<void> deleteCity(String id) => _db.from('cities').delete().eq('id', id);

  // ── admin: listings ───────────────────────────────────────────────────────
  Future<void> upsertListing(Map<String, dynamic> data) =>
      _db.from('listings').upsert(data);

  Future<void> deleteListing(String id) =>
      _db.from('listings').delete().eq('id', id);

  // ── storage ────────────────────────────────────────────────────────────────
  /// Uploads image [bytes] to the public bucket and returns its public URL.
  Future<String> uploadImage(String path, Uint8List bytes,
      {String contentType = 'image/jpeg'}) async {
    const bucket = 'city-guide-images';
    await _db.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions:
              FileOptions(upsert: true, contentType: contentType),
        );
    return _db.storage.from(bucket).getPublicUrl(path);
  }

  static String _month(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][(m - 1).clamp(0, 11)];
}
