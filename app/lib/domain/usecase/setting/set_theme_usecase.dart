import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 设置主题参数
class SetThemeParams {
  final bool isDarkMode;

  SetThemeParams({required this.isDarkMode});
}

/// 设置主题 UseCase
class SetThemeUseCase implements UseCase<void, SetThemeParams> {
  final SettingRepository _repository;

  SetThemeUseCase(this._repository);

  @override
  Future<void> call({required SetThemeParams params}) async {
    await _repository.changeBrightnessToDark(params.isDarkMode);
  }
}

