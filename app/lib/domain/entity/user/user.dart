import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String? mobile;
  final String? email;
  final int? code;
  final UserProfile? profile;

  User({
    required this.id,
    required this.username,
    this.mobile,
    this.email,
    this.code,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserProfile {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String? nickname;
  final String? avatar;
  final String? signed;
  final String? lang;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserProfile({
    required this.id,
    required this.userId,
    this.nickname,
    this.avatar,
    this.signed,
    this.lang,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
