import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/presentation/store/futures/futures_trade_store.dart';
import 'package:fastapp/presentation/views/common/number_input_widget.dart';
import 'package:fastapp/presentation/views/common/percentage_slider.dart';
import 'package:fastapp/presentation/views/wallet/currency/transfer_screen.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/advanced_take_profit_stop_loss_bottom_sheet.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/margin_mode_bottom_sheet.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/leverage_bottom_sheet.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/position_mode_bottom_sheet.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/order_type_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 期货订单表单组件
class FuturesOrderForm extends StatefulWidget {
  final VoidCallback? onHeightChanged;
  
  const FuturesOrderForm({super.key, this.onHeightChanged});

  @override
  State<FuturesOrderForm> createState() => _FuturesOrderFormState();
}

class _FuturesOrderFormState extends State<FuturesOrderForm> {
  final FuturesTradeStore _store = getIt<FuturesTradeStore>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  double _selectedPercentage = 0.0;
  String _marginMode = marginModeCross;
  String _leverage = '5x';
  String _positionMode = positionModeSingle;
  String _positionSide = positionSideOpen; // 开仓/平仓
  bool _takeProfitStopLoss = false; // 止盈止损开关
  String _simpleTakeProfitTriggerType = '标记'; // 简单止盈触发类型
  String _simpleStopLossTriggerType = '标记'; // 简单止损触发类型
  String _timeInForce = 'GTC'; // 时效方式
  final TextEditingController _takeProfitController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = '43245.50';
    _updateTotal();
    _priceController.addListener(_updateTotal);
    _quantityController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    _takeProfitController.dispose();
    _stopLossController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final total = price * quantity;
    _totalController.text = total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
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
          const SizedBox(height: 12),
          
          // 开仓/平仓切换
          _buildPositionSideSelector(),
          const SizedBox(height: 12),
          
          // 订单类型选择（开仓和平仓都显示）
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
          
          // 时效方式选择
          _buildTimeInForceSelector(),
          const SizedBox(height: 6),
          
          // 止盈止损选项（仅开仓时显示）
          if (_positionSide == positionSideOpen) ...[
            _buildStopLossProfit(),
            if (_takeProfitStopLoss) ...[
              const SizedBox(height: 12),
              _buildTakeProfitInput(),
              const SizedBox(height: 12),
              _buildStopLossInput(),
            ],
            const SizedBox(height: 12),
          ],
          
          // 账户余额信息
          _buildBalanceInfo(),
          const SizedBox(height: 12),
          
          // 显示交易按钮
          _buildDualSubmitButtons(),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildTopButton(
            _marginMode,
            onTap: () {
              _showMarginModeSheet();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(
            _leverage,
            onTap: () {
              _showLeverageSheet();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTopButton(
            _positionMode,
            onTap: () {
              _showPositionModeSheet();
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

  Widget _buildPositionSideSelector() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _positionSide = positionSideOpen;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onHeightChanged?.call();
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _positionSide == positionSideOpen ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
positionSideOpen,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _positionSide == positionSideOpen ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _positionSide = positionSideClose;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onHeightChanged?.call();
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _positionSide == positionSideClose ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
positionSideClose,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _positionSide == positionSideClose ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector() {
    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () {
                  _showOrderTypeSheet();
                },
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

  void _showOrderTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OrderTypeBottomSheet(
        currentType: _store.orderType,
        onTypeChanged: (type) => _store.setOrderType(type),
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
        return orderTypeStopLossMarket;
    }
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
        final baseCurrency = parts.isNotEmpty ? parts[0] : 'BTC';
        return NumberInputWidget(
          controller: _quantityController,
          onDecrease: () {
            final quantity = double.tryParse(_quantityController.text) ?? 0;
            if (quantity > 0) {
              _quantityController.text = (quantity - 0.001).toStringAsFixed(3);
            }
          },
          onIncrease: () {
            final quantity = double.tryParse(_quantityController.text) ?? 0;
            _quantityController.text = (quantity + 0.001).toStringAsFixed(3);
          },
          label: '数量($baseCurrency)',
          hintText: '',
        );
      },
    );
  }

  Widget _buildPercentageSlider() {
    return Observer(
      builder: (_) {
        final activeColor = _positionSide == positionSideOpen
            ? (_store.tradeSide == OrderSide.buy ? Colors.green : Colors.red)
            : Colors.grey;
        return PercentageSlider(
          value: _selectedPercentage,
          activeColor: activeColor,
          onChanged: (value) {
            setState(() {
              _selectedPercentage = value;
            });
            // TODO: 根据百分比设置数量
          },
        );
      },
    );
  }

  Widget _buildTimeInForceSelector() {
    return InkWell(
      onTap: () {
        _showTimeInForceSheet();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              _timeInForce,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void _showTimeInForceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '订单时效',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              
              // 选项列表
              _buildTimeInForceOption('GTC', '(一直有效直到取消)', _timeInForce == 'GTC', () {
                setState(() {
                  _timeInForce = 'GTC';
                });
                Navigator.pop(context);
              }),
              _buildTimeInForceOption('IOC', '(立即成交否则取消)', _timeInForce == 'IOC', () {
                setState(() {
                  _timeInForce = 'IOC';
                });
                Navigator.pop(context);
              }),
              _buildTimeInForceOption('FOK', '(全部成交否则取消)', _timeInForce == 'FOK', () {
                setState(() {
                  _timeInForce = 'FOK';
                });
                Navigator.pop(context);
              }),
              _buildTimeInForceOption('GTD', '(到目前为止有效)', _timeInForce == 'GTD', () {
                setState(() {
                  _timeInForce = 'GTD';
                });
                Navigator.pop(context);
              }),
              
              // 取消按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    '取消',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInForceOption(String title, String description, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: title),
                    TextSpan(
                      text: '  $description',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.black87,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    // 平仓时只显示可平信息
    if (_positionSide == positionSideClose) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Text('可平', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const Spacer(),
            const Text('0.00 USDT', style: TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      );
    }
    
    // 开仓时显示完整信息
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                child: Text('可用', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('0 USDT', style: TextStyle(fontSize: 12, color: Colors.black87)),
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
        _buildBalanceRow('可开', '0 USDT'),
        _buildBalanceRow('可用保证金', '0 USDT'),
      ],
    );
  }

  Widget _buildBalanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildStopLossProfit() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _takeProfitStopLoss = !_takeProfitStopLoss;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onHeightChanged?.call();
            });
          },
          child: Icon(
            _takeProfitStopLoss ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            '止盈/止损',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            _showAdvancedStopLossProfitSheet();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '高级',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdvancedStopLossProfitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedStopLossProfitSheet(),
    );
  }

  void _showMarginModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MarginModeBottomSheet(
        currentMode: _marginMode,
        onModeChanged: (mode) {
          setState(() {
            _marginMode = mode;
          });
        },
      ),
    );
  }

  void _showLeverageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LeverageBottomSheet(
        currentLeverage: _leverage,
        onLeverageChanged: (leverage) {
          setState(() {
            _leverage = leverage;
          });
        },
      ),
    );
  }

  void _showPositionModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PositionModeBottomSheet(
        currentMode: _positionMode,
        onModeChanged: (mode) {
          setState(() {
            _positionMode = mode;
          });
        },
      ),
    );
  }

  Widget _buildTakeProfitInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('止盈', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _takeProfitController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '价格',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              _showSimplePriceTriggerTypeSheet(true);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_simpleTakeProfitTriggerType, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopLossInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('止损', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _stopLossController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '价格',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              _showSimplePriceTriggerTypeSheet(false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_simpleStopLossTriggerType, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSimplePriceTriggerTypeSheet(bool isTakeProfit) {
    final currentType = isTakeProfit ? _simpleTakeProfitTriggerType : _simpleStopLossTriggerType;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 选项列表
              _buildSimplePriceTriggerOption('标记价格', currentType == '标记', () {
                setState(() {
                  if (isTakeProfit) {
                    _simpleTakeProfitTriggerType = '标记';
                  } else {
                    _simpleStopLossTriggerType = '标记';
                  }
                });
                Navigator.pop(context);
              }),
              _buildSimplePriceTriggerOption('最新价格', currentType == '最新', () {
                setState(() {
                  if (isTakeProfit) {
                    _simpleTakeProfitTriggerType = '最新';
                  } else {
                    _simpleStopLossTriggerType = '最新';
                  }
                });
                Navigator.pop(context);
              }),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplePriceTriggerOption(String title, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Colors.black87,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDualSubmitButtons() {
    return Observer(
      builder: (_) {
        final isOpen = _positionSide == positionSideOpen;
        
        return Column(
          children: [
            // 开多/平多按钮
            ElevatedButton(
              onPressed: _store.isSubmitting ? null : () {
                _store.setTradeSide(OrderSide.buy);
                _store.submitOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _store.isSubmitting && _store.tradeSide == OrderSide.buy
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isOpen ? '开多' : '平多',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 8),
            // 可平信息（仅平仓时显示）
            if (_positionSide == positionSideClose)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('可平', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const Spacer(),
                    const Text('0.00 USDT', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ],
                ),
              ),
            // 开空/平空按钮
            ElevatedButton(
              onPressed: _store.isSubmitting ? null : () {
                _store.setTradeSide(OrderSide.sell);
                _store.submitOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _store.isSubmitting && _store.tradeSide == OrderSide.sell
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isOpen ? '开空' : '平空',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        );
      },
    );
  }
}
