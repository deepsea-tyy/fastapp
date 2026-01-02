import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/form/advanced_take_profit_stop_loss_bottom_sheet.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/form/auto_borrow_repay_bottom_sheet.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/info_bottom_sheet.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/form/payment_account_bottom_sheet.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/form/order_type_detail_sheet.dart';
import 'package:fastapp/presentation/views/common/selection_bottom_sheet.dart';
import 'package:fastapp/presentation/views/common/number_input_widget.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:fastapp/presentation/views/spot/widgets/leverage/manual_borrow_repay_screen.dart';
import 'package:fastapp/presentation/views/common/percentage_slider.dart';
import 'package:fastapp/presentation/views/wallet/currency/transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 杠杆订单表单组件
class LeverageOrderForm extends StatefulWidget {
  const LeverageOrderForm({super.key});

  @override
  State<LeverageOrderForm> createState() => _LeverageOrderFormState();
}

class _LeverageOrderFormState extends State<LeverageOrderForm> {
  final SpotTradeStore _store = getIt<SpotTradeStore>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _takeProfitPriceController = TextEditingController();
  final TextEditingController _stopLossTriggerPriceController = TextEditingController();
  final TextEditingController _icebergOrderQuantityController = TextEditingController();
  final TextEditingController _advancedTakeProfitPriceController = TextEditingController();
  final TextEditingController _advancedTakeProfitPercentageController = TextEditingController();
  final TextEditingController _advancedStopLossTriggerPriceController = TextEditingController();
  final TextEditingController _advancedStopLossPercentageController = TextEditingController();
  final TextEditingController _advancedStopLossLimitPriceController = TextEditingController();
  double _selectedPercentage = 0.0;
  bool _takeProfitStopLoss = false;
  bool _icebergOrder = false;
  String _marginMode = '全仓';
  String _leverage = '5x';
  bool _autoBorrow = true;
  bool _autoRepay = true;
  String _takeProfitStopLossType = '涨跌幅';
  String _stopLossOrderType = '限价止损';

  // 样式常量
  static final _labelTextStyle = TextStyle(fontSize: 11, color: Colors.grey.shade600);
  static final _inputBoxDecoration = BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(8),
  );
  static final _bottomSheetShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  static final _checkboxSide = WidgetStateBorderSide.resolveWith(
    (states) => BorderSide(color: Colors.grey.shade300, width: 1.5),
  );

  @override
  void initState() {
    super.initState();
    _priceController.text = '1.598';
    _updateTotal();
    _priceController.addListener(_updateTotal);
    _quantityController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    _takeProfitPriceController.dispose();
    _stopLossTriggerPriceController.dispose();
    _icebergOrderQuantityController.dispose();
    _advancedTakeProfitPriceController.dispose();
    _advancedTakeProfitPercentageController.dispose();
    _advancedStopLossTriggerPriceController.dispose();
    _advancedStopLossPercentageController.dispose();
    _advancedStopLossLimitPriceController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final total = price * quantity;
    _totalController.text = total.toStringAsFixed(2);
  }

  double _getTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.width;
  }

  /// 构建带虚线下划线的标签
  Widget _buildLabelWithDottedLine(String text, {TextStyle? style}) {
    final labelStyle = style ?? _labelTextStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: labelStyle),
        const SizedBox(height: 2),
        SizedBox(
          width: _getTextWidth(text, labelStyle),
          height: 1,
          child: const CustomPaint(painter: DottedLinePainter()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部按钮组
          _buildTopButtons(),
          const SizedBox(height: 6),
          
          // 买入/卖出切换
          _buildTradeSideSelector(),
          const SizedBox(height: 6),
          
          // 订单类型选择
          _buildOrderTypeSelector(),
          const SizedBox(height: 6),
          
          // 价格输入
          _buildPriceInput(),
          const SizedBox(height: 6),
          
          // 数量输入
          _buildQuantityInput(),
          const SizedBox(height: 6),
          
          // 百分比分配滑块
          _buildPercentageSlider(),
          const SizedBox(height: 6),
          
          // 总额显示
          _buildTotalAmount(),
          const SizedBox(height: 6),
          
          // 高级订单选项
          _buildAdvancedOptions(),
          const SizedBox(height: 6),
          
          // 账户余额信息
          _buildBalanceInfo(),
          const SizedBox(height: 6),
          
          // 提交订单按钮
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildTopButton(
            '全仓',
            onTap: () => _showMarginModeBottomSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(
            _leverage,
            onTap: () => _showLeverageBottomSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(
            '自动',
            onTap: () => _showAutoBorrowRepayBottomSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(
            '借/还',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManualBorrowRepayScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTradeSideSelector() {
    return Observer(
      builder: (_) => Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _store.setTradeSide(OrderSide.buy),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _store.tradeSide == OrderSide.buy ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '买入',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _store.tradeSide == OrderSide.buy ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _store.setTradeSide(OrderSide.sell),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _store.tradeSide == OrderSide.sell ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '卖出',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _store.tradeSide == OrderSide.sell ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            InkWell(
              onTap: () => _showOrderTypeBottomSheet(context),
              child: Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _showOrderTypeSelectionSheet(context),
                child: Row(
                  children: [
                    Expanded(child: Text(_getOrderTypeLabel(_store.orderType), style: const TextStyle(fontSize: 14, color: Colors.black87))),
                    Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.limit:
        return orderTypeLimit;
      case OrderType.market:
        return orderTypeMarket;
      case OrderType.stopLoss:
        return orderTypeStopLoss;
      case OrderType.takeProfit:
        return orderTypeTakeProfit;
    }
  }

  // 公共弹框显示方法
  void _showBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: isScrollControlled,
      shape: _bottomSheetShape,
      builder: (_) => child,
    );
  }

  void _showOrderTypeSelectionSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: Observer(
        builder: (_) {
          final orderTypes = [
            {'label': orderTypeLimit, 'type': OrderType.limit},
            {'label': orderTypeMarket, 'type': OrderType.market},
            {'label': orderTypeStopLoss, 'type': OrderType.stopLoss},
            {'label': orderTypeTakeProfit, 'type': OrderType.takeProfit},
            {'label': orderTypeTrailing, 'type': null}, // 暂时不支持
          ];

          return SelectionBottomSheet<OrderType?>(
            title: '订单类型',
            useListTileStyle: true,
            selectedValue: _store.orderType,
            onSelected: (type) {
              if (type != null) {
                _store.setOrderType(type);
                Navigator.of(context).pop();
              }
            },
            options: orderTypes
                .map((item) => SelectionOption<OrderType?>(
                      title: item['label'] as String,
                      value: item['type'] as OrderType?,
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  void _showOrderTypeBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      isScrollControlled: true,
      child: OrderTypeDetailSheet(store: _store),
    );
  }

  void _showMarginModeBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: SelectionBottomSheet<String>(
        title: '杠杆账户',
        selectedValue: _marginMode,
        onSelected: (mode) {
          setState(() {
            _marginMode = mode;
          });
          Navigator.of(context).pop();
        },
        options: [
          SelectionOption(
            title: '全仓',
            description: '全仓保证金账户中的抵押品由全部仓位共享，可能受抵押率的限制。如果发生强平，全部仓位都将被强制平仓。',
            value: '全仓',
          ),
          SelectionOption(
            title: '逐仓',
            description: '每个交易对都有各自的逐仓保证金账户。如果发生强制平仓，风险仅限于该交易对。',
            value: '逐仓',
          ),
        ],
        footer: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '*全仓保证金和逐仓保证金的交易对有所不同',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  void _showLeverageBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: SelectionBottomSheet<String>(
        title: '全仓杠杆最高杠杆倍数',
        selectedValue: _leverage,
        onSelected: (leverage) {
          setState(() {
            _leverage = leverage;
          });
          Navigator.of(context).pop();
        },
        options: ['3x', '5x', '10x']
            .map((leverage) => SelectionOption<String>(
                  title: leverage,
                  value: leverage,
                ))
            .toList(),
      ),
    );
  }

  void _showAutoBorrowRepayBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: AutoBorrowRepayBottomSheet(
        autoBorrow: _autoBorrow,
        autoRepay: _autoRepay,
        onAutoBorrowChanged: (value) {
          setState(() {
            _autoBorrow = value;
          });
        },
        onAutoRepayChanged: (value) {
          setState(() {
            _autoRepay = value;
          });
        },
      ),
    );
  }

  void _showTakeProfitStopLossInfoBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: InfoBottomSheet(
        title: '止盈/止损',
        content: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  children: [
                    TextSpan(text: '提前设置止盈/止损，双向止盈/止损由OCO订单实现，其中'),
                    TextSpan(text: "'被动限价单'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '作为止盈单，'),
                    TextSpan(text: "'限价止损(或市价止损)'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '作为止损单。'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // TODO: 实现查看更多功能
                },
                child: Text('查看更多', style: TextStyle(fontSize: 14, color: Colors.orange.shade700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedTakeProfitStopLossBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      isScrollControlled: true,
      child: AdvancedTakeProfitStopLossBottomSheet(
        takeProfitPriceController: _advancedTakeProfitPriceController,
        takeProfitPercentageController: _advancedTakeProfitPercentageController,
        stopLossTriggerPriceController: _advancedStopLossTriggerPriceController,
        stopLossPercentageController: _advancedStopLossPercentageController,
        stopLossLimitPriceController: _advancedStopLossLimitPriceController,
        stopLossOrderType: _stopLossOrderType,
        onStopLossOrderTypeChanged: (type) {
          setState(() {
            _stopLossOrderType = type;
          });
        },
      ),
    );
  }

  void _showTakeProfitStopLossBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: SelectionBottomSheet<String>(
        title: '止盈/止损设置',
        selectedValue: _takeProfitStopLossType,
        onSelected: (type) {
          setState(() {
            _takeProfitStopLossType = type;
          });
          Navigator.of(context).pop();
        },
        options: [
          SelectionOption(
            title: '涨跌幅',
            description: '根据主订单价格或开仓价格相关的百分比变化来设置止盈/止损价格',
            value: '涨跌幅',
          ),
          SelectionOption(
            title: '盈亏',
            description: '根据预估盈亏设置止盈/止损价格',
            value: '盈亏',
          ),

        ],
      ),
    );
  }

  void _showIcebergOrderBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: InfoBottomSheet(
        title: '冰山单',
        content: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '冰山单将把原订单拆成多笔订单进行交易,仅当前一个冰山单完全成交后下达下一个冰山单。最后一个冰山单的数量为(订单总数量 / 冰山单数量)的剩余数量。一个订单最多分成10个冰山单(= 订单总数量 / 冰山单数量),且应低于总订单数量。冰山单遵循常规交易规则,包括最小订单金额要求以及交易手续费率等。',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return NumberInputWidget(
      controller: _priceController,
      onDecrease: () {
        final price = double.tryParse(_priceController.text) ?? 0;
        _priceController.text = (price - 0.001).toStringAsFixed(3);
      },
      onIncrease: () {
        final price = double.tryParse(_priceController.text) ?? 0;
        _priceController.text = (price + 0.001).toStringAsFixed(3);
      },
      label: '委托价(USDT)',
      isBold: true,
      fontSize: 18,
    );
  }

  Widget _buildQuantityInput() {
    return Observer(
      builder: (_) {
        final parts = _store.selectedSymbol.split('/');
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'TON';
        return NumberInputWidget(
          controller: _quantityController,
          onDecrease: () {
            final quantity = double.tryParse(_quantityController.text) ?? 0;
            if (quantity > 0) {
              _quantityController.text = (quantity - 0.1).toStringAsFixed(1);
            }
          },
          onIncrease: () {
            final quantity = double.tryParse(_quantityController.text) ?? 0;
            _quantityController.text = (quantity + 0.1).toStringAsFixed(1);
          },
          label: '数量($baseCurrency)',
          hintText: '',
        );
      },
    );
  }

  Widget _buildPercentageSlider() {
    return Observer(
      builder: (_) => PercentageSlider(
        value: _selectedPercentage,
        activeColor: Colors.green,
        onChanged: (value) {
          setState(() {
            _selectedPercentage = value;
          });
          // TODO: 根据百分比设置数量
        },
      ),
    );
  }

  Widget _buildTotalAmount() {
    return NumberInputWidget(
      controller: _totalController,
      onDecrease: () {},
      onIncrease: () {},
      label: '总额(USDT)',
      showDecreaseButton: false,
      showIncreaseButton: false,
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => setState(() => _takeProfitStopLoss = !_takeProfitStopLoss),
              child: Icon(
                _takeProfitStopLoss ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _showTakeProfitStopLossInfoBottomSheet(context),
                child: const Text(
                  '止盈/止损',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
              ),
            ),
            if (_takeProfitStopLoss) ...[
              Text(
                '高级',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _showAdvancedTakeProfitStopLossBottomSheet(context),
                child: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        if (_takeProfitStopLoss) ...[
          const SizedBox(height: 12),
          _buildTakeProfitSection(),
          const SizedBox(height: 12),
          _buildStopLossSection(),
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: () => setState(() => _icebergOrder = !_icebergOrder),
              child: Icon(
                _icebergOrder ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _showIcebergOrderBottomSheet(context),
                child: const Text(
                  '冰山单',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_icebergOrder) ...[
          const SizedBox(height: 12),
          _buildIcebergOrderQuantitySection(),
        ],
      ],
    );
  }

  Widget _buildTakeProfitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('止盈', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        NumberInputWidget(
          controller: _takeProfitPriceController,
          onDecrease: () {
            final price = double.tryParse(_takeProfitPriceController.text) ?? 0;
            if (price > 0) _takeProfitPriceController.text = (price - 0.01).toStringAsFixed(2);
          },
          onIncrease: () {
            final price = double.tryParse(_takeProfitPriceController.text) ?? 0;
            _takeProfitPriceController.text = (price + 0.01).toStringAsFixed(2);
          },
          label: '限价止盈(USDT)',
          showLabel: false,
          hintText: '限价止盈(USDT)',
        ),
      ],
    );
  }

  Widget _buildStopLossSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('止损', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        NumberInputWidget(
          controller: _stopLossTriggerPriceController,
          onDecrease: () {
            final price = double.tryParse(_stopLossTriggerPriceController.text) ?? 0;
            if (price > 0) _stopLossTriggerPriceController.text = (price - 0.01).toStringAsFixed(2);
          },
          onIncrease: () {
            final price = double.tryParse(_stopLossTriggerPriceController.text) ?? 0;
            _stopLossTriggerPriceController.text = (price + 0.01).toStringAsFixed(2);
          },
          label: '止损触发价(USDT)',
          showLabel: false,
          hintText: '止损触发价(USDT)',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _stopLossOrderType = '限价止损'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _stopLossOrderType == '限价止损' ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('限价止损', style: TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(width: 4),
                      const Icon(Icons.add, size: 16, color: Colors.black87),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _stopLossOrderType = '市价'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _stopLossOrderType == '市价' ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: const Text('市价', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black87)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIcebergOrderQuantitySection() {
    return NumberInputWidget(
      controller: _icebergOrderQuantityController,
      onDecrease: () {
        final quantity = int.tryParse(_icebergOrderQuantityController.text) ?? 0;
        if (quantity > 1) {
          _icebergOrderQuantityController.text = (quantity - 1).toString();
        }
      },
      onIncrease: () {
        final quantity = int.tryParse(_icebergOrderQuantityController.text) ?? 0;
        _icebergOrderQuantityController.text = (quantity + 1).toString();
      },
      label: '冰山单数量',
      showLabel: false,
      hintText: '冰山单数量',
    );
  }

  Widget _buildBalanceInfo() {
    return Observer(
      builder: (_) {
        final parts = _store.selectedSymbol.split('/');
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'TON';
        final quoteCurrency = parts.length > 1 ? parts[1] : 'USDT';
        final repayCurrency = _store.tradeSide == OrderSide.buy ? baseCurrency : quoteCurrency;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showPaymentAccountBottomSheet(context),
                      child: _buildLabelWithDottedLine('可用'),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showPaymentAccountBottomSheet(context),
                        child: Text('0 USDT', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TransferScreen(),
                            ),
                          );
                        },
                        child: Icon(Icons.swap_horiz, size: 20, color: Colors.amber.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildBalanceRow('可开', '0 USDT', onTap: () => _showAvailableInfoBottomSheet(context)),
            _buildBalanceRow('借款', '0 USDT', onTap: () => _showBorrowInfoBottomSheet(context)),
            _buildBalanceRow('还款', '0 $repayCurrency', onTap: () => _showRepayInfoBottomSheet(context)),
          ],
        );
      },
    );
  }

  Widget _buildBalanceRow(String label, String value, {VoidCallback? onTap}) {
    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          _buildLabelWithDottedLine(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );

    return onTap != null ? InkWell(onTap: onTap, child: content) : content;
  }

  void _showPaymentAccountBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: const PaymentAccountBottomSheet(),
    );
  }

  void _showAvailableInfoBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: InfoBottomSheet.simple(
        title: '可开',
        description: '最大金额 = 可用余额 + 最高可借金额',
      ),
    );
  }

  void _showBorrowInfoBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: InfoBottomSheet.multiLine(
        title: '借款',
        descriptions: [
          '下单时自动借入相应金额。',
          '无论成交与否,下单成功开始计息,需手动还款。',
          '资金池为0%时不可借入。',
        ],
      ),
    );
  }

  void _showRepayInfoBottomSheet(BuildContext context) {
    _showBottomSheet(
      context: context,
      child: InfoBottomSheet.simple(
        title: '还款',
        description: '成交后自动还款对应金额，可能受手续费和实际成交情况影响。',
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Observer(
      builder: (_) {
        final parts = _store.selectedSymbol.split('/');
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'TON';
        return ElevatedButton(
          onPressed: _store.isSubmitting ? null : () => _store.submitOrder(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _store.isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  _store.tradeSide == OrderSide.buy ? '杠杆买入 $baseCurrency' : '杠杆卖出 $baseCurrency',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
        );
      },
    );
  }
}
