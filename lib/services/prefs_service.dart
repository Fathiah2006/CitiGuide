import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Thin wrapper over SharedPreferences for local persistence of session,
/// favourites, selected city, profile and the notification preference.
class PrefsService {
  PrefsService._(this._prefs);

  final SharedPreferences _prefs;

  static const _kLoggedIn = 'cg_logged_in';
  static const _kCity = 'cg_city';
  static const _kFavs = 'cg_favourites';
  static const _kNotif = 'cg_notifications';
  static const _kProfile = 'cg_profile';

  static Future<PrefsService> create() async =>
      PrefsService._(await SharedPreferences.getInstance());

  bool get isLoggedIn => _prefs.getBool(_kLoggedIn) ?? false;
  Future<void> setLoggedIn(bool v) => _prefs.setBool(_kLoggedIn, v);

  String? get cityId => _prefs.getString(_kCity);
  Future<void> setCity(String? id) =>
      id == null ? _prefs.remove(_kCity) : _prefs.setString(_kCity, id);

  Set<String> get favourites =>
      (_prefs.getStringList(_kFavs) ?? const <String>[]).toSet();
  Future<void> setFavourites(Set<String> v) =>
      _prefs.setStringList(_kFavs, v.toList());

  bool get notifications => _prefs.getBool(_kNotif) ?? true;
  Future<void> setNotifications(bool v) => _prefs.setBool(_kNotif, v);

  Profile? get profile {
    final raw = _prefs.getString(_kProfile);
    if (raw == null) return null;
    return Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> setProfile(Profile p) =>
      _prefs.setString(_kProfile, jsonEncode(p.toJson()));

  Future<void> clearSession() async {
    await _prefs.remove(_kLoggedIn);
    await _prefs.remove(_kCity);
  }
}
