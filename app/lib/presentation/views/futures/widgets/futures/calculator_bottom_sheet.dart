import 'package:flutter/material.dart';

/// 计算器底部弹窗
class CalculatorBottomSheet extends StatefulWidget {
  const CalculatorBottomSheet({super.key});

  @override
  State<CalculatorBottomSheet> createState() => _CalculatorBottomSheetState();
}

class _CalculatorBottomSheetState extends State<CalculatorBottomSheet> {
  int _selectedTab = 0; // 0: 盈亏, 1: 目标价格, 2: 强平价格, 3: 可开, 4: 开仓价格
  String _selectedSide = '做多'; // 做多/做空
  double _leverage = 20.0;
  
  final TextEditingController _entryPriceController = TextEditingController();
  final TextEditingController _closePriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _entryPriceController.dispose();
    _closePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
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
            
            // 标题行
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '计算',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 标签页
            _buildTabBar(),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 做多/做空选择
                    _buildSideSelector(),
                    const SizedBox(height: 20),
                    
                    // 杠杆选择
                    _buildLeverageSection(),
                    const SizedBox(height: 20),
                    
                    // 开仓价格
                    _buildInputField('开仓价格', _entryPriceController, '0.00', 'USDT'),
                    const SizedBox(height: 16),
                    
                    // 平仓价格
                    _buildInputField('平仓价格', _closePriceController, '0.00', 'USDT'),
                    const SizedBox(height: 16),
                    
                    // 成交数量
                    _buildInputField('成交数量', _quantityController, '0.00', 'USDT'),
                    const SizedBox(height: 24),
                    
                    // 结果区域
                    _buildResultSection(),
                    const SizedBox(height: 20),
                    
                    // 计算按钮
                    _buildCalculateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['盈亏', '目标价格', '强平价格', '可开', '开仓价格'];
    
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSideSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedSide = '做多'),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _selectedSide == '做多' ? Colors.green : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              ),
              child: Text(
                '做多',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedSide == '做多' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedSide = '做空'),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _selectedSide == '做空' ? Colors.white : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              child: Text(
                '做空',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedSide == '做空' ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeverageSection() {
    return Column(
      children: [
        // 杠杆显示
        Container(
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_leverage.toInt()}x',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        
        // 杠杆滑块
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.white,
                  overlayColor: Colors.grey.withOpacity(0.2),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                    elevation: 2,
                  ),
                ),
                child: Slider(
                  value: _leverage,
                  min: 1,
                  max: 75,
                  divisions: 74,
                  onChanged: (value) => setState(() => _leverage = value),
                ),
              ),
            ),
          ],
        ),
        
        // 刻度标记
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('15x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('30x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('45x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('60x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text('75x', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // 提示信息
        Row(
          children: [
            Text(
              '当前杠杆数保持仓上限',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Text(
              '800,000 USDT',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String placeholder, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Text(
                suffix,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '结果',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildResultRow('起始保证金', '-- USDT'),
          const SizedBox(height: 12),
          _buildResultRow('盈亏', '0.00 USDT'),
          const SizedBox(height: 12),
          _buildResultRow('回报率', '0.00 %'),
          const SizedBox(height: 12),
          Text(
            '* 提前查看交易的潜在风险和回报。通过使用合约计算来了解',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          '计算',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
