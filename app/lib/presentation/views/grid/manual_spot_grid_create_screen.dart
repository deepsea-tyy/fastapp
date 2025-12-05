import 'package:flutter/material.dart';

/// 手动创建现货网格策略页面
class ManualSpotGridCreateScreen extends StatefulWidget {
  final String strategyType;
  
  const ManualSpotGridCreateScreen({
    super.key,
    required this.strategyType,
  });

  @override
  State<ManualSpotGridCreateScreen> createState() => _ManualSpotGridCreateScreenState();
}

class _ManualSpotGridCreateScreenState extends State<ManualSpotGridCreateScreen> {
  String _selectedSymbol = 'BTC/USDT';
  double _currentPrice = 91274.75;
  double _priceChange = -2.36;
  
  // 表单数据
  String _minPrice = '';
  String _maxPrice = '';
  String _gridCount = '2-170';
  String _gridType = '等差';
  String _investment = '>0';
  String _currency = 'USDT';
  
  // 进阶选项
  bool _enableUpMove = false;
  bool _enableGridTrigger = false;
  bool _enableStopProfit = false;
  bool _enableSellAll = true;

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
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                ],
              ),
              Text(
                '${_currentPrice.toStringAsFixed(2)} ${_priceChange >= 0 ? '+' : ''}${_priceChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
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
                '1. 价格区间',
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
                      '3天 AI',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3. 投资额',
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
                    Text(
                      _currency,
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
              Text(
                _currency,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '可用',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Text(
              '0.00 USDT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.add_circle_outline, size: 20, color: Colors.amber.shade700),
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
          
          // 上移
          _buildCheckboxOption('上移', _enableUpMove, (value) {
            setState(() => _enableUpMove = value);
          }),
          
          const SizedBox(height: 16),
          
          // 网格触发
          _buildCheckboxOption('网格触发', _enableGridTrigger, (value) {
            setState(() => _enableGridTrigger = value);
          }),
          
          const SizedBox(height: 16),
          
          // 止盈/止损
          _buildCheckboxOption('止盈/止损', _enableStopProfit, (value) {
            setState(() => _enableStopProfit = value);
          }),
          
          const SizedBox(height: 16),
          
          // 终止时出售全部 BTC
          _buildCheckboxOption('终止时出售全部 BTC', _enableSellAll, (value) {
            setState(() => _enableSellAll = value);
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

  Widget _buildTextField(String hint, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value.isEmpty ? hint : value,
        style: TextStyle(
          fontSize: 14,
          color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
        ),
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
            '创建',
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
