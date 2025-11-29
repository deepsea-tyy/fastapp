/// 订单状态枚举
enum OrderStatus {
  /// 待成交
  pending,
  
  /// 部分成交
  partiallyFilled,
  
  /// 完全成交
  filled,
  
  /// 已取消
  cancelled,
  
  /// 已拒绝
  rejected,
  
  /// 已过期
  expired,
}

