/// 客服级别
enum CustomerServiceLevel {
  junior, // 初级客服
  intermediate, // 中级客服
  senior, // 高级客服
  expert; // 专家客服

  String get label {
    switch (this) {
      case CustomerServiceLevel.junior:
        return '初级客服';
      case CustomerServiceLevel.intermediate:
        return '中级客服';
      case CustomerServiceLevel.senior:
        return '高级客服';
      case CustomerServiceLevel.expert:
        return '专家客服';
    }
  }

  String get badge {
    switch (this) {
      case CustomerServiceLevel.junior:
        return '⭐';
      case CustomerServiceLevel.intermediate:
        return '⭐⭐';
      case CustomerServiceLevel.senior:
        return '⭐⭐⭐';
      case CustomerServiceLevel.expert:
        return '⭐⭐⭐⭐';
    }
  }
}

/// 客服信息实体
class CustomerService {
  /// 客服ID
  final int id;

  /// 客服昵称
  final String nickname;

  /// 客服头像URL
  final String avatar;

  /// 客服级别
  final CustomerServiceLevel level;

  /// 在线状态
  final bool isOnline;

  /// 客服简介
  final String? description;

  /// 服务评分
  final double? rating;

  /// 响应时间（秒）
  final int? responseTime;

  CustomerService({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.level,
    this.isOnline = true,
    this.description,
    this.rating,
    this.responseTime,
  });

  factory CustomerService.fromJson(Map<String, dynamic> json) {
    return CustomerService(
      id: json['id'] as int,
      nickname: json['nickname'] as String? ?? 'Customer Service',
      avatar: json['avatar'] as String? ?? '',
      level: _parseLevelFromJson(json['level']),
      isOnline: json['is_online'] as bool? ?? true,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      responseTime: json['response_time'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'level': level.index,
      'is_online': isOnline,
      'description': description,
      'rating': rating,
      'response_time': responseTime,
    };
  }

  static CustomerServiceLevel _parseLevelFromJson(dynamic level) {
    if (level is int) {
      if (level >= 0 && level < CustomerServiceLevel.values.length) {
        return CustomerServiceLevel.values[level];
      }
    } else if (level is String) {
      try {
        return CustomerServiceLevel.values.firstWhere(
          (e) => e.name == level.toLowerCase(),
        );
      } catch (_) {
        return CustomerServiceLevel.junior;
      }
    }
    return CustomerServiceLevel.junior;
  }

  /// 创建默认客服
  factory CustomerService.defaultService() {
    return CustomerService(
      id: 0,
      nickname: '在线客服',
      avatar: '',
      level: CustomerServiceLevel.intermediate,
      isOnline: true,
      description: '很高兴为您服务',
      rating: 4.9,
      responseTime: 30,
    );
  }

  CustomerService copyWith({
    int? id,
    String? nickname,
    String? avatar,
    CustomerServiceLevel? level,
    bool? isOnline,
    String? description,
    double? rating,
    int? responseTime,
  }) {
    return CustomerService(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      isOnline: isOnline ?? this.isOnline,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      responseTime: responseTime ?? this.responseTime,
    );
  }
}
