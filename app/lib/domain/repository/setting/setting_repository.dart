abstract class SettingRepository {
  Future<void> changeBrightnessToDark(bool value);
  bool get isDarkMode;
  Future<void> changeLanguage(String value);
  String? get currentLanguage;
}
