/// 搜索关键词模型
class SearchKeyword {
  final String keyword;
  final int hitCount;
  final String? icon;
  final String? color;

  SearchKeyword({
    required this.keyword,
    required this.hitCount,
    this.icon,
    this.color,
  });

  factory SearchKeyword.fromJson(Map<String, dynamic> json) {
    return SearchKeyword(
      keyword: json['keyword'] as String? ?? '',
      hitCount: json['hit_count'] as int? ?? 0,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'hit_count': hitCount,
      'icon': icon,
      'color': color,
    };
  }
}
