import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/domain/entity/feed/converters/string_to_int_converter.dart';
import 'package:fastapp/utils/json_converters.dart';

part 'feed_user_profile.g.dart';

/// 用户资料实体（用于用户主页）
///
/// 包含用户基本信息和统计数据
@JsonSerializable()
class FeedUserProfile {
  /// 用户ID
  @JsonKey(name: 'user_id')
  @StringToIntConverter()
  final int userId;

  /// 昵称
  final String nickname;

  /// 头像
  final String? avatar;

  /// 个性签名
  final String? signed;

  /// 是否认证用户
  @JsonKey(name: 'is_verified', fromJson: intToBool)
  final bool isVerified;

  /// 关注数
  @JsonKey(name: 'following_count')
  final int followingCount;

  /// 粉丝数
  @JsonKey(name: 'followers_count')
  final int followersCount;

  /// 获赞数
  @JsonKey(name: 'like_count')
  final int likeCount;

  /// 分享数
  @JsonKey(name: 'share_count')
  final int shareCount;

  FeedUserProfile({
    required this.userId,
    required this.nickname,
    this.avatar,
    this.signed,
    this.isVerified = false,
    this.followingCount = 0,
    this.followersCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
  });

  factory FeedUserProfile.fromJson(Map<String, dynamic> json) =>
      _$FeedUserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$FeedUserProfileToJson(this);

  /// 获取显示用的昵称
  String get displayNickname => nickname.isNotEmpty ? nickname : '用户$userId';

  /// 获取显示用的签名
  String get displaySigned =>
      signed?.isNotEmpty == true ? signed! : '什么也没有..';
}
