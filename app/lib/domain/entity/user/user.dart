import 'package:json_annotation/json_annotation.dart';
import 'package:fastapp/domain/entity/feed/converters/string_to_int_converter.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String? username;
  final String? mobile;
  final String? email;
  final int? code;
  @JsonKey(name: 'is_google2fa')
  final int? isGoogle2fa;
  @JsonKey(name: 'is_trans_password')
  final int? isTransPassword;
  @JsonKey(name: 'is_password')
  final int? isPassword;
  @JsonKey(name: 'is_kyc')
  final int? isKyc;
  final int? no;
  final UserProfile? profile;

  User({
    required this.id,
    this.username,
    this.mobile,
    this.email,
    this.code,
    this.isGoogle2fa,
    this.isTransPassword,
    this.isPassword,
    this.isKyc,
    this.no,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserProfile {
  final int id;
  @JsonKey(name: 'user_id')
  @StringToIntConverter()
  final int userId;
  final String? nickname;
  final String? avatar;
  final String? signed;
  final String? lang;
  final Map<String, dynamic>? setting;
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
    this.setting,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
