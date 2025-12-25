/// 快捷问题实体
class QuickQuestion {
  /// 问题ID
  final int id;

  /// 问题文本
  final String question;

  /// 问题分类
  final String? category;

  /// 图标（可选）
  final String? icon;

  /// 排序
  final int order;

  QuickQuestion({
    required this.id,
    required this.question,
    this.category,
    this.icon,
    this.order = 0,
  });

  factory QuickQuestion.fromJson(Map<String, dynamic> json) {
    return QuickQuestion(
      id: json['id'] as int,
      question: json['question'] as String,
      category: json['category'] as String?,
      icon: json['icon'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'icon': icon,
      'order': order,
    };
  }

  /// 创建默认快捷问题列表
  static List<QuickQuestion> getDefaultQuestions() {
    return [
      QuickQuestion(
        id: 1,
        question: '如何充值？',
        category: '充值提现',
        order: 1,
      ),
      QuickQuestion(
        id: 2,
        question: '如何提现？',
        category: '充值提现',
        order: 2,
      ),
      QuickQuestion(
        id: 3,
        question: '如何进行交易？',
        category: '交易问题',
        order: 3,
      ),
      QuickQuestion(
        id: 4,
        question: '手续费是多少？',
        category: '交易问题',
        order: 4,
      ),
      QuickQuestion(
        id: 5,
        question: '忘记密码怎么办？',
        category: '账户安全',
        order: 5,
      ),
      QuickQuestion(
        id: 6,
        question: '如何完成实名认证？',
        category: '账户安全',
        order: 6,
      ),
      QuickQuestion(
        id: 7,
        question: '提现多久到账？',
        category: '充值提现',
        order: 7,
      ),
      QuickQuestion(
        id: 8,
        question: '有优惠活动吗？',
        category: '活动福利',
        order: 8,
      ),
    ];
  }
}
