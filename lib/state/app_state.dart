import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../models/profile.dart';
import '../models/review.dart';
import '../services/prefs_service.dart';
import '../services/seed_data.dart';
import '../services/supabase_service.dart';

/// Central app state — auth session, selected city, favourites, reviews and
/// profile. Talks to [SupabaseService] when a backend is configured, otherwise
/// runs entirely against the bundled [SeedData] with [PrefsService] persistence.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    // local defaults (used as-is in offline mode, and as fallbacks)
    _isLoggedIn = _prefs.isLoggedIn;
    _selectedCityId = _prefs.cityId;
    _favourites = _prefs.favourites;
    _notificationsEnabled = _prefs.notifications;
    _profile = _prefs.profile ?? SeedData.defaultProfile;
  }

  final PrefsService _prefs;
  final SupabaseService _supa = SupabaseService.instance;

  bool get _online => _supa.enabled;

  bool _isLoggedIn = false;
  Profile _profile = SeedData.defaultProfile;
  String _role = 'user';
  String? _selectedCityId;
  Set<String> _favourites = {};
  bool _notificationsEnabled = true;
  int _myReviewCount = 7;
  final Map<String, List<Review>> _userReviews = {}; // local mode
  final Map<String, List<Review>> _reviewCache = {}; // online mode

  // ── getters ──
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _role == 'admin';
  Profile get profile => _profile;
  String? get selectedCityId => _selectedCityId;
  bool get notificationsEnabled => _notificationsEnabled;
  int get favouriteCount => _favourites.length;
  int get reviewCount => _online
      ? _myReviewCount
      : 7 + _userReviews.values.fold(0, (s, l) => s + l.length);

  bool isFavourite(String listingId) => _favourites.contains(listingId);

  List<Listing> get favouriteListings =>
      SeedData.listings.where((l) => _favourites.contains(l.id)).toList();

  /// Loads the catalogue + session data. Called from the splash screen.
  Future<void> bootstrap() async {
    if (!_online) return;
    try {
      final cat = await _supa.loadCatalog();
      SeedData.hydrate(
          categories: cat.categories, cities: cat.cities, listings: cat.listings);
    } catch (_) {/* keep seed catalogue on failure */}

    _isLoggedIn = _supa.isSignedIn;
    if (_isLoggedIn) await _loadSession();
    notifyListeners();
  }

  Future<void> _loadSession() async {
    try {
      final p = await _supa.fetchProfile();
      if (p != null) {
        _profile = p.$1;
        _role = p.$2;
      }
      _notificationsEnabled = await _supa.isNotificationEnabled();
      _favourites = await _supa.fetchFavouriteIds();
      _myReviewCount = await _supa.countMyReviews();
    } catch (_) {/* non-fatal */}
  }

  // ── auth ──
  Future<void> login(String email, String password) async {
    if (_online) {
      await _supa.signIn(email, password);
      await _loadSession();
    } else {
      _profile = _profile.copyWith(email: email);
      _prefs.setProfile(_profile);
    }
    _isLoggedIn = true;
    _prefs.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> signup(String name, String email, String password) async {
    if (_online) {
      await _supa.signUp(name, email, password);
      await _loadSession();
    } else {
      _profile = _profile.copyWith(name: name, email: email);
      _prefs.setProfile(_profile);
    }
    _isLoggedIn = true;
    _prefs.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> logout() async {
    if (_online) {
      await _supa.signOut();
      _role = 'user';
      _favourites = {};
      _reviewCache.clear();
    }
    _isLoggedIn = false;
    _selectedCityId = null;
    _prefs.clearSession();
    notifyListeners();
  }

  // ── city (selection stays device-local) ──
  void selectCity(String cityId) {
    _selectedCityId = cityId;
    _prefs.setCity(cityId);
    notifyListeners();
  }

  // ── favourites ──
  bool toggleFavourite(String listingId) {
    final added = !_favourites.contains(listingId);
    _favourites = {..._favourites};
    if (added) {
      _favourites.add(listingId);
    } else {
      _favourites.remove(listingId);
    }
    notifyListeners();
    if (_online) {
      (added ? _supa.addFavourite(listingId) : _supa.removeFavourite(listingId))
          .catchError((_) {});
    } else {
      _prefs.setFavourites(_favourites);
    }
    return added;
  }

  // ── notifications ──
  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
    if (_online) {
      _supa.updateProfile(notif: value).catchError((_) {});
    } else {
      _prefs.setNotifications(value);
    }
  }

  // ── profile ──
  void updateProfile({String? name, String? phone}) {
    _profile = _profile.copyWith(name: name, phone: phone);
    notifyListeners();
    if (_online) {
      _supa.updateProfile(name: name, phone: phone).catchError((_) {});
    } else {
      _prefs.setProfile(_profile);
    }
  }

  // ── reviews ──
  List<Review> reviewsFor(String listingId) {
    if (_online) return _reviewCache[listingId] ?? const [];
    return [...?_userReviews[listingId], ...SeedData.reviewsFor(listingId)];
  }

  /// Ensures reviews for a listing are loaded (online mode). Safe to call often.
  Future<void> ensureReviews(String listingId) async {
    if (!_online || _reviewCache.containsKey(listingId)) return;
    try {
      _reviewCache[listingId] = await _supa.fetchReviews(listingId);
      notifyListeners();
    } catch (_) {/* leave empty */}
  }

  Future<void> addReview(String listingId, int rating, String text) async {
    final comment =
        text.trim().isEmpty ? 'Great place — highly recommend.' : text.trim();
    if (_online) {
      await _supa.addReview(listingId, rating, comment);
      _reviewCache.remove(listingId);
      await ensureReviews(listingId);
      _myReviewCount += 1;
      // refresh the listing's blended rating
      try {
        final cat = await _supa.loadCatalog();
        SeedData.hydrate(listings: cat.listings);
      } catch (_) {}
      notifyListeners();
    } else {
      final review = Review(
        user: _profile.name,
        rating: rating,
        date: 'Just now',
        likes: 0,
        liked: false,
        text: comment,
      );
      _userReviews[listingId] = [review, ...?_userReviews[listingId]];
      notifyListeners();
    }
  }

  /// Re-fetch the catalogue (after admin edits).
  Future<void> refreshCatalog() async {
    if (!_online) return;
    try {
      final cat = await _supa.loadCatalog();
      SeedData.hydrate(
          categories: cat.categories, cities: cat.cities, listings: cat.listings);
      notifyListeners();
    } catch (_) {}
  }
}
