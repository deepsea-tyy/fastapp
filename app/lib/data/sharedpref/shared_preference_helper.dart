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

  // Device:--------------------------------------------------------------------
  Future<String?> get deviceId async {
    return _sharedPreference.getString(Preferences.device_id);
  }

  Future<bool> saveDeviceId(String deviceId) async {
    return _sharedPreference.setString(Preferences.device_id, deviceId);
  }

  Future<bool> removeDeviceId() async {
    return _sharedPreference.remove(Preferences.device_id);
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

  // Search History:---------------------------------------------------
  List<String> get searchHistory {
    return _sharedPreference.getStringList(Preferences.search_history) ?? [];
  }

  Future<bool> saveSearchHistory(List<String> history) {
    return _sharedPreference.setStringList(Preferences.search_history, history);
  }

  Future<bool> clearSearchHistory() {
    return _sharedPreference.remove(Preferences.search_history);
  }

  // Batch Clear Methods:-----------------------------------------------

  /// 清除所有认证数据（包括 token 和登录状态）
  Future<void> clearAllAuthData() async {
    await _clearKeys(Preferences.authKeys);
  }

  /// 清除所有用户相关数据
  Future<void> clearAllUserData() async {
    await _clearKeys(Preferences.userDataKeys);
  }

  /// 清除所有用户数据（认证 + 用户数据，但保留应用设置）
  Future<void> clearAllUserRelatedData() async {
    await Future.wait([
      clearAllAuthData(),
      clearAllUserData(),
    ]);
  }

  /// 清除所有数据（包括应用设置）
  Future<void> clearAll() async {
    await _sharedPreference.clear();
  }

  /// 通用清除方法：根据 key 列表批量清除
  Future<void> _clearKeys(List<String> keys) async {
    await Future.wait(keys.map((key) => _sharedPreference.remove(key)));
  }

  /// 获取指定 key 的值（通用方法）
  T? getValue<T>(String key) {
    if (T == String) {
      return _sharedPreference.getString(key) as T?;
    } else if (T == int) {
      return _sharedPreference.getInt(key) as T?;
    } else if (T == bool) {
      return _sharedPreference.getBool(key) as T?;
    } else if (T == double) {
      return _sharedPreference.getDouble(key) as T?;
    }
    return null;
  }

  /// 设置指定 key 的值（通用方法）
  Future<bool> setValue<T>(String key, T value) async {
    if (value is String) {
      return _sharedPreference.setString(key, value);
    } else if (value is int) {
      return _sharedPreference.setInt(key, value);
    } else if (value is bool) {
      return _sharedPreference.setBool(key, value);
    } else if (value is double) {
      return _sharedPreference.setDouble(key, value);
    }
    return false;
  }
}