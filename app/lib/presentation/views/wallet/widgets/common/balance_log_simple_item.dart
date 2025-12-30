import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/utils/balance_log_utils.dart';
import 'package:flutter/material.dart';

/// 余额日志简洁列表项（用于资产详情页）
class BalanceLogSimpleItem extends StatelessWidget {
  final dynamic log;
  final VoidCallback? onTap;

  const BalanceLogSimpleItem({
    super.key,
    required this.log,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;
    final isIncrease = log.isIncrease as bool;
    final amountColor = isIncrease ? context.statusTheme.success : context.statusTheme.error;
    final amountPrefix = isIncrease ? '+' : '';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderTheme.defaultColor, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BalanceLogUtils.getLogTitle(log),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    BalanceLogUtils.formatDateTimeShort(log.createdAt as String),
                    style: TextStyle(
                      fontSize: 12,
                      color: textTheme.hint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${(log.amount as double).toStringAsFixed(8)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
