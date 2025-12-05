import 'package:flutter/material.dart';

/// 手动创建网格策略页面
class ManualGridCreateScreen extends StatefulWidget {
  final String strategyType;
  
  const ManualGridCreateScreen({
    super.key,
    required this.strategyType,
  });

  @override
  State<ManualGridCreateScreen> createState() => _ManualGridCreateScreenState();
}

class _ManualGridCreateScreenState extends State<ManualGridCreateScreen> {
  String _selectedSymbol = 'ETHUSD CM';
  String _contractType = '永续';
  double _currentPrice = 3114.85;
  double _priceChange = -2.79;
  String _selectedDirection = '中性';
  
  // 表单数据
  String _minPrice = '';
  String _maxPrice = '';
  String _gridCount = '2-169';
  String _gridType = '等差网格';
  String _investment = '>=0 ETH';
  String _leverage = '10x';
  
  // 进阶选项
  bool _enableGridTrigger = true;
  String _triggerPrice = '';
  bool _enableStopProfit = true;
  String _stopProfitType = '全部平仓';
  String _stopProfitMinPrice = '';
  String _stopProfitMaxPrice = '';
  bool _enableStopLoss = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: _buildSymbolHeader(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.image_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 方向选择
                  _buildDirectionButtons(),
                  const SizedBox(height: 16),
                  
                  // 价格范围
                  _buildPriceRangeSection(),
                  const SizedBox(height: 16),
                  
                  // 网格数量
                  _buildGridCountSection(),
                  const SizedBox(height: 16),
                  
                  // 投资额
                  _buildInvestmentSection(),
                  const SizedBox(height: 16),
                  
                  // 可用信息
                  _buildAvailableInfo(),
                  const SizedBox(height: 24),
                  
                  // 进阶选项
                  _buildAdvancedOptions(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // 底部创建按钮
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildSymbolHeader() {
    return GestureDetector(
      onTap: () {
        // TODO: 打开交易对选择器
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _selectedSymbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _contractType,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                ],
              ),
              Row(
                children: [
                  Text(
                    _currentPrice.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_priceChange >= 0 ? '+' : ''}${_priceChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButtons() {
    return Row(
      children: [
        _buildDirectionButton('中性'),
        const SizedBox(width: 12),
        _buildDirectionButton('做多'),
        const SizedBox(width: 12),
        _buildDirectionButton('做空'),
      ],
    );
  }

  Widget _buildDirectionButton(String label) {
    final isSelected = _selectedDirection == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDirection = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. 价格范围',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '30天 AI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('最低价格', _minPrice),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('最高价格', _maxPrice),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. 网格数量',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _gridCount,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      _gridType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '每格利润（已扣除费用）                --%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. 投资额（保证金）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _investment,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      _leverage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableInfo() {
    return Column(
      children: [
        _buildInfoRow('可用', '0.0000 ETH', true),
        const SizedBox(height: 8),
        _buildInfoRow('每笔数量', '-- 张'),
        const SizedBox(height: 8),
        _buildInfoRow('总投资额', '-- ETH'),
        const SizedBox(height: 8),
        _buildInfoRow('保证金模式', '全仓'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [bool highlight = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.amber.shade700 : Colors.grey.shade600,
              ),
            ),
            if (highlight) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Colors.amber.shade700),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '进阶（可选）',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                  ],
                ),
                Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 网格触发
          _buildCheckboxOption('网格触发', _enableGridTrigger, (value) {
            setState(() => _enableGridTrigger = value);
          }),
          if (_enableGridTrigger) ...[
            const SizedBox(height: 8),
            _buildTextField('触发价格', _triggerPrice, suffix: '标记'),
          ],
          
          const SizedBox(height: 16),
          
          // 止盈/止损
          _buildCheckboxOption('止盈/止损', _enableStopProfit, (value) {
            setState(() => _enableStopProfit = value);
          }),
          if (_enableStopProfit) ...[
            const SizedBox(height: 8),
            _buildDropdownField('', _stopProfitType),
            const SizedBox(height: 8),
            _buildTextField('终止最低价格', _stopProfitMinPrice, suffix: '标记'),
            const SizedBox(height: 8),
            _buildTextField('终止最高价格', _stopProfitMaxPrice, suffix: '标记'),
          ],
          
          const SizedBox(height: 16),
          
          // 终止时全部平仓
          _buildCheckboxOption('终止时全部平仓', _enableStopLoss, (value) {
            setState(() => _enableStopLoss = value);
          }),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, String value, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    suffix,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField(String hint, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // TODO: 创建网格策略
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade400,
            foregroundColor: Colors.black87,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            '创建（中性）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
