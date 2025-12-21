import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 设置语言参数
class SetLanguageParams {
  final String language;

  SetLanguageParams({required this.language});
}

/// 设置语言 UseCase
class SetLanguageUseCase implements UseCase<void, SetLanguageParams> {
  final SettingRepository _repository;

  SetLanguageUseCase(this._repository);

  @override
  Future<void> call({required SetLanguageParams params}) async {
    await _repository.changeLanguage(params.language);
  }
}

