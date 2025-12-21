import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 获取语言 UseCase
class GetLanguageUseCase implements UseCase<String?, void> {
  final SettingRepository _repository;

  GetLanguageUseCase(this._repository);

  @override
  Future<String?> call({required params}) async {
    return _repository.currentLanguage;
  }
}

