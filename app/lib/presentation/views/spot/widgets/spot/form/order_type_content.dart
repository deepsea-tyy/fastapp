import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 订单类型内容组件
class SpotOrderTypeContent extends StatefulWidget {
  final int selectedTab;

  const SpotOrderTypeContent({
    super.key,
    required this.selectedTab,
  });

  @override
  State<SpotOrderTypeContent> createState() => _SpotOrderTypeContentState();
}

class _SpotOrderTypeContentState extends State<SpotOrderTypeContent> {
  bool _isBuy = true;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTab == 0) {
      return _buildLimitOrderContent();
    } else if (widget.selectedTab == 1) {
      return _buildMarketOrderContent();
    } else if (widget.selectedTab == 2) {
      return _buildLimitTakeProfitStopLossContent();
    } else if (widget.selectedTab == 3) {
      return _buildMarketTakeProfitStopLossContent();
    } else {
      return _buildTrailingStopContent();
    }
  }

  Widget _buildLimitOrderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 说明文字
        Text(
          '限价委托是指以限定或更优价格进行买卖,限价单不能保证执行。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Text(
            '查看更多',
            style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 24),
        // 图示说明
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('图示说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            Row(
              children: [
                _buildRadioButton('买入', true, _isBuy, () => setState(() => _isBuy = true)),
                const SizedBox(width: 16),
                _buildRadioButton('卖出', false, !_isBuy, () => setState(() => _isBuy = false)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 图表区域
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: LimitOrderChartPainter(isBuy: _isBuy),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Row(
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('A-当前价格', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('B/C-限价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 详细说明
        Text(
          '当价格(A)下跌到订单的限价(C)或以下,订单将会自动执行。如果买单的限价高于或等于当前价格,买单将会立即成交。因此,当需要限价买入时,委托价格应低于当前价格。举例说明:',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 16),
        Text(
          '1)上图中,当前价格2400(A)。设置一个委托价格为1500(C)的限价买入订单,价格未下跌到1500(C)或以下之前,订单是不会执行成交的;',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          '2)相反,如果设置限价买入单的委托价格为3000(B),高于当前价格,该订单将会立即成交。其最优成交价应在2400左右,而不是3000。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildMarketOrderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 说明文字
        Text(
          '市价委托是指以目前市场可获得的最优价格进行快速买卖。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Text(
            '查看更多',
            style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 24),
        // 图示说明
        const Text('图示说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        // 图表区域
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: MarketOrderChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Row(
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('A-当前价格', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 详细说明
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            children: [
              const TextSpan(text: '当前价格2400,此时下单一笔市价单,它将会根据'),
              TextSpan(
                text: '对手价',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '直接成交,但成交均价可能不等于2400。根据买卖方向不同,成交均价可能低于,也可能高于2400。'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 备注
        const Text('备注', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          '1) 对于市价买单,成交均价会略高于当前价格;对于市价卖单,成交均价会略低于当前价格;',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          '2) 买入和卖出的市价单,都支持使用【数量】或【成交额】进行下单。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLimitTakeProfitStopLossContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 说明文字
        Text(
          '限价止盈止损委托需要同时设置一个触发价格和一个委托价格。当市场最新价到达触发价时,按预先设置的委托价格和数量自动下单。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Text(
            '查看更多',
            style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 24),
        // 图示说明
        const Text('图示说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        // 图表区域
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: LimitTakeProfitStopLossChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('A-当前价格', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('B/C-触发价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.orange, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('B1/B2/C1/C2-限价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 详细说明
        Text(
          '当前价格为2400 (A),限价止盈止损订单的触发价格,可以设置为3000(B),高于当前价格;也可以设置为1500(C),低于当前价格。一旦价格上涨至3000(B),或下跌到1500(C),达到触发价,限价委托单将自动激活生效。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 24),
        // 备注
        const Text('备注', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          '1) 对于买入和卖出的限价止盈止损订单,委托价都可以高于或低于触发价。比如,触发价B可以和价格略低的委托价B1限价组成止盈止损订单,也可以和价格略高的委托价B2组成止盈止损订单;',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          '2) 在触发价没有达到时,限价委托单是不会生效的,即使价格到达委托价的时间早于触发价;',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            children: [
              const TextSpan(text: '3) 当触发价达到时,只能表明限价委托单将会自动激活生效,并不表示限价委托单将会立即成交。限价委托单被激活后,只有满足其成交条件才会最终执行。'),
              TextSpan(
                text: '了解限价单',
                style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketTakeProfitStopLossContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 说明文字
        Text(
          '当触达设定的价格时,止损市价委托会自动触发。交易者需要设定一个价格去触发该类型委托。该类委托可以应用于设置市价止损和市价止盈委托。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Text(
            '查看更多',
            style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 24),
        // 图示说明
        const Text('图示说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        // 图表区域
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: MarketTakeProfitStopLossChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Row(
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('A-当前价格', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('B/C-触发价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 详细说明
        Text(
          '当前价格2400,市价止盈止损订单的触发价格,可以设置为3000(B),高于当前价格;也可以设置为1500(C),低于当前价格。一旦价格上涨至3000(B),或下跌到1500(C),达到触发价,市价委托单将自动激活生效。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTrailingStopContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        const Text(
          '追踪止损订单',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        // 说明文字
        Text(
          '追踪止损订单允许交易者在市场波动时向市场发送预设订单。当最新价格在订单创建后达到最高/最低价格 (1±追踪幅度)时,这将触发订单作为限价单/市价单提交。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        // 激活价格说明（可展开）
        _buildExpandableActivationPrice(),
        const SizedBox(height: 16),
        // 买入/卖出选择
        Row(
          children: [
            _buildRadioButton('买入', true, _isBuy, () => setState(() => _isBuy = true)),
            const SizedBox(width: 16),
            _buildRadioButton('卖出', false, !_isBuy, () => setState(() => _isBuy = false)),
          ],
        ),
        const SizedBox(height: 24),
        // 图示说明
        const Text('图示说明', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        // 图表区域
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: TrailingStopChartPainter(isBuy: _isBuy),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('A-当前价格', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('B-激活价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.orange, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('C-跟踪幅度', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('D-限价', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // 激活价格说明
        Text(
          '激活价格(B)是可选的。如果设置,它应高于当前价格(A),当激活价格(B)满足且反弹率大于或等于追踪幅度时,将以价格C提交限价单(D)或市价单。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 24),
        // 例如
        const Text('例如', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          '1) 上图中的当前价格为1700 (A)。创建一个新的买入追踪止损订单,激活价格为1500 (B),追踪幅度为10%,限价为1450 (D)。限价可以是任何值,这里我们以1450为例。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          '2) 当市场价格达到1500(B)的激活价格时,追踪止损订单的一个条件满足。当价格降至1400(最低市场价格)然后开始上涨,反弹率大于或等于10%的追踪幅度时,价格将达到C = 1400 * (1 + 10%) = 1540。这将触发在1600(D)提交限价单到订单簿中。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          '3) 如果未设置1450(D)的限价,将优先选择市价单。一旦满足第二个条件,将提交市价单并立即以市场价格成交。',
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildExpandableActivationPrice() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Text(
            '激活价格是追踪止损订单的触...',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Text(
            '展示全部',
            style: TextStyle(fontSize: 14, color: Colors.orange, decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String label, bool value, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade400, width: 2),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}

// 限价止盈止损图表绘制器
class LimitTakeProfitStopLossChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制价格走势线
    paint.color = Colors.black;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.6);
    canvas.drawPath(path, paint);

    // 绘制点A（当前价格）
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final pointAY = size.height * 0.3;
    final pointAX = size.width * 0.3;
    canvas.drawCircle(Offset(pointAX, pointAY), 4, paint);

    // 绘制触发价B（3000，高于当前价格）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointBY = size.height * 0.2;
    final pointBX = size.width * 0.7;
    canvas.drawCircle(Offset(pointBX, pointBY), 4, paint);

    // 绘制触发价C（1500，低于当前价格）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointCY = size.height * 0.75;
    final pointCX = size.width * 0.5;
    canvas.drawCircle(Offset(pointCX, pointCY), 4, paint);

    // 绘制限价B1（略低于触发价B）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    final pointB1Y = pointBY + 20;
    final pointB1X = pointBX;
    canvas.drawCircle(Offset(pointB1X, pointB1Y), 4, paint);

    // 绘制限价B2（略高于触发价B）
    final pointB2Y = pointBY - 20;
    final pointB2X = pointBX;
    canvas.drawCircle(Offset(pointB2X, pointB2Y), 4, paint);

    // 绘制限价C1（略高于触发价C）
    final pointC1Y = pointCY - 20;
    final pointC1X = pointCX;
    canvas.drawCircle(Offset(pointC1X, pointC1Y), 4, paint);

    // 绘制限价C2（略低于触发价C）
    final pointC2Y = pointCY + 20;
    final pointC2X = pointCX;
    canvas.drawCircle(Offset(pointC2X, pointC2Y), 4, paint);

    // 绘制虚线连接
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    final dashPath1 = Path();
    dashPath1.moveTo(pointAX, pointAY);
    dashPath1.lineTo(pointBX, pointBY);
    canvas.drawPath(dashPath1, paint);

    final dashPath2 = Path();
    dashPath2.moveTo(pointAX, pointAY);
    dashPath2.lineTo(pointCX, pointCY);
    canvas.drawPath(dashPath2, paint);

    // 绘制橙色虚线连接触发价和限价
    paint.color = Colors.orange;
    paint.strokeWidth = 1;
    final dashPath3 = Path();
    dashPath3.moveTo(pointBX, pointBY);
    dashPath3.lineTo(pointB1X, pointB1Y);
    canvas.drawPath(dashPath3, paint);

    final dashPath4 = Path();
    dashPath4.moveTo(pointBX, pointBY);
    dashPath4.lineTo(pointB2X, pointB2Y);
    canvas.drawPath(dashPath4, paint);

    final dashPath5 = Path();
    dashPath5.moveTo(pointCX, pointCY);
    dashPath5.lineTo(pointC1X, pointC1Y);
    canvas.drawPath(dashPath5, paint);

    final dashPath6 = Path();
    dashPath6.moveTo(pointCX, pointCY);
    dashPath6.lineTo(pointC2X, pointC2Y);
    canvas.drawPath(dashPath6, paint);

    // 绘制Y轴标签
    final textPainter = TextPainter(
      text: const TextSpan(text: '3000', style: TextStyle(fontSize: 10, color: Colors.black87)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, pointBY - 6));

    textPainter.text = const TextSpan(text: '1500', style: TextStyle(fontSize: 10, color: Colors.black87));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, pointCY - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 市价单图表绘制器
class MarketOrderChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制价格线（2400水平线）
    paint.color = Colors.orange;
    paint.strokeWidth = 1.5;
    final priceY = size.height * 0.5;
    canvas.drawLine(Offset(0, priceY), Offset(size.width, priceY), paint);

    // 绘制价格走势线
    paint.color = Colors.black;
    paint.strokeWidth = 2;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.7, priceY);
    canvas.drawPath(path, paint);

    // 绘制虚线（从A点继续）
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    final dashPath = Path();
    dashPath.moveTo(size.width * 0.7, priceY);
    dashPath.lineTo(size.width, size.height * 0.4);
    canvas.drawPath(dashPath, paint..style = PaintingStyle.stroke);

    // 绘制点A（当前价格，在2400线上）
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;
    final pointAX = size.width * 0.7;
    final pointAY = priceY;
    canvas.drawCircle(Offset(pointAX, pointAY), 4, paint);

    // 绘制Y轴标签
    final textPainter = TextPainter(
      text: const TextSpan(text: '2400', style: TextStyle(fontSize: 10, color: Colors.black87)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, priceY - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 限价单图表绘制器
class LimitOrderChartPainter extends CustomPainter {
  final bool isBuy;

  LimitOrderChartPainter({required this.isBuy});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制价格线
    paint.color = Colors.black;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.9);
    canvas.drawPath(path, paint);

    // 绘制限价线（1500水平线）
    paint.color = Colors.orange;
    paint.strokeWidth = 1.5;
    final limitPriceY = size.height * 0.75;
    canvas.drawLine(Offset(0, limitPriceY), Offset(size.width, limitPriceY), paint);

    // 绘制点A（当前价格）
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final pointAY = size.height * 0.3;
    final pointAX = size.width * 0.3;
    canvas.drawCircle(Offset(pointAX, pointAY), 4, paint);

    // 绘制点B（限价3000）
    paint.color = Colors.red;
    final pointBY = size.height * 0.2;
    final pointBX = size.width * 0.7;
    canvas.drawCircle(Offset(pointBX, pointBY), 4, paint);

    // 绘制点C（限价1500）
    paint.color = Colors.red;
    final pointCY = limitPriceY;
    final pointCX = size.width * 0.5;
    canvas.drawCircle(Offset(pointCX, pointCY), 4, paint);

    // 绘制虚线从C向下
    paint.color = Colors.orange;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    final dashPath = Path();
    dashPath.moveTo(pointCX, pointCY);
    dashPath.lineTo(pointCX, size.height);
    canvas.drawPath(dashPath, paint..style = PaintingStyle.stroke);

    // 绘制Y轴标签
    final textPainter = TextPainter(
      text: const TextSpan(text: '3000', style: TextStyle(fontSize: 10, color: Colors.black87)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height * 0.2 - 6));

    textPainter.text = const TextSpan(text: '1500', style: TextStyle(fontSize: 10, color: Colors.black87));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, limitPriceY - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 市价止盈止损图表绘制器
class MarketTakeProfitStopLossChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制价格走势线（实线部分）
    paint.color = Colors.black;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    canvas.drawPath(path, paint);

    // 绘制点A（当前价格）
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final pointAY = size.height * 0.5;
    final pointAX = size.width * 0.7;
    canvas.drawCircle(Offset(pointAX, pointAY), 4, paint);

    // 绘制虚线从A点延伸（黑色虚线转橙色虚线）
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    // 向上的虚线（黑色部分）
    final dashPathUp1 = Path();
    dashPathUp1.moveTo(pointAX, pointAY);
    dashPathUp1.lineTo(size.width * 0.85, size.height * 0.3);
    canvas.drawPath(dashPathUp1, paint);
    
    // 向上的虚线（橙色部分）
    paint.color = Colors.orange;
    final dashPathUp2 = Path();
    dashPathUp2.moveTo(size.width * 0.85, size.height * 0.3);
    dashPathUp2.lineTo(size.width, size.height * 0.2);
    canvas.drawPath(dashPathUp2, paint);

    // 向下的虚线（黑色部分）
    paint.color = Colors.black;
    final dashPathDown1 = Path();
    dashPathDown1.moveTo(pointAX, pointAY);
    dashPathDown1.lineTo(size.width * 0.85, size.height * 0.7);
    canvas.drawPath(dashPathDown1, paint);
    
    // 向下的虚线（橙色部分）
    paint.color = Colors.orange;
    final dashPathDown2 = Path();
    dashPathDown2.moveTo(size.width * 0.85, size.height * 0.7);
    dashPathDown2.lineTo(size.width, size.height * 0.75);
    canvas.drawPath(dashPathDown2, paint);

    // 绘制触发价B（3000，高于当前价格）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointBY = size.height * 0.2;
    final pointBX = size.width;
    canvas.drawCircle(Offset(pointBX, pointBY), 4, paint);

    // 绘制触发价C（1500，低于当前价格）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointCY = size.height * 0.75;
    final pointCX = size.width;
    canvas.drawCircle(Offset(pointCX, pointCY), 4, paint);

    // 绘制Y轴标签
    final textPainter = TextPainter(
      text: const TextSpan(text: '3000', style: TextStyle(fontSize: 10, color: Colors.black87)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, pointBY - 6));

    textPainter.text = const TextSpan(text: '1500', style: TextStyle(fontSize: 10, color: Colors.black87));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, pointCY - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 跟踪委托图表绘制器
class TrailingStopChartPainter extends CustomPainter {
  final bool isBuy;

  TrailingStopChartPainter({required this.isBuy});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 绘制价格走势线（实线部分，上升趋势）
    paint.color = Colors.black;
    final path = Path();
    path.moveTo(0, size.height * 0.9);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    canvas.drawPath(path, paint);

    // 绘制虚线部分（继续上升然后下降）
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    final dashPath1 = Path();
    dashPath1.moveTo(size.width * 0.4, size.height * 0.3);
    dashPath1.lineTo(size.width * 0.6, size.height * 0.2);
    dashPath1.lineTo(size.width * 0.7, size.height * 0.9);
    canvas.drawPath(dashPath1, paint);

    // 绘制橙色虚线（反弹）
    paint.color = Colors.orange;
    final dashPath2 = Path();
    dashPath2.moveTo(size.width * 0.7, size.height * 0.9);
    dashPath2.lineTo(size.width, size.height * 0.7);
    canvas.drawPath(dashPath2, paint);

    // 绘制点A（当前价格，在实线高点）
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final pointAY = size.height * 0.3;
    final pointAX = size.width * 0.4;
    canvas.drawCircle(Offset(pointAX, pointAY), 4, paint);

    // 绘制点B（激活价，在虚线下降部分）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointBY = size.height * 0.9;
    final pointBX = size.width * 0.7;
    canvas.drawCircle(Offset(pointBX, pointBY), 4, paint);

    // 绘制点C（跟踪幅度，在橙色反弹线上）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    final pointCY = size.height * 0.75;
    final pointCX = size.width * 0.85;
    canvas.drawCircle(Offset(pointCX, pointCY), 4, paint);

    // 绘制点D（限价，在橙色反弹线上）
    paint.color = Colors.orange;
    paint.style = PaintingStyle.fill;
    final pointDY = size.height * 0.9;
    final pointDX = size.width;
    canvas.drawCircle(Offset(pointDX, pointDY), 4, paint);

    // 绘制"市场最低价格"标签
    final textPainter = TextPainter(
      text: const TextSpan(text: '市场最低价格', style: TextStyle(fontSize: 10, color: Colors.black87)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.7 - 30, size.height * 0.9 + 8));

    // 绘制Y轴标签
    textPainter.text = const TextSpan(text: '1600', style: TextStyle(fontSize: 10, color: Colors.black87));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height * 0.3 - 6));

    textPainter.text = const TextSpan(text: '1500', style: TextStyle(fontSize: 10, color: Colors.black87));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, size.height * 0.9 - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
