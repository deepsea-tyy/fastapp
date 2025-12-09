import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'constants/preferences.dart';

class SharedPreferenceHelper {
  // shared pref instance
  final SharedPreferences _sharedPreference;

  // constructor
  SharedPreferenceHelper(this._sharedPreference);

  // General Methods: ----------------------------------------------------------
  Future<String?> get authToken async {
    return _sharedPreference.getString(Preferences.auth_token);
  }

  Future<bool> saveAuthToken(String authToken) async {
    return _sharedPreference.setString(Preferences.auth_token, authToken);
  }

  Future<bool> removeAuthToken() async {
    return _sharedPreference.remove(Preferences.auth_token);
  }

  Future<String?> get refreshToken async {
    return _sharedPreference.getString(Preferences.refresh_token);
  }

  Future<bool> saveRefreshToken(String refreshToken) async {
    return _sharedPreference.setString(Preferences.refresh_token, refreshToken);
  }

  Future<bool> removeRefreshToken() async {
    return _sharedPreference.remove(Preferences.refresh_token);
  }

  Future<int?> get expireAt async {
    return _sharedPreference.getInt(Preferences.expire_at);
  }

  Future<bool> saveExpireAt(int expireAt) async {
    return _sharedPreference.setInt(Preferences.expire_at, expireAt);
  }

  Future<bool> removeExpireAt() async {
    return _sharedPreference.remove(Preferences.expire_at);
  }

  /// 清除所有认证相关的 token
  Future<void> clearAllTokens() async {
    await Future.wait([
      removeAuthToken(),
      removeRefreshToken(),
      removeExpireAt(),
    ]);
  }

  // Login:---------------------------------------------------------------------
  Future<bool> get isLoggedIn async {
    return _sharedPreference.getBool(Preferences.is_logged_in) ?? false;
  }

  Future<bool> saveIsLoggedIn(bool value) async {
    return _sharedPreference.setBool(Preferences.is_logged_in, value);
  }

  // Theme:------------------------------------------------------
  bool get isDarkMode {
    return _sharedPreference.getBool(Preferences.is_dark_mode) ?? false;
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.setBool(Preferences.is_dark_mode, value);
  }

  // Language:---------------------------------------------------
  String? get currentLanguage {
    return _sharedPreference.getString(Preferences.current_language);
  }

  Future<void> changeLanguage(String language) {
    return _sharedPreference.setString(Preferences.current_language, language);
  }
}