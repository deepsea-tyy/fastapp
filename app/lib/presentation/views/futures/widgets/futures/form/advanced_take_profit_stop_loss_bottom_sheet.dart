import 'package:fastapp/presentation/views/common/number_input_widget.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 高级止盈止损设置弹窗
class AdvancedStopLossProfitSheet extends StatefulWidget {
  const AdvancedStopLossProfitSheet({super.key});
  
  @override
  State<AdvancedStopLossProfitSheet> createState() => _AdvancedStopLossProfitSheetState();
}

class _AdvancedStopLossProfitSheetState extends State<AdvancedStopLossProfitSheet> {
  String _side = '开多'; // 开多/开空
  bool _takeProfitEnabled = true;
  bool _stopLossEnabled = true;
  String _takeProfitType = '市价单'; // 限价单/市价单
  String _stopLossType = '市价单';
  String _takeProfitTriggerType = '标记'; // 标记价格类型
  String _stopLossTriggerType = '标记';
  String _takeProfitProfitLossType = '盈亏'; // 盈亏/收益率%/涨跌幅%
  String _stopLossProfitLossType = '盈亏';
  
  final TextEditingController _takeProfitTriggerController = TextEditingController();
  final TextEditingController _takeProfitPriceController = TextEditingController();
  final TextEditingController _stopLossTriggerController = TextEditingController();
  final TextEditingController _stopLossPriceController = TextEditingController();

  @override
  void dispose() {
    _takeProfitTriggerController.dispose();
    _takeProfitPriceController.dispose();
    _stopLossTriggerController.dispose();
    _stopLossPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDragHandle(),
            
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '止盈/止损',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 开多/开空切换
                  _buildSideSelector(),
                  const SizedBox(height: 24),
                  
                  // 止盈设置
                  _buildTakeProfitSection(),
                  const SizedBox(height: 24),
                  
                  // 止损设置
                  _buildStopLossSection(),
                  const SizedBox(height: 24),
                  
                  // 确认按钮
                  buildBottomSheetButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: '确认',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _side = '开多';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _side == '开多' ? Colors.green : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                ),
                child: Text(
                  '开多',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _side == '开多' ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _side = '开空';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _side == '开空' ? Colors.grey.shade200 : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                ),
                child: const Text(
                  '开空',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTakeProfitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _takeProfitEnabled = !_takeProfitEnabled;
                });
              },
              child: Icon(
                _takeProfitEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                size: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '止盈',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                _showPriceTriggerTypeSheet(_takeProfitTriggerType, (type) {
                  setState(() {
                    _takeProfitTriggerType = type;
                  });
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _takeProfitTriggerType,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ),
        if (_takeProfitEnabled) ...[
          const SizedBox(height: 12),
          NumberInputWidget(
            controller: _takeProfitTriggerController,
            onDecrease: () {
              final price = double.tryParse(_takeProfitTriggerController.text) ?? 0;
              if (price > 0) {
                _takeProfitTriggerController.text = (price - 0.001).toStringAsFixed(3);
              }
            },
            onIncrease: () {
              final price = double.tryParse(_takeProfitTriggerController.text) ?? 0;
              _takeProfitTriggerController.text = (price + 0.001).toStringAsFixed(3);
            },
            label: '触发价',
            showLabel: false,
            hintText: '触发价',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _takeProfitType = '限价单'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _takeProfitType == '限价单' ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Text('限价单', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _takeProfitType = '市价单'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _takeProfitType == '市价单' ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Text('市价单', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ),
              ),
            ],
          ),
          if (_takeProfitType == '限价单') ...[
            const SizedBox(height: 8),
            NumberInputWidget(
              controller: _takeProfitPriceController,
              onDecrease: () {
                final price = double.tryParse(_takeProfitPriceController.text) ?? 0;
                if (price > 0) {
                  _takeProfitPriceController.text = (price - 0.001).toStringAsFixed(3);
                }
              },
              onIncrease: () {
                final price = double.tryParse(_takeProfitPriceController.text) ?? 0;
                _takeProfitPriceController.text = (price + 0.001).toStringAsFixed(3);
              },
              label: '委托价',
              showLabel: false,
              hintText: '委托价',
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStopLossSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _stopLossEnabled = !_stopLossEnabled;
                });
              },
              child: Icon(
                _stopLossEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                size: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '止损',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                _showPriceTriggerTypeSheet(_stopLossTriggerType, (type) {
                  setState(() {
                    _stopLossTriggerType = type;
                  });
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _stopLossTriggerType,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ),
        if (_stopLossEnabled) ...[
          const SizedBox(height: 12),
          NumberInputWidget(
            controller: _stopLossTriggerController,
            onDecrease: () {
              final price = double.tryParse(_stopLossTriggerController.text) ?? 0;
              if (price > 0) {
                _stopLossTriggerController.text = (price - 0.001).toStringAsFixed(3);
              }
            },
            onIncrease: () {
              final price = double.tryParse(_stopLossTriggerController.text) ?? 0;
              _stopLossTriggerController.text = (price + 0.001).toStringAsFixed(3);
            },
            label: '触发价',
            showLabel: false,
            hintText: '触发价',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _stopLossType = '限价单'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _stopLossType == '限价单' ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Text('限价单', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _stopLossType = '市价单'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _stopLossType == '市价单' ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Text('市价单', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black87)),
                  ),
                ),
              ),
            ],
          ),
          if (_stopLossType == '限价单') ...[
            const SizedBox(height: 8),
            NumberInputWidget(
              controller: _stopLossPriceController,
              onDecrease: () {
                final price = double.tryParse(_stopLossPriceController.text) ?? 0;
                if (price > 0) {
                  _stopLossPriceController.text = (price - 0.001).toStringAsFixed(3);
                }
              },
              onIncrease: () {
                final price = double.tryParse(_stopLossPriceController.text) ?? 0;
                _stopLossPriceController.text = (price + 0.001).toStringAsFixed(3);
              },
              label: '委托价',
              showLabel: false,
              hintText: '委托价',
            ),
          ],
        ],
      ],
    );
  }

  void _showPriceTriggerTypeSheet(String currentType, Function(String) onSelected) {
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
              buildDragHandle(),
              
              _buildPriceTriggerOption('标记价格', currentType == '标记', () {
                onSelected('标记');
                Navigator.pop(context);
              }),
              _buildPriceTriggerOption('最新价格', currentType == '最新', () {
                onSelected('最新');
                Navigator.pop(context);
              }),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTriggerOption(String title, bool isSelected, VoidCallback onTap) {
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
}
