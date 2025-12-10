import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

/// 刷新TokenUseCase
class RefreshTokenUseCase implements UseCase<void, void> {
  final UserRepository _userRepository;

  RefreshTokenUseCase(this._userRepository);

  @override
  Future<void> call({required void params}) async {
    return _userRepository.refreshToken();
  }
}

