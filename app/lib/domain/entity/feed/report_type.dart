/// 举报类型枚举（与数据库 report_type 对应）
enum ReportType {
  spam(1, '垃圾广告'),
  porn(2, '色情低俗'),
  illegal(3, '违法违规'),
  abuse(4, '侮辱谩骂'),
  other(5, '其他');

  final int value;
  final String label;

  const ReportType(this.value, this.label);
}

/// 举报原因选项
class ReportReason {
  final String text;
  final ReportType type;
  final bool needDetail;

  const ReportReason({
    required this.text,
    required this.type,
    this.needDetail = false,
  });
}

/// 预定义的举报原因列表
class ReportReasons {
  static const List<ReportReason> reasons = [
    ReportReason(
      text: '垃圾广告',
      type: ReportType.spam,
      needDetail: false,
    ),
    ReportReason(
      text: '色情低俗',
      type: ReportType.porn,
      needDetail: false,
    ),
    ReportReason(
      text: '欺诈',
      type: ReportType.illegal,
      needDetail: false,
    ),
    ReportReason(
      text: '虚假信息',
      type: ReportType.illegal,
      needDetail: false,
    ),
    ReportReason(
      text: '侮辱谩骂',
      type: ReportType.abuse,
      needDetail: false,
    ),
    ReportReason(
      text: '其他',
      type: ReportType.other,
      needDetail: true,
    ),
  ];
}
