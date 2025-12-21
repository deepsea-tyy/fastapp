import '../../../core/domain/usecase/use_case.dart';
import '../../repository/setting/setting_repository.dart';

/// 获取主题 UseCase
class GetThemeUseCase implements UseCase<bool, void> {
  final SettingRepository _repository;

  GetThemeUseCase(this._repository);

  @override
  Future<bool> call({required params}) async {
    return _repository.isDarkMode;
  }
}

