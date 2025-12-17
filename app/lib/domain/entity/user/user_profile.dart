import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/utils/image_utils.dart';

part 'user_profile.g.dart';

/// 用户资料实体
///
/// 对应后端 user_profile 表
@JsonSerializable()
class UserProfile {
  /// 用户ID
  @JsonKey(name: 'user_id')
  final int? userId;

  /// 昵称
  final String? nickname;

  /// 头像
  final String? avatar;

  UserProfile({
    this.userId,
    this.nickname,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// 默认空资料
  static UserProfile get empty => UserProfile(
        nickname: '',
        avatar: '',
      );

  /// 获取昵称（带默认值）
  String get displayNickname {
    if (nickname == null || nickname!.isEmpty) {
      return 'xxx';
    }
    return nickname!;
  }

  /// 获取头像 URL（使用 ImageUtils 格式化）
  String get displayAvatar {
    return ImageUtils.formatSingleImagePath(avatar);
  }

  /// 检查是否有有效头像
  bool get hasAvatar {
    return ImageUtils.isValidImagePath(avatar) &&
           displayAvatar != ImageUtils.defaultImage;
  }
}
