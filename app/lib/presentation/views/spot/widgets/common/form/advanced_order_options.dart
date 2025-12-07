import 'package:fastapp/presentation/views/common/number_input_widget.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/info_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// 高级订单选项组件（止盈止损、冰山单）
class AdvancedOrderOptions extends StatelessWidget {
  // 止盈止损
  final bool takeProfitStopLoss;
  final ValueChanged<bool> onTakeProfitStopLossChanged;
  final TextEditingController takeProfitPriceController;
  final TextEditingController stopLossTriggerPriceController;
  final String stopLossOrderType;
  final ValueChanged<String> onStopLossOrderTypeChanged;
  final VoidCallback? onAdvancedTakeProfitStopLossTap;

  // 冰山单
  final bool icebergOrder;
  final ValueChanged<bool> onIcebergOrderChanged;
  final TextEditingController icebergOrderQuantityController;

  // 高度变化回调
  final VoidCallback? onHeightChanged;

  const AdvancedOrderOptions({
    super.key,
    required this.takeProfitStopLoss,
    required this.onTakeProfitStopLossChanged,
    required this.takeProfitPriceController,
    required this.stopLossTriggerPriceController,
    required this.stopLossOrderType,
    required this.onStopLossOrderTypeChanged,
    this.onAdvancedTakeProfitStopLossTap,
    required this.icebergOrder,
    required this.onIcebergOrderChanged,
    required this.icebergOrderQuantityController,
    this.onHeightChanged,
  });

  void _showTakeProfitStopLossInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InfoBottomSheet(
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
                onTap: () {},
                child: Text('查看更多', style: TextStyle(fontSize: 14, color: Colors.orange.shade700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIcebergOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => InfoBottomSheet(
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 止盈止损选项
        Row(
          children: [
            InkWell(
              onTap: () {
                onTakeProfitStopLossChanged(!takeProfitStopLoss);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onHeightChanged?.call();
                });
              },
              child: Icon(
                takeProfitStopLoss ? Icons.check_box : Icons.check_box_outline_blank,
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
            if (takeProfitStopLoss) ...[
              Text(
                '高级',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onAdvancedTakeProfitStopLossTap,
                child: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        if (takeProfitStopLoss) ...[
          const SizedBox(height: 12),
          _buildTakeProfitSection(),
          const SizedBox(height: 12),
          _buildStopLossSection(),
        ],
        const SizedBox(height: 6),
        // 冰山单选项
        Row(
          children: [
            InkWell(
              onTap: () {
                onIcebergOrderChanged(!icebergOrder);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onHeightChanged?.call();
                });
              },
              child: Icon(
                icebergOrder ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Builder(
                builder: (context) => InkWell(
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
            ),
          ],
        ),
        if (icebergOrder) ...[
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
          controller: takeProfitPriceController,
          onDecrease: () {
            final price = double.tryParse(takeProfitPriceController.text) ?? 0;
            if (price > 0) takeProfitPriceController.text = (price - 0.01).toStringAsFixed(2);
          },
          onIncrease: () {
            final price = double.tryParse(takeProfitPriceController.text) ?? 0;
            takeProfitPriceController.text = (price + 0.01).toStringAsFixed(2);
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
          controller: stopLossTriggerPriceController,
          onDecrease: () {
            final price = double.tryParse(stopLossTriggerPriceController.text) ?? 0;
            if (price > 0) stopLossTriggerPriceController.text = (price - 0.01).toStringAsFixed(2);
          },
          onIncrease: () {
            final price = double.tryParse(stopLossTriggerPriceController.text) ?? 0;
            stopLossTriggerPriceController.text = (price + 0.01).toStringAsFixed(2);
          },
          label: '止损触发价(USDT)',
          showLabel: false,
          hintText: '止损触发价(USDT)',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStopLossTypeButton('限价止损', showAddIcon: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStopLossTypeButton('市价'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStopLossTypeButton(String type, {bool showAddIcon = false}) {
    final isSelected = stopLossOrderType == type;
    return InkWell(
      onTap: () => onStopLossOrderTypeChanged(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: showAddIcon
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(type, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(width: 4),
                  const Icon(Icons.add, size: 16, color: Colors.black87),
                ],
              )
            : Text(type, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ),
    );
  }

  Widget _buildIcebergOrderQuantitySection() {
    return NumberInputWidget(
      controller: icebergOrderQuantityController,
      onDecrease: () {
        final quantity = int.tryParse(icebergOrderQuantityController.text) ?? 0;
        if (quantity > 1) {
          icebergOrderQuantityController.text = (quantity - 1).toString();
        }
      },
      onIncrease: () {
        final quantity = int.tryParse(icebergOrderQuantityController.text) ?? 0;
        icebergOrderQuantityController.text = (quantity + 1).toString();
      },
      label: '冰山单数量',
      showLabel: false,
      hintText: '冰山单数量',
    );
  }
}
