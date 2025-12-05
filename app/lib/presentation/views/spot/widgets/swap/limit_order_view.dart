import 'package:flutter/material.dart';
import 'currency_selector.dart';
import 'swap_button.dart';

/// 限价交易页面 - 限价订单
class LimitOrderView extends StatefulWidget {
  const LimitOrderView({super.key});

  @override
  State<LimitOrderView> createState() => _LimitOrderViewState();
}

class _LimitOrderViewState extends State<LimitOrderView> {
  String _fromCurrency = 'TON';
  String _toCurrency = 'USDT';
  String _fromAmount = '0.0063';
  String _toAmount = '0.01';
  String _fromBalance = '0.00079';
  String _toBalance = '71000';
  String _fromMinAmount = '44000';
  String _toMinAmount = '71000';
  String _limitPrice = '1.599'; // 限价
  String _validityPeriod = '30 天后失效'; // 有效期
  int _currentOrdersCount = 0; // 当前委托数量

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFromSection(),
                const SizedBox(height: 16),
                Center(child: SwapButton(onPressed: _handleSwapCurrencies)),
                const SizedBox(height: 16),
                _buildToSection(),
                const SizedBox(height: 24),
                _buildPriceSection(),
                const SizedBox(height: 24),
                _buildValidityPeriodSection(),
                const SizedBox(height: 24),
                _buildPreviewButton(),
                const SizedBox(height: 24),
                _buildCurrentOrdersSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSwapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      
      final tempAmount = _fromAmount;
      _fromAmount = _toAmount;
      _toAmount = tempAmount;
      
      final tempBalance = _fromBalance;
      _fromBalance = _toBalance;
      _toBalance = tempBalance;
    });
  }


  Widget _buildFromSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '从',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Row(
              children: [
                Text(
                  '可用 ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  '$_fromBalance $_fromCurrency',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5C842),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrencySelector(
              currency: _fromCurrency,
              isPrimary: true,
              onTap: () {
                // TODO: 显示货币选择对话框
              },
            ),
            Expanded(
              child: Text(
                '$_fromAmount - $_fromMinAmount',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '最大',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '至',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrencySelector(
              currency: _toCurrency,
              isPrimary: true,
              onTap: () {
                // TODO: 显示货币选择对话框
              },
            ),
            Expanded(
              child: Text(
                '$_toAmount - $_toMinAmount',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '价格',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrencySelector(
              currency: _toCurrency,
              isPrimary: true,
              onTap: () {},
            ),
            Expanded(
              child: Text(
                _limitPrice,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValidityPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '有效期',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showValidityPeriodPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _validityPeriod,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showValidityPeriodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildValidityOption('7 天后失效'),
              _buildValidityOption('30 天后失效'),
              _buildValidityOption('60 天后失效'),
              _buildValidityOption('90 天后失效'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValidityOption(String period) {
    return ListTile(
      title: Text(period),
      trailing: _validityPeriod == period ? const Icon(Icons.check, color: Color(0xFFF5C842)) : null,
      onTap: () {
        setState(() => _validityPeriod = period);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCurrentOrdersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '当前委托 ($_currentOrdersCount)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (_currentOrdersCount > 0)
            TextButton(
              onPressed: () {
                // TODO: 显示委托列表
              },
              child: const Text('查看全部'),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showPreviewDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5C842),
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '预览',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showPreviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '预览订单',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildPreviewRow('从', '$_fromAmount $_fromCurrency'),
                  _buildDivider(),
                  _buildPreviewRow('至', '$_toAmount $_toCurrency'),
                  _buildDivider(),
                  _buildPreviewRow('价格', '$_limitPrice $_toCurrency'),
                  _buildDivider(),
                  _buildPreviewRow('有效期', _validityPeriod),
                  _buildDivider(),
                  _buildPreviewRow('交易手续费', '0 USDT'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _createLimitOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5C842),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '确认',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
    );
  }

  void _createLimitOrder() {
    // TODO: 实现创建限价订单的 API 调用
    setState(() => _currentOrdersCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('限价订单创建成功'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
