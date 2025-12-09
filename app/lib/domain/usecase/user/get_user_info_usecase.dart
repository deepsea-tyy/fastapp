import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';
import '../../entity/user/user.dart';

/// 获取用户信息UseCase
class GetUserInfoUseCase implements UseCase<User?, void> {
  final UserRepository _userRepository;

  GetUserInfoUseCase(this._userRepository);

  @override
  Future<User?> call({required void params}) async {
    final data = await _userRepository.getUserInfo();
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }
}

