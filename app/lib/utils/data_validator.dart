/// 数据验证工具类
/// 用于验证 API 响应数据的有效性
class DataValidator {
  DataValidator._();

  /// 检查对象是否为空或无效
  ///
  /// 返回 true 表示数据为空或无效：
  /// - null
  /// - 空对象 {}
  /// - 空数组 []
  static bool isEmpty(dynamic data) {
    if (data == null) return true;

    if (data is Map) {
      return data.isEmpty;
    }

    if (data is List) {
      return data.isEmpty;
    }

    return false;
  }

  /// 检查 Map 数据是否包含所有必填字段
  ///
  /// [data] 要验证的 Map 数据
  /// [requiredFields] 必填字段列表
  ///
  /// 返回 true 表示所有必填字段都存在且不为 null
  ///
  /// 示例：
  /// ```dart
  /// final isValid = DataValidator.hasRequiredFields(
  ///   data,
  ///   ['user_id', 'kyc_level', 'status'],
  /// );
  /// ```
  static bool hasRequiredFields(Map data, List<String> requiredFields) {
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }
    return true;
  }

  /// 检查数据是否有效（非空且包含必填字段）
  ///
  /// [data] 要验证的数据
  /// [requiredFields] 必填字段列表（可选）
  ///
  /// 返回 true 表示数据有效
  static bool isValid(dynamic data, {List<String>? requiredFields}) {
    // 首先检查是否为空
    if (isEmpty(data)) return false;

    // 如果指定了必填字段，且数据是 Map，则验证字段
    if (requiredFields != null && data is Map) {
      return hasRequiredFields(data, requiredFields);
    }

    return true;
  }

  /// 安全地将动态数据转换为 Map<String, dynamic>
  ///
  /// [data] 要转换的数据
  ///
  /// 返回转换后的 Map，如果数据无效则返回 null
  static Map<String, dynamic>? toMap(dynamic data) {
    if (data == null || data is! Map) return null;

    try {
      return Map<String, dynamic>.from(data);
    } catch (e) {
      return null;
    }
  }

  /// 安全地从响应中提取数据列表
  ///
  /// [data] API 响应数据
  /// [requiredFields] 每个元素必须包含的字段（可选）
  ///
  /// 返回有效数据的列表
  ///
  /// 示例：
  /// ```dart
  /// final items = DataValidator.extractList(
  ///   response,
  ///   requiredFields: ['id', 'name'],
  /// );
  /// ```
  static List<Map<String, dynamic>> extractList(
    dynamic data, {
    List<String>? requiredFields,
  }) {
    final result = <Map<String, dynamic>>[];

    if (data == null) return result;

    // 如果是数组
    if (data is List) {
      for (var item in data) {
        if (item is Map) {
          final map = toMap(item);
          if (map != null && isValid(map, requiredFields: requiredFields)) {
            result.add(map);
          }
        }
      }
    }
    // 如果是单个对象，包装为数组
    else if (data is Map) {
      final map = toMap(data);
      if (map != null && isValid(map, requiredFields: requiredFields)) {
        result.add(map);
      }
    }

    return result;
  }

  /// 安全地从响应中提取单个数据对象
  ///
  /// [data] API 响应数据
  /// [requiredFields] 必须包含的字段（可选）
  ///
  /// 返回有效的数据对象，如果无效则返回 null
  ///
  /// 示例：
  /// ```dart
  /// final user = DataValidator.extractObject(
  ///   response,
  ///   requiredFields: ['id', 'email'],
  /// );
  /// ```
  static Map<String, dynamic>? extractObject(
    dynamic data, {
    List<String>? requiredFields,
  }) {
    if (data == null || data is! Map) return null;

    final map = toMap(data);
    if (map != null && isValid(map, requiredFields: requiredFields)) {
      return map;
    }

    return null;
  }

  /// 验证字段类型
  ///
  /// [data] 要验证的 Map 数据
  /// [field] 字段名
  /// [type] 期望的类型
  ///
  /// 返回 true 表示字段存在且类型匹配
  ///
  /// 示例：
  /// ```dart
  /// if (DataValidator.checkFieldType(data, 'age', int)) {
  ///   final age = data['age'] as int;
  /// }
  /// ```
  static bool checkFieldType(Map data, String field, Type type) {
    if (!data.containsKey(field)) return false;

    final value = data[field];
    if (value == null) return false;

    return value.runtimeType == type;
  }

  /// 获取字段值，如果不存在或类型不匹配则返回默认值
  ///
  /// [data] 数据 Map
  /// [field] 字段名
  /// [defaultValue] 默认值
  ///
  /// 示例：
  /// ```dart
  /// final name = DataValidator.getField<String>(data, 'name', '未知');
  /// final age = DataValidator.getField<int>(data, 'age', 0);
  /// ```
  static T getField<T>(Map data, String field, T defaultValue) {
    if (!data.containsKey(field)) return defaultValue;

    final value = data[field];
    if (value is T) return value;

    return defaultValue;
  }
}
