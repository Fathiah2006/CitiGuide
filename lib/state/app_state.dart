import 'package:flutter/foundation.dart';

import '../models/listing.dart';
import '../models/profile.dart';
import '../models/review.dart';
import '../services/prefs_service.dart';
import '../services/seed_data.dart';

/// Central app state — auth session, selected city, favourites, reviews and
/// profile. Mirrors the single state container in the design's `App.jsx`, but
/// persists across launches via [PrefsService]. Acts as the seam where a real
/// Supabase backend would later plug in.
class AppState extends ChangeNotifier {
  AppState(this._prefs) {
    _isLoggedIn = _prefs.isLoggedIn;
    _selectedCityId = _prefs.cityId;
    _favourites = _prefs.favourites;
    _notificationsEnabled = _prefs.notifications;
    _profile = _prefs.profile ?? SeedData.defaultProfile;
  }

  final PrefsService _prefs;

  bool _isLoggedIn = false;
  Profile _profile = SeedData.defaultProfile;
  String? _selectedCityId;
  Set<String> _favourites = {};
  bool _notificationsEnabled = true;
  final Map<String, List<Review>> _userReviews = {};

  // ── getters ──
  bool get isLoggedIn => _isLoggedIn;
  Profile get profile => _profile;
  String? get selectedCityId => _selectedCityId;
  bool get notificationsEnabled => _notificationsEnabled;
  int get favouriteCount => _favourites.length;

  /// Total reviews authored by the current user across the session.
  int get reviewCount =>
      7 + _userReviews.values.fold(0, (sum, list) => sum + list.length);

  bool isFavourite(String listingId) => _favourites.contains(listingId);

  List<Listing> get favouriteListings =>
      SeedData.listings.where((l) => _favourites.contains(l.id)).toList();

  // ── auth ──
  void login(String email) {
    _isLoggedIn = true;
    _prefs.setLoggedIn(true);
    notifyListeners();
  }

  void signup(String name, String email) {
    _profile = _profile.copyWith(name: name, email: email);
    _prefs.setProfile(_profile);
    login(email);
  }

  void logout() {
    _isLoggedIn = false;
    _selectedCityId = null;
    _prefs.clearSession();
    notifyListeners();
  }

  // ── city ──
  void selectCity(String cityId) {
    _selectedCityId = cityId;
    _prefs.setCity(cityId);
    notifyListeners();
  }

  // ── favourites ──
  /// Toggles a favourite. Returns `true` when the listing was just saved.
  bool toggleFavourite(String listingId) {
    final added = !_favourites.contains(listingId);
    if (added) {
      _favourites = {..._favourites, listingId};
    } else {
      _favourites = {..._favourites}..remove(listingId);
    }
    _prefs.setFavourites(_favourites);
    notifyListeners();
    return added;
  }

  // ── notifications ──
  void setNotifications(bool value) {
    _notificationsEnabled = value;
    _prefs.setNotifications(value);
    notifyListeners();
  }

  // ── profile ──
  void updateProfile({String? name, String? phone}) {
    _profile = _profile.copyWith(name: name, phone: phone);
    _prefs.setProfile(_profile);
    notifyListeners();
  }

  // ── reviews ──
  /// User-authored reviews first, then the seeded/generated ones.
  List<Review> reviewsFor(String listingId) =>
      [...?_userReviews[listingId], ...SeedData.reviewsFor(listingId)];

  void addReview(String listingId, int rating, String text) {
    final review = Review(
      user: _profile.name,
      rating: rating,
      date: 'Just now',
      likes: 0,
      liked: false,
      text: text.trim().isEmpty
          ? 'Great place — highly recommend.'
          : text.trim(),
    );
    _userReviews[listingId] = [review, ...?_userReviews[listingId]];
    notifyListeners();
  }
}
