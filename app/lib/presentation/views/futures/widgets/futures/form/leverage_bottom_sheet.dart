import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 杠杆调整弹窗
class LeverageBottomSheet extends StatefulWidget {
  final String currentLeverage;
  final ValueChanged<String> onLeverageChanged;

  const LeverageBottomSheet({
    super.key,
    required this.currentLeverage,
    required this.onLeverageChanged,
  });

  @override
  State<LeverageBottomSheet> createState() => _LeverageBottomSheetState();
}

class _LeverageBottomSheetState extends State<LeverageBottomSheet> {
  late double _tempLeverage;

  @override
  void initState() {
    super.initState();
    _tempLeverage = double.tryParse(widget.currentLeverage.replaceAll('x', '')) ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDragHandle(),
              
              // 标题
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '调整杠杆',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // 杠杆显示区域
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_tempLeverage > 1) {
                          setState(() {
                            _tempLeverage = (_tempLeverage - 1).clamp(1, 150);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.remove, color: Colors.grey.shade600, size: 24),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Text(
                      '${_tempLeverage.toInt()}x',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 40),
                    InkWell(
                      onTap: () {
                        if (_tempLeverage < 150) {
                          setState(() {
                            _tempLeverage = (_tempLeverage + 1).clamp(1, 150);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.add, color: Colors.grey.shade600, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 滑块
              Row(
                children: [
                  const Text('1x', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Expanded(
                    child: Slider(
                      value: _tempLeverage,
                      min: 1,
                      max: 150,
                      divisions: 149,
                      activeColor: Colors.black87,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() {
                          _tempLeverage = value;
                        });
                      },
                    ),
                  ),
                  const Text('150x', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),

              // 刻度标记
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLeverageMark(1),
                    _buildLeverageMark(30),
                    _buildLeverageMark(60),
                    _buildLeverageMark(90),
                    _buildLeverageMark(120),
                    _buildLeverageMark(150),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 提示信息
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '* 当前杠杆倍数最高可开：12,000,000USDT',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当逐仓有仓位时，只能提高杠杆倍数，请注意杠杆调整对仓位的影响。',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '杠杆调整将同时影响当前仓位和挂单的杠杆。',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        children: const [
                          TextSpan(text: '* 选择超过[10x]杠杆交易会增加强行平仓风险，请注意相关风险。更多信息请参考'),
                          TextSpan(
                            text: '这里',
                            style: TextStyle(color: Colors.orange, decoration: TextDecoration.underline),
                          ),
                          TextSpan(text: '。'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 确认按钮
              buildBottomSheetButton(
                onPressed: () {
                  widget.onLeverageChanged('${_tempLeverage.toInt()}x');
                  Navigator.pop(context);
                },
                text: '确认',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeverageMark(int value) {
    final isActive = _tempLeverage >= value;
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.black87 : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value}x',
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
