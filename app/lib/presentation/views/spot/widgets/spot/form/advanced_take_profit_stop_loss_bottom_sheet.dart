import 'package:fastapp/presentation/views/common/number_input_widget.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

// 设置方式类型
enum CalculationType {
  priceChangeRange, // 涨跌幅
  profitLoss, // 盈亏
}

// 高级止盈/止损配置弹框
class AdvancedTakeProfitStopLossBottomSheet extends StatefulWidget {
  final TextEditingController takeProfitPriceController;
  final TextEditingController takeProfitPercentageController;
  final TextEditingController stopLossTriggerPriceController;
  final TextEditingController stopLossPercentageController;
  final TextEditingController stopLossLimitPriceController;
  final String stopLossOrderType;
  final ValueChanged<String> onStopLossOrderTypeChanged;

  const AdvancedTakeProfitStopLossBottomSheet({
    super.key,
    required this.takeProfitPriceController,
    required this.takeProfitPercentageController,
    required this.stopLossTriggerPriceController,
    required this.stopLossPercentageController,
    required this.stopLossLimitPriceController,
    required this.stopLossOrderType,
    required this.onStopLossOrderTypeChanged,
  });

  @override
  State<AdvancedTakeProfitStopLossBottomSheet> createState() => _AdvancedTakeProfitStopLossBottomSheetState();
}

class _AdvancedTakeProfitStopLossBottomSheetState extends State<AdvancedTakeProfitStopLossBottomSheet> {
  CalculationType _selectedType = CalculationType.priceChangeRange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Text('止盈/止损', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          _buildTakeProfitSection(context),
          const SizedBox(height: 20),
          _buildStopLossSection(context),
          const SizedBox(height: 24),
          buildBottomSheetButton(
            onPressed: () => Navigator.of(context).pop(),
            text: '确认',
          ),
        ],
      ),
    );
  }

  void _showCalculationTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CalculationTypeSelector(
        selectedType: _selectedType,
        onTypeSelected: (type) {
          setState(() {
            _selectedType = type;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildTakeProfitSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('止盈', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                controller: widget.takeProfitPriceController,
                hintText: '限价止盈(USDT)',
                onDecrease: () {
                  final price = double.tryParse(widget.takeProfitPriceController.text) ?? 0;
                  if (price > 0) widget.takeProfitPriceController.text = (price - 0.001).toStringAsFixed(3);
                },
                onIncrease: () {
                  final price = double.tryParse(widget.takeProfitPriceController.text) ?? 0;
                  widget.takeProfitPriceController.text = (price + 0.001).toStringAsFixed(3);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPercentageInput(
                controller: widget.takeProfitPercentageController,
                onDecrease: () {
                  final percentage = double.tryParse(widget.takeProfitPercentageController.text) ?? 0;
                  if (percentage > 0) widget.takeProfitPercentageController.text = (percentage - 0.01).toStringAsFixed(2);
                },
                onIncrease: () {
                  final percentage = double.tryParse(widget.takeProfitPercentageController.text) ?? 0;
                  widget.takeProfitPercentageController.text = (percentage + 0.01).toStringAsFixed(2);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStopLossSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('止损', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                controller: widget.stopLossTriggerPriceController,
                hintText: '止损触发价(USDT)',
                onDecrease: () {
                  final price = double.tryParse(widget.stopLossTriggerPriceController.text) ?? 0;
                  if (price > 0) widget.stopLossTriggerPriceController.text = (price - 0.001).toStringAsFixed(3);
                },
                onIncrease: () {
                  final price = double.tryParse(widget.stopLossTriggerPriceController.text) ?? 0;
                  widget.stopLossTriggerPriceController.text = (price + 0.001).toStringAsFixed(3);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPercentageInput(
                controller: widget.stopLossPercentageController,
                onDecrease: () {
                  final percentage = double.tryParse(widget.stopLossPercentageController.text) ?? 0;
                  if (percentage > 0) widget.stopLossPercentageController.text = (percentage - 0.01).toStringAsFixed(2);
                },
                onIncrease: () {
                  final percentage = double.tryParse(widget.stopLossPercentageController.text) ?? 0;
                  widget.stopLossPercentageController.text = (percentage + 0.01).toStringAsFixed(2);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                controller: widget.stopLossLimitPriceController,
                hintText: '限价止损',
                onDecrease: () {
                  final price = double.tryParse(widget.stopLossLimitPriceController.text) ?? 0;
                  if (price > 0) widget.stopLossLimitPriceController.text = (price - 0.001).toStringAsFixed(3);
                },
                onIncrease: () {
                  final price = double.tryParse(widget.stopLossLimitPriceController.text) ?? 0;
                  widget.stopLossLimitPriceController.text = (price + 0.001).toStringAsFixed(3);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => widget.onStopLossOrderTypeChanged('市价'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.stopLossOrderType == '市价' ? Colors.grey.shade200 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent, width: 0),
                  ),
                  child: const Text('市价', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black87)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return NumberInputWidget(
      controller: controller,
      onDecrease: onDecrease,
      onIncrease: onIncrease,
      hintText: hintText,
      fontSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      showLabel: false,
    );
  }

  Widget _buildPercentageInput({
    required TextEditingController controller,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    String getTypeLabel() {
      switch (_selectedType) {
        case CalculationType.priceChangeRange:
          return '涨跌幅';
        case CalculationType.profitLoss:
          return '盈亏';
      }
    }

    String getUnit() {
      return _selectedType == CalculationType.profitLoss ? 'USDT' : '%';
    }

    return NumberInputWidget(
      controller: controller,
      onDecrease: onDecrease,
      onIncrease: onIncrease,
      hintText: getTypeLabel(),
      fontSize: 14,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      showLabel: false,
      showDecreaseButton: false,
      showIncreaseButton: false,
      trailing: InkWell(
        onTap: () => _showCalculationTypeSelector(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(getUnit(), style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.2)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}

// 计算方式选择器
class _CalculationTypeSelector extends StatelessWidget {
  final CalculationType selectedType;
  final ValueChanged<CalculationType> onTypeSelected;

  const _CalculationTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        'type': CalculationType.priceChangeRange,
        'title': '涨跌幅',
        'description': '根据主订单价格或开仓价格相关的百分比变化来设置止盈/止损价格',
      },
      {
        'type': CalculationType.profitLoss,
        'title': '盈亏',
        'description': '根据预估盈亏设置止盈/止损价格',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildDragHandle(),
          const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Text('止盈/止损设置', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          ...options.map((option) {
            final type = option['type'] as CalculationType;
            final title = option['title'] as String;
            final description = option['description'] as String;
            final isSelected = selectedType == type;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onTypeSelected(type),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: 1,
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
