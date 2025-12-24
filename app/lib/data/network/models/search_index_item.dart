/// 搜索索引项模型
class SearchIndexItem {
  final String targetType;
  final int targetId;
  final String title;
  final String? content;
  final List<String> tags;
  final int weight;
  final DateTime lastAt;

  SearchIndexItem({
    required this.targetType,
    required this.targetId,
    required this.title,
    this.content,
    required this.tags,
    required this.weight,
    required this.lastAt,
  });

  factory SearchIndexItem.fromJson(Map<String, dynamic> json) {
    return SearchIndexItem(
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      weight: json['weight'] as int? ?? 0,
      lastAt: json['last_at'] != null 
          ? DateTime.parse(json['last_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_type': targetType,
      'target_id': targetId,
      'title': title,
      'content': content,
      'tags': tags,
      'weight': weight,
      'last_at': lastAt.toIso8601String(),
    };
  }
}
