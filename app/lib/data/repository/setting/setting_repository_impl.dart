import 'package:fastapp/domain/repository/setting/setting_repository.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';

class SettingRepositoryImpl extends SettingRepository {
  final SharedPreferenceHelper _sharedPrefsHelper;

  SettingRepositoryImpl(this._sharedPrefsHelper);

  @override
  Future<void> changeBrightnessToDark(bool value) =>
      _sharedPrefsHelper.changeBrightnessToDark(value);

  @override
  bool get isDarkMode => _sharedPrefsHelper.isDarkMode;

  @override
  Future<void> changeLanguage(String value) =>
      _sharedPrefsHelper.changeLanguage(value);

  @override
  String? get currentLanguage => _sharedPrefsHelper.currentLanguage;
}
