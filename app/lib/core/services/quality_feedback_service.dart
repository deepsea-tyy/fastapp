import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:fastapp/di/service_locator.dart';

/// 内容质量反馈服务
///
/// 管理用户对内容质量的反馈（对投资没有帮助、内容质量差）
class QualityFeedbackService {
  final UserApi _userApi = getIt<UserApi>();

  /// 提交质量反馈
  /// [targetType] 目标类型：1帖子 2文章 3公告 4新闻
  /// [targetId] 目标ID
  /// [qualityType] 质量类型：1对投资没有帮助 2内容质量差
  Future<bool> submitFeedback({
    required int targetType,
    required int targetId,
    required int qualityType,
  }) async {
    try {
      await _userApi.submitQualityFeedback(
        targetType: targetType,
        targetId: targetId,
        qualityType: qualityType,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
