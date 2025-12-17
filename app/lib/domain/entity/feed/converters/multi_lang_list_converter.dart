import 'package:json_annotation/json_annotation.dart';

/// 多语言列表转换器
///
/// 将后端返回的多语言数组格式 [{"lang":"zh_CN","text":"url"}] 转换为字符串列表
class MultiLangListConverter implements JsonConverter<List<String>?, dynamic> {
  const MultiLangListConverter();

  @override
  List<String>? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is! List) return null;
    if (json.isEmpty) return null;

    final result = <String>[];

    for (final item in json) {
      if (item is String) {
        // 如果已经是字符串，直接添加
        if (item.isNotEmpty) result.add(item);
      } else if (item is Map<String, dynamic>) {
        // 如果是多语言对象，提取 text 字段
        final text = item['text'];
        if (text != null && text is String && text.isNotEmpty) {
          result.add(text);
        }
      }
    }

    return result.isEmpty ? null : result;
  }

  @override
  dynamic toJson(List<String>? object) {
    return object;
  }
}
