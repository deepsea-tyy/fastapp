import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/assets/asset_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 当前交易对资产组件
class CurrentTradingPairAssets extends StatelessWidget {
  const CurrentTradingPairAssets({super.key});

  @override
  Widget build(BuildContext context) {
    final spotTradeStore = getIt<SpotTradeStore>();
    final walletStore = getIt<WalletStore>();
    final marketDataStore = getIt<MarketDataStore>();

    return Observer(
      builder: (_) {
        // 解析当前交易对符号
        final symbol = spotTradeStore.selectedSymbol;
        final parts = symbol.split('/');
        if (parts.length != 2) {
          return const SizedBox.shrink();
        }

        final baseCurrency = parts[0];
        final quoteCurrency = parts[1];

        // 获取现货账户余额
        final balances = walletStore.accountBalance?.getBalancesByType(WalletType.SPOT) ?? [];
        
        // 查找基础币种和计价币种的余额
        final baseBalance = balances.firstWhere(
          (b) => b.symbol == baseCurrency,
          orElse: () => _createEmptyBalance(baseCurrency),
        );
        final quoteBalance = balances.firstWhere(
          (b) => b.symbol == quoteCurrency,
          orElse: () => _createEmptyBalance(quoteCurrency),
        );

        // 获取币种信息
        final baseCurrencyInfo = marketDataStore.getCurrency(baseCurrency);
        final quoteCurrencyInfo = marketDataStore.getCurrency(quoteCurrency);

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '当前交易对资产',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  IconButton(
                    icon: _FilterIcon(color: Colors.grey.shade600),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AssetItem(
                symbol: baseCurrency,
                name: baseCurrencyInfo?.name ?? baseCurrency,
                iconColor: _getColorForSymbol(baseCurrency),
                iconText: baseCurrency.isNotEmpty ? baseCurrency[0] : '?',
                balance: baseBalance.total.toStringAsFixed(4),
                logoUrl: baseCurrencyInfo?.logo,
              ),
              const Divider(height: 32),
              AssetItem(
                symbol: quoteCurrency,
                name: quoteCurrencyInfo?.name ?? quoteCurrency,
                iconColor: _getColorForSymbol(quoteCurrency),
                iconText: quoteCurrency.isNotEmpty ? quoteCurrency[0] : '?',
                balance: quoteBalance.total.toStringAsFixed(4),
                logoUrl: quoteCurrencyInfo?.logo,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 创建空余额对象
  Balance _createEmptyBalance(String symbol) {
    return Balance(
      symbol: symbol,
      available: 0.0,
      frozen: 0.0,
      total: 0.0,
    );
  }

  /// 根据币种符号获取颜色
  Color _getColorForSymbol(String symbol) {
    final colors = {
      'BTC': Colors.orange,
      'ETH': Colors.blue,
      'USDT': Colors.teal,
      'BNB': Colors.yellow.shade700,
      'USDC': Colors.blue.shade300,
    };
    return colors[symbol] ?? Colors.grey;
  }
}

/// 自定义筛选图标（两个水平短横线，每条线上有两个小圆圈）
class _FilterIcon extends StatelessWidget {
  final Color color;

  const _FilterIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 16),
      painter: _FilterIconPainter(color: color),
    );
  }
}

class _FilterIconPainter extends CustomPainter {
  final Color color;

  _FilterIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制两条水平线
    final line1Y = size.height * 0.3;
    final line2Y = size.height * 0.7;
    final lineWidth = size.width * 0.6;
    final lineStartX = size.width * 0.2;

    // 第一条线
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineStartX, line1Y - 1, lineWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );

    // 第二条线
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lineStartX, line2Y - 1, lineWidth, 2),
        const Radius.circular(1),
      ),
      paint,
    );

    // 绘制第一条线上的两个圆圈
    final circleRadius = 2.0;
    final circle1X = lineStartX + lineWidth * 0.25;
    final circle2X = lineStartX + lineWidth * 0.75;
    canvas.drawCircle(Offset(circle1X, line1Y), circleRadius, circlePaint);
    canvas.drawCircle(Offset(circle2X, line1Y), circleRadius, circlePaint);

    // 绘制第二条线上的两个圆圈
    canvas.drawCircle(Offset(circle1X, line2Y), circleRadius, circlePaint);
    canvas.drawCircle(Offset(circle2X, line2Y), circleRadius, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
