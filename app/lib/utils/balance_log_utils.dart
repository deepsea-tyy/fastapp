import 'package:intl/intl.dart';

/// 余额日志工具类
class BalanceLogUtils {
  BalanceLogUtils._();

  /// 格式化日期时间（简短格式：MM-dd HH:mm）
  static String formatDateTimeShort(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('MM-dd HH:mm').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  /// 格式化日期时间（完整格式：yyyy-MM-dd HH:mm:ss）
  static String formatDateTimeFull(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  /// 获取钱包类型标签
  static String getWalletTypeLabel(String? walletType) {
    const labels = {
      'SPOT': '现货',
      'FUTURES': '合约',
      'FUNDING': '资金',
      'MARGIN': '杠杆',
      'EARN': '理财',
      'OPTIONS': '期权',
    };
    return labels[walletType] ?? walletType ?? '全部';
  }

  /// 获取变动类型标签
  static String getChangeTypeLabel(String? changeType) {
    const labels = {
      'DEPOSIT': '充值',
      'WITHDRAW': '提现',
      'TRANSFER_IN': '划入',
      'TRANSFER_OUT': '划出',
      'TRADE_BUY': '买入',
      'TRADE_SELL': '卖出',
      'ORDER_FREEZE': '下单冻结',
      'ORDER_UNFREEZE': '撤单解冻',
      'FEE': '手续费',
      'REBATE': '返佣',
      'INTEREST': '利息收益',
    };
    return labels[changeType] ?? '全部';
  }

  /// 根据 refType 和 changeType 组合获取显示标题
  static String getLogTitle(dynamic log) {
    final refType = log.refType;
    final changeType = log.changeType;

    // 优先使用组合逻辑
    if (refType == 'TRANSFER') {
      return changeType == 'IN' ? '划入' : '划出';
    } else if (refType == 'USER_TRANSFER') {
      return changeType == 'IN' ? '收到转账' : '转账';
    } else if (refType == 'DEPOSIT') {
      return '充值';
    } else if (refType == 'WITHDRAW') {
      if (changeType == 'ORDER_FREEZE') {
        return '提现冻结';
      }
      return changeType == 'IN' ? '提现入账' : '提现';
    } else if (refType == 'ORDER_FREEZE') {
      return '下单冻结';
    } else if (refType == 'ORDER_UNFREEZE') {
      return '撤单解冻';
    } else if (refType == 'FEE') {
      return '手续费';
    } else if (refType == 'REBATE') {
      return '返佣';
    } else if (refType == 'INTEREST') {
      return '利息收益';
    }

    // 兜底：使用 changeType 映射
    return changeType ?? '其他';
  }
}
