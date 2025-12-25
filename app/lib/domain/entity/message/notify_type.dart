/// 通知分类枚举
enum NotifyType {
  /// 公告
  announcement(1, '公告'),

  /// 业务通知(活动等)
  activity(2, '活动'),

  /// 账号
  account(3, '账户'),

  /// 广场
  community(4, '广场'),

  /// 资金
  funds(5, '交易');

  const NotifyType(this.value, this.displayName);

  /// 类型值
  final int value;

  /// 显示名称
  final String displayName;

  /// 从值获取枚举
  static NotifyType fromValue(int value) {
    return NotifyType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotifyType.announcement,
    );
  }
}
