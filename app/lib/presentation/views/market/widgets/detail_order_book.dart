import 'package:flutter/material.dart';

/// 订单簿数据项
class OrderBookItem {
  final double quantity;
  final double price;

  const OrderBookItem({
    required this.quantity,
    required this.price,
  });
}

/// 最新成交数据项
class TradeItem {
  final DateTime time;
  final double price;
  final double quantity;
  final bool isBuy; // true: 买入, false: 卖出

  const TradeItem({
    required this.time,
    required this.price,
    required this.quantity,
    required this.isBuy,
  });
}

/// 委托订单/最新成交组件
class DetailOrderBook extends StatefulWidget {
  const DetailOrderBook({super.key});

  @override
  State<DetailOrderBook> createState() => _DetailOrderBookState();
}

class _DetailOrderBookState extends State<DetailOrderBook> {
  int _selectedTab = 0; // 0: 委托订单, 1: 最新成交
  String _selectedPrecision = '0.1';

  // 样式常量
  static const _textStyle12 = TextStyle(fontSize: 12, color: Colors.black87);
  static const _textStyle12Grey = TextStyle(fontSize: 12, color: Colors.grey);
  static const _textStyle12Green = TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500);
  static const _textStyle12Red = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500);
  static const _textStyle12White = TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold);

  // 模拟数据
  final List<OrderBookItem> _buyOrders = [
    const OrderBookItem(quantity: 1782338.1, price: 86714.9),
    const OrderBookItem(quantity: 1647.6, price: 86714.8),
    const OrderBookItem(quantity: 346.9, price: 86714.7),
    const OrderBookItem(quantity: 173.5, price: 86714.3),
    const OrderBookItem(quantity: 8064.5, price: 86714.2),
    const OrderBookItem(quantity: 1994.5, price: 86714.1),
    const OrderBookItem(quantity: 607.0, price: 86714.0),
    const OrderBookItem(quantity: 173.5, price: 86713.8),
    const OrderBookItem(quantity: 892.3, price: 86713.7),
    const OrderBookItem(quantity: 1245.6, price: 86713.6),
    const OrderBookItem(quantity: 567.8, price: 86713.5),
    const OrderBookItem(quantity: 2341.2, price: 86713.4),
    const OrderBookItem(quantity: 987.4, price: 86713.3),
    const OrderBookItem(quantity: 1567.9, price: 86713.2),
    const OrderBookItem(quantity: 345.6, price: 86713.1),
    const OrderBookItem(quantity: 2123.4, price: 86713.0),
    const OrderBookItem(quantity: 789.1, price: 86712.9),
    const OrderBookItem(quantity: 1456.7, price: 86712.8),
    const OrderBookItem(quantity: 678.3, price: 86712.7),
    const OrderBookItem(quantity: 1890.5, price: 86712.6),
    const OrderBookItem(quantity: 456.2, price: 86712.5),
    const OrderBookItem(quantity: 2234.8, price: 86712.4),
    const OrderBookItem(quantity: 1123.6, price: 86712.3),
    const OrderBookItem(quantity: 3456.9, price: 86712.2),
    const OrderBookItem(quantity: 567.4, price: 86712.1),
    const OrderBookItem(quantity: 1789.2, price: 86712.0),
  ];

  final List<OrderBookItem> _sellOrders = [
    const OrderBookItem(quantity: 82466.0, price: 86715.0),
    const OrderBookItem(quantity: 346.9, price: 86715.1),
    const OrderBookItem(quantity: 433.6, price: 86715.2),
    const OrderBookItem(quantity: 310874.8, price: 86715.4),
    const OrderBookItem(quantity: 346.9, price: 86715.5),
    const OrderBookItem(quantity: 260.2, price: 86715.7),
    const OrderBookItem(quantity: 173.5, price: 86715.8),
    const OrderBookItem(quantity: 260.2, price: 86716.0),
    const OrderBookItem(quantity: 1234.5, price: 86716.1),
    const OrderBookItem(quantity: 567.8, price: 86716.2),
    const OrderBookItem(quantity: 2345.6, price: 86716.3),
    const OrderBookItem(quantity: 890.1, price: 86716.4),
    const OrderBookItem(quantity: 1678.3, price: 86716.5),
    const OrderBookItem(quantity: 456.7, price: 86716.6),
    const OrderBookItem(quantity: 2123.4, price: 86716.7),
    const OrderBookItem(quantity: 789.2, price: 86716.8),
    const OrderBookItem(quantity: 1456.9, price: 86716.9),
    const OrderBookItem(quantity: 678.5, price: 86717.0),
    const OrderBookItem(quantity: 1890.7, price: 86717.1),
    const OrderBookItem(quantity: 456.3, price: 86717.2),
    const OrderBookItem(quantity: 2234.1, price: 86717.3),
    const OrderBookItem(quantity: 1123.8, price: 86717.4),
    const OrderBookItem(quantity: 3456.2, price: 86717.5),
    const OrderBookItem(quantity: 567.9, price: 86717.6),
    const OrderBookItem(quantity: 1789.4, price: 86717.7),
    const OrderBookItem(quantity: 2345.1, price: 86717.8),
  ];

  final double _buyPercentage = 82.20;
  final double _sellPercentage = 17.80;

  // 最新成交模拟数据
  final List<TradeItem> _latestTrades = List.generate(50, (index) {
    return TradeItem(
      time: DateTime.now().subtract(Duration(seconds: index + 1)),
      price: 86716.0 + (index * 0.1) + (index % 2 == 0 ? 0.5 : -0.3),
      quantity: 1000.0 + (index * 123.4) + (index % 3 * 456.7),
      isBuy: index % 2 == 0,
    );
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 标签页
          _buildTabs(),
          
          // 买卖比例进度条（仅委托订单显示）
          if (_selectedTab == 0) _buildPercentageBar(),
          
          // 订单簿内容
          Expanded(
            child: _selectedTab == 0 ? _buildOrderBook() : _buildLatestTrades(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['委托订单', '最新成交'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = _selectedTab == index;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 16.0 : 0),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPercentageBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (_buyPercentage * 10).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: (_sellPercentage * 10).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${_buyPercentage.toStringAsFixed(2)}%',
                    style: _textStyle12White.copyWith(
                      shadows: const [
                        Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${_sellPercentage.toStringAsFixed(2)}%',
                    style: _textStyle12White.copyWith(
                      shadows: const [
                        Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBook() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text('买', style: _textStyle12Grey.copyWith(color: Colors.grey.shade600)),
                      const SizedBox(width: 8),
                      const SizedBox(width: 60, height: 20),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('卖', style: _textStyle12Grey.copyWith(color: Colors.grey.shade600)),
                      _buildPrecisionSelector(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 可滚动内容
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buyOrders.asMap().entries.map((entry) => _buildOrderRow(
                        quantity: entry.value.quantity,
                        price: entry.value.price,
                        isBuy: true,
                        index: entry.key,
                      )).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _sellOrders.asMap().entries.map((entry) => _buildOrderRow(
                        quantity: entry.value.quantity,
                        price: entry.value.price,
                        isBuy: false,
                        index: entry.key,
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow({
    required double quantity,
    required double price,
    required bool isBuy,
    required int index,
  }) {
    final orders = isBuy ? _buyOrders : _sellOrders;
    final maxQuantity = orders.map((o) => o.quantity).reduce((a, b) => a > b ? a : b);
    final depthRatio = maxQuantity > 0 ? quantity / maxQuantity : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Stack(
        children: [
          // 背景深度填充
          Positioned.fill(
            child: Align(
              alignment: isBuy ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: depthRatio,
                child: Container(
                  color: isBuy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                ),
              ),
            ),
          ),
          // 内容
          Row(
            mainAxisAlignment: isBuy ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: isBuy
                ? [
                    _buildTextCell(_formatNumber(quantity), _textStyle12, TextAlign.left),
                    _buildTextCell(price.toStringAsFixed(1), _textStyle12Green, TextAlign.right),
                  ]
                : [
                    _buildTextCell(price.toStringAsFixed(1), _textStyle12Red, TextAlign.left),
                    const SizedBox(width: 8),
                    _buildTextCell(_formatNumber(quantity), _textStyle12, TextAlign.right),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextCell(String text, TextStyle style, TextAlign align) {
    return SizedBox(
      width: 80,
      child: Text(text, style: style, textAlign: align),
    );
  }

  Widget _buildPrecisionSelector() {
    return GestureDetector(
      onTap: () {
        // TODO: 显示精度选择对话框
      },
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedPrecision,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestTrades() {
    return Column(
      children: [
        // 表头
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('时间', style: _textStyle12Grey.copyWith(color: Colors.grey.shade600)),
              ),
              Expanded(
                flex: 3,
                child: Text('价格', style: _textStyle12Grey.copyWith(color: Colors.grey.shade600), textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 3,
                child: Text('数量(USDT)', style: _textStyle12Grey.copyWith(color: Colors.grey.shade600), textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        // 成交列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _latestTrades.length,
            itemBuilder: (context, index) {
              final trade = _latestTrades[index];
              return _buildTradeRow(trade);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTradeRow(TradeItem trade) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(_formatTime(trade.time), style: _textStyle12),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatNumber(trade.price),
              style: trade.isBuy ? _textStyle12Green : _textStyle12Red,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatNumber(trade.quantity),
              style: _textStyle12,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  String _formatNumber(double number) {
    final parts = number.toStringAsFixed(1).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    String formatted = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted += ',';
      }
      formatted += integerPart[i];
    }
    
    return decimalPart.isNotEmpty ? '$formatted.$decimalPart' : formatted;
  }
}
