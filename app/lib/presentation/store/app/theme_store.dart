import 'package:fastapp/constants/app_theme.dart';
import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/repository/setting/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  final SettingRepository _repository;
  final ErrorStore errorStore;

  _ThemeStore(this._repository, this.errorStore) {
    init();
  }

  @observable
  AppThemeType _currentTheme = AppThemeType.dark;

  @computed
  AppThemeType get currentTheme => _currentTheme;

  @computed
  bool get isDarkMode => _currentTheme == AppThemeType.dark;

  @computed
  ThemeData get themeData => AppTheme.getTheme(_currentTheme);

  /// 切换主题（在亮色和暗色之间）
  @action
  Future<void> toggleTheme() async {
    _currentTheme = _currentTheme.toggle();
    await _saveTheme();
  }

  /// 设置主题
  @action
  Future<void> setTheme(AppThemeType themeType) async {
    if (_currentTheme == themeType) return;
    _currentTheme = themeType;
    await _saveTheme();
  }

  /// 初始化主题
  Future<void> init() async {
    final isDark = _repository.isDarkMode;
    _currentTheme = isDark ? AppThemeType.dark : AppThemeType.light;
  }

  /// 保存主题到本地存储
  Future<void> _saveTheme() async {
    await _repository.changeBrightnessToDark(isDarkMode);
  }

  /// 检查系统是否为暗色模式
  bool isPlatformDark(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;
}

