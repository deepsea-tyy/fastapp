import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/utils/balance_log_utils.dart';
import 'package:flutter/material.dart';

/// 余额日志详细列表项（用于余额日志页面）
class BalanceLogDetailItem extends StatelessWidget {
  final dynamic log;

  const BalanceLogDetailItem({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final borderTheme = context.borderTheme;
    final isIncrease = log.isIncrease as bool;
    final amountColor = isIncrease ? context.statusTheme.success : context.statusTheme.error;
    final amountPrefix = isIncrease ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundTheme.card,
        border: Border(
          bottom: BorderSide(color: borderTheme.defaultColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  BalanceLogUtils.getLogTitle(log),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textTheme.primary,
                  ),
                ),
              ),
              Text(
                '$amountPrefix${(log.amount as double).toStringAsFixed(8)} ${log.symbol}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            '账户',
            BalanceLogUtils.getWalletTypeLabel(log.walletType as String?),
            textTheme,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            '变动',
            '${(log.availableBefore as double).toStringAsFixed(8)} → ${(log.availableAfter as double).toStringAsFixed(8)}',
            textTheme,
          ),
          const SizedBox(height: 4),
          _buildInfoRow(
            '时间',
            BalanceLogUtils.formatDateTimeFull(log.createdAt as String),
            textTheme,
          ),
          if (log.remark != null && (log.remark as String).isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildInfoRow(
              '备注',
              log.remark as String,
              textTheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextThemeColors textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textTheme.hint),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: textTheme.secondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
