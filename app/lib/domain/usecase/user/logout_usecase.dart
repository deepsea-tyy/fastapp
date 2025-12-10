import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

/// 退出登录UseCase
class LogoutUseCase implements UseCase<void, void> {
  final UserRepository _userRepository;

  LogoutUseCase(this._userRepository);

  @override
  Future<void> call({required void params}) async {
    return _userRepository.logout();
  }
}

