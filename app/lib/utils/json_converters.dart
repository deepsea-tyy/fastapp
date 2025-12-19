import 'package:json_annotation/json_annotation.dart';

/// 整型转布尔值转换器
class IntToBoolConverter implements JsonConverter<bool?, dynamic> {
  const IntToBoolConverter();

  @override
  bool? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1';
    return null;
  }

  @override
  dynamic toJson(bool? value) => value == true ? 1 : 0;
}

/// 整型转非空布尔值转换器
class IntToBoolNotNullConverter implements JsonConverter<bool, dynamic> {
  const IntToBoolNotNullConverter();

  @override
  bool fromJson(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1';
    return false;
  }

  @override
  dynamic toJson(bool value) => value ? 1 : 0;
}

/// 全局转换函数（用于 fromJson 参数）
bool? intToBoolNullable(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1';
  return null;
}

/// 全局转换函数（非空版本）
bool intToBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == '1';
  return false;
}
