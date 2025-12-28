import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';

/// 资产详情页面
class AssetDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final Color iconColor;
  final String iconText;

  const AssetDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.iconColor,
    required this.iconText,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.iconColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.iconText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.diamond, color: theme.colorScheme.primary, size: 16),
            const SizedBox(width: 4),
            Text(
              widget.symbol,
              style: TextStyle(
                color: textTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceSection(),
            const SizedBox(height: 24),
            _buildHistorySection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBalanceSection() {
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '现货账户余额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textTheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  _balanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: textTheme.secondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _balanceVisible = !_balanceVisible;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _balanceVisible ? '0.00079' : '****',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _balanceVisible ? '≈ ¥0.00907053' : '',
                  style: TextStyle(
                    fontSize: 14,
                    color: textTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo('可用余额', _balanceVisible ? '0.00079' : '****'),
              ),
              Expanded(
                child: _buildBalanceInfo('不可用', _balanceVisible ? '0' : '****'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo('平均成本', '3.65 USDT'),
              ),
              Expanded(
                child: Row(
                  children: [
                    _buildBalanceInfo('今日盈亏', '-0.00001817 USDT', valueColor: context.statusTheme.error),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: context.textTheme.hint),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value, {Color? valueColor}) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textTheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? textTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '历史',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textTheme.primary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '全部',
                    style: TextStyle(
                      fontSize: 14,
                      color: textTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 16, color: textTheme.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: backgroundTheme.input,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.description, size: 40, color: textTheme.hint),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Icon(Icons.search, size: 20, color: textTheme.hint),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无历史记录',
                  style: TextStyle(
                    fontSize: 14,
                    color: textTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: borderTheme.defaultColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => WalletNavigator.toDeposit(
                  context,
                  symbol: widget.symbol,
                  name: widget.name,
                ),
                child: Text(
                  '添加 ${widget.symbol}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => WalletNavigator.toTransferToUser(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderTheme.defaultColor),
                ),
                child: Text(
                  '转账',
                  style: TextStyle(fontSize: 16, color: textTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => WalletNavigator.toTransfer(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: borderTheme.defaultColor),
                ),
                child: Text(
                  '划转',
                  style: TextStyle(fontSize: 16, color: textTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
