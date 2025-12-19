import 'package:json_annotation/json_annotation.dart';

/// 字符串转整数转换器
///
/// 将后端返回的字符串类型的数字（如 "123"）转换为整数类型
/// 支持三种类型：
/// - 整型：123
/// - 字符串数字："123"
/// - 空字符串：""
class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is int) return json;
    if (json is String) {
      // 处理空字符串
      if (json.isEmpty) return 0;
      return int.tryParse(json) ?? 0;
    }
    return 0;
  }

  @override
  dynamic toJson(int object) {
    return object;
  }
}
