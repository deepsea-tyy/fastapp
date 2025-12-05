import 'package:flutter/material.dart';
import 'widgets/merchant_card.dart';

/// C2C交易主屏幕
class C2CScreen extends StatefulWidget {
  const C2CScreen({super.key});

  @override
  State<C2CScreen> createState() => _C2CScreenState();
}

class _C2CScreenState extends State<C2CScreen> {
  bool _isBuying = true; // true: 我要买, false: 我要卖
  String _selectedCurrency = 'USDT';
  String _selectedFiatCurrency = 'CNY';
  String _selectedAmount = '金额';
  String _selectedPayment = '支付';
  final TextEditingController _amountController = TextEditingController();
  final List<String> _selectedPaymentMethods = [];

  final List<String> _currencies = ['USDT', 'BTC', 'ETH', 'USDC'];
  final List<String> _fiatCurrencies = ['CNY', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildFiatCurrencySelector(),
        ],
      ),
      body: Column(
        children: [
          _buildBuySellToggle(),
          _buildFilterBar(),
          Expanded(
            child: _buildMerchantList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiatCurrencySelector() {
    return GestureDetector(
      onTap: () => _showFiatCurrencyBottomSheet(),
      child: Container(
        margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              _selectedFiatCurrency,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showFiatCurrencyBottomSheet() {
    final fiatCurrencies = [
      {'code': 'CNY', 'name': 'Chinese Yuan (RMB)', 'icon': '¥', 'color': const Color(0xFFE74C3C)},
      {'code': 'USD', 'name': 'US Dollar', 'icon': '\$', 'color': const Color(0xFF27AE60)},
      {'code': 'EUR', 'name': 'Euro', 'icon': '€', 'color': const Color(0xFF3498DB)},
      {'code': 'GBP', 'name': 'British Pound', 'icon': '£', 'color': const Color(0xFF9B59B6)},
      {'code': 'AFN', 'name': 'AFN', 'icon': '؋', 'color': const Color(0xFFE74C3C)},
      {'code': 'ALL', 'name': 'ALL', 'icon': 'Lek', 'color': const Color(0xFFE74C3C)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部拖拽指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 标题
              const Text(
                '选择法币',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // 搜索框
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '请输入法币',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 默认认选项
              Text(
                '默认',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              // CNY选项
              _buildFiatCurrencyItem(
                fiatCurrencies[0]['code'] as String,
                fiatCurrencies[0]['name'] as String,
                fiatCurrencies[0]['icon'] as String,
                fiatCurrencies[0]['color'] as Color,
                _selectedFiatCurrency == 'CNY',
              ),
              const SizedBox(height: 24),
              // 全部法币标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '全部法币',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  // 字母索引
                  Column(
                    children: [
                      Text('A', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('B', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                      Text('C', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 法币列表
              Expanded(
                child: ListView.separated(
                  itemCount: fiatCurrencies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) return const SizedBox.shrink(); // Skip CNY as it's shown above
                    final currency = fiatCurrencies[index];
                    return _buildFiatCurrencyItem(
                      currency['code'] as String,
                      currency['name'] as String,
                      currency['icon'] as String,
                      currency['color'] as Color,
                      _selectedFiatCurrency == currency['code'],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiatCurrencyItem(String code, String name, String icon, Color color, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _selectedFiatCurrency = code);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          // 法币图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 法币信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // 选中标记
          if (isSelected)
            const Icon(
              Icons.check,
              size: 24,
              color: Colors.black87,
            ),
        ],
      ),
    );
  }

  Widget _buildBuySellToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('我要买', true),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildToggleButton('我要卖', false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isBuy) {
    final isSelected = _isBuying == isBuy;
    return GestureDetector(
      onTap: () => setState(() => _isBuying = isBuy),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCurrencySelector(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAmountSelector(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPaymentSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector() {
    return GestureDetector(
      onTap: () => _showPaymentBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedPayment,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部拖拽指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 标题
                  Row(
                    children: [
                      const Text(
                        '支付方式',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 搜索框
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '搜索',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 支付方式选项
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentOption(
                          '全部',
                          _selectedPaymentMethods.isEmpty,
                          false,
                          setModalState,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentOption(
                          'QQ 钱包',
                          _selectedPaymentMethods.contains('QQ 钱包'),
                          true,
                          setModalState,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentOption(
                          '微信',
                          _selectedPaymentMethods.contains('微信'),
                          true,
                          setModalState,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPaymentOption(
                          '支付宝',
                          _selectedPaymentMethods.contains('支付宝'),
                          true,
                          setModalState,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    '银行借记卡',
                    _selectedPaymentMethods.contains('银行借记卡'),
                    true,
                    setModalState,
                  ),
                  const SizedBox(height: 16),
                  // 底部按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedPaymentMethods.clear();
                            });
                            setState(() => _selectedPayment = '支付');
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '重置',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedPaymentMethods.isNotEmpty) {
                              setState(() {
                                _selectedPayment = _selectedPaymentMethods.join(',');
                              });
                            } else {
                              setState(() => _selectedPayment = '支付');
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFF5C842),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '确认',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentOption(String label, bool isSelected, bool showIcon, StateSetter setModalState) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (label == '全部') {
            _selectedPaymentMethods.clear();
          } else {
            if (isSelected) {
              _selectedPaymentMethods.remove(label);
            } else {
              _selectedPaymentMethods.add(label);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected && label != '全部' ? Colors.grey.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            if (showIcon) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: Colors.orange.shade300,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSelector() {
    return GestureDetector(
      onTap: () => _showAmountBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedAmount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  void _showAmountBottomSheet() {
    // 清空之前的输入
    _amountController.clear();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部拖拽指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 标题
                Text(
                  _isBuying ? '我要买' : '我要卖',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 输入框
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '请输入总额',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        _selectedFiatCurrency,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 快捷金额按钮
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAmountButton('¥ 100'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAmountButton('¥ 1千'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAmountButton('¥ 1万'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAmountButton('¥ 10万'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 底部按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _selectedAmount = '金额');
                          _amountController.clear();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '重置',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_amountController.text.isNotEmpty) {
                            setState(() => _selectedAmount = _amountController.text);
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF5C842),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '确认',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () {
        // 提取数字部分
        String numericAmount = amount.replaceAll('¥', '').replaceAll(' ', '').trim();
        if (numericAmount.contains('千')) {
          numericAmount = numericAmount.replaceAll('千', '000');
        } else if (numericAmount.contains('万')) {
          numericAmount = numericAmount.replaceAll('万', '0000');
        }
        _amountController.text = numericAmount;
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        amount,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    // 获取当前选中币种的颜色
    Color getCurrencyColor(String currency) {
      switch (currency) {
        case 'USDT':
          return Colors.teal;
        case 'BTC':
          return Colors.orange;
        case 'ETH':
          return Colors.purple;
        case 'USDC':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () => _showCurrencyBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 币种图标
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: getCurrencyColor(_selectedCurrency),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _selectedCurrency[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedCurrency,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  void _showCurrencyBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部拖拽指示器
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 标题和取消按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选择币种',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 搜索框
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '选择币种',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 提示文字
              Text(
                '* 价格和比例仅供参考，实际价格以下单时为准。',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              // 币种标题
              Text(
                'C2C支持的数字货币',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              // 币种列表
              _buildCurrencyItem('USDT', '计价币种', Colors.teal),
              const SizedBox(height: 16),
              _buildCurrencyItem('BTC', '最知名币种', Colors.orange),
              const SizedBox(height: 16),
              _buildCurrencyItem('ETH', 'Ethereum', Colors.purple),
              const SizedBox(height: 16),
              _buildCurrencyItem('USDC', 'USDC', Colors.blue),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyItem(String symbol, String description, Color color) {
    return InkWell(
      onTap: () {
        setState(() => _selectedCurrency = symbol);
        Navigator.pop(context);
      },
      child: Row(
        children: [
          // 币种图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 币种信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
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

  Widget _buildFilterDropdown(String value, List<String> items, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            isExpanded: true,
            isDense: true,
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantList() {
    // Mock data
    final merchants = [
      {
        'name': '顺源资本-实名收付-安全快捷',
        'avatar': 'assets/images/avatar1.png',
        'orders': 77,
        'completionRate': 87.50,
        'price': 6.96,
        'minAmount': 70000.00,
        'maxAmount': 244624.00,
        'available': 35147.14,
        'paymentMethods': ['银行借记卡'],
        'timeLimit': '15 分钟',
        'verified': true,
        'badges': ['gold', 'shield'],
      },
      {
        'name': '大马壹号-大宗神盾-老商家',
        'avatar': 'assets/images/avatar2.png',
        'orders': 411,
        'completionRate': 95.60,
        'price': 6.97,
        'minAmount': 250000.00,
        'maxAmount': 918206.00,
        'available': 131736.95,
        'paymentMethods': ['银行借记卡'],
        'timeLimit': '15 分钟',
        'verified': true,
        'badges': ['purple', 'shield'],
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        return MerchantCard(
          merchant: merchants[index],
          currency: _selectedCurrency,
          fiatCurrency: _selectedFiatCurrency,
          isBuying: _isBuying,
        );
      },
    );
  }
}
