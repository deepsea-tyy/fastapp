import 'package:flutter/material.dart';

/// C2C订单详情页面
class C2COrderScreen extends StatefulWidget {
  final Map<String, dynamic> merchant;
  final String currency;
  final String fiatCurrency;
  final bool isBuying;
  final double price;

  const C2COrderScreen({
    super.key,
    required this.merchant,
    required this.currency,
    required this.fiatCurrency,
    required this.isBuying,
    required this.price,
  });

  @override
  State<C2COrderScreen> createState() => _C2COrderScreenState();
}

class _C2COrderScreenState extends State<C2COrderScreen> {
  bool _isAmountMode = true; // true: CNY模式, false: USDT模式
  final TextEditingController _amountController = TextEditingController();
  double _receivedAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountController.text = '0';
    _amountController.addListener(_calculateAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    final input = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      if (_isAmountMode) {
        // CNY转USDT
        _receivedAmount = input / widget.price;
      } else {
        // USDT转CNY
        _receivedAmount = input * widget.price;
      }
    });
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
        title: Text(
          '${widget.isBuying ? '买入' : '卖出'} ${widget.currency}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              '单价 ¥ ${widget.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountInputCard(),
            const SizedBox(height: 8),
            if (widget.isBuying) ...[
              _buildPaymentMethodSection(),
              const SizedBox(height: 8),
              _buildTradeInfoSection(),
              const SizedBox(height: 8),
              _buildTermsSection(),
              const SizedBox(height: 8),
              _buildMerchantInfoSection(),
            ] else ...[
              _buildSelectPaymentSection(),
              const SizedBox(height: 16),
              _buildSellTradeInfoSection(),
              const SizedBox(height: 16),
              _buildMerchantInfoSection(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAmountInputCard() {
    final minLimit = widget.merchant['minAmount'] as double;
    final maxLimit = widget.merchant['maxAmount'] as double;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 切换标签（仅买入时显示）
          if (widget.isBuying)
            Row(
              children: [
                _buildTab('CNY', _isAmountMode, true),
                const SizedBox(width: 8),
                _buildTab('USDT', !_isAmountMode, false),
              ],
            ),
          if (widget.isBuying) const SizedBox(height: 16),
          // 卖出模式的标签
          if (!widget.isBuying)
            Row(
              children: [
                _buildTab('CNY', false, true),
                const SizedBox(width: 8),
                _buildTab('USDT', true, false),
              ],
            ),
          if (!widget.isBuying) const SizedBox(height: 16),
          // 输入区域
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.isBuying
                            ? (_isAmountMode ? 'CNY' : widget.currency)
                            : widget.currency,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (widget.isBuying) {
                            final maxAmount = widget.merchant['maxAmount'] as double;
                            _amountController.text = maxAmount.toStringAsFixed(2);
                          } else {
                            // 卖出模式显示全部可用余额
                            _amountController.text = '0'; // TODO: 替换为实际余额
                          }
                        },
                        child: Text(
                          widget.isBuying ? '最大' : '全部',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF5C842),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 限额显示
          Text(
            widget.isBuying
                ? '限额 ${_formatAmount(minLimit)} - ${_formatAmount(maxLimit)} ${widget.fiatCurrency}'
                : '限额 ${_formatUSDTAmount(minLimit / widget.price)} - ${_formatUSDTAmount(maxLimit / widget.price)} ${widget.currency}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if (!widget.isBuying) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '资产 0 ${widget.currency}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // 收到金额
          Text(
            widget.isBuying
                ? '您收到 ${_receivedAmount.toStringAsFixed(2)} ${_isAmountMode ? widget.currency : widget.fiatCurrency}'
                : '您收到 ${_receivedAmount.toStringAsFixed(2)} ${widget.fiatCurrency}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUSDTAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  Widget _buildTab(String label, bool isSelected, bool isCNY) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAmountMode = isCNY;
          _calculateAmount();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5C842) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '选择收款方式',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildSellTradeInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow('付款时限', '30 分钟', true),
          const SizedBox(height: 12),
          _buildInfoRow('广告方状态', '在线', false, statusDot: true),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    final paymentMethods = widget.merchant['paymentMethods'] as List<dynamic>? ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFF5C842),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            paymentMethods.isNotEmpty ? paymentMethods[0] : '银行借记卡',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow('付款时限', '15 分钟', true),
          const SizedBox(height: 12),
          _buildInfoRow('广告方状态', '1 小时前在线', false, statusDot: true),
          const SizedBox(height: 12),
          _buildInfoRow('安全验证', '> 5,000.00CNY', false),
          const SizedBox(height: 12),
          _buildInfoRow('提现保护', '交易之星', false),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTime, {bool statusDot = false}) {
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
            if (statusDot)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isTime ? Colors.black87 : Colors.grey.shade700,
                fontWeight: isTime ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'C2C交易须知',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '需提供带照片的身份证件',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildTermItem('1.请提供近期银行卡至少2张的支票明细截图，ATM存款、现存资金、外汇资金不支持，必要时提供录屏、请悉周配合。'),
          _buildTermItem('2.收支明细画面包含以下信息（当前账户余额且大于本次订单金额），同时显示同账户产生时间和账户持有人信息不予交易。'),
          _buildTermItem('3.不接受7天内有他人转入的资金(政府、理财、股票、银证转帐除外)、同名卡转入账户仅接受实业收入和工资流入订单。'),
          _buildTermItem('4.卖方付款，转账IC"备注信息"，付款后需要提供银行卡卡号的交易流水（收支明细）截图'),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMerchantInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.merchant['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5C842),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5C842),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '30 日成单率 | 计数',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.merchant['completionRate'].toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.merchant['orders']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '平均放行时间',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            // TODO: 处理下单
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isBuying ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            '确定下单',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    if (amount is int) {
      return amount.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else if (amount is double) {
      return amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return amount.toString();
  }
}
