import 'package:flutter/material.dart';
import 'currency_selector.dart';

/// 定投交易页面 - 定期定额投资
class RecurringInvestmentView extends StatefulWidget {
  const RecurringInvestmentView({super.key});

  @override
  State<RecurringInvestmentView> createState() => _RecurringInvestmentViewState();
}

class _RecurringInvestmentViewState extends State<RecurringInvestmentView> {
  String _fromCurrency = 'USDT';
  String _toCurrency = 'TON';
  String _investmentAmount = '100';
  String _frequency = '每日, 00:00 (UTC+8)'; // 频率
  String _targetWallet = '现货账户'; // 目标钱包
  String _planName = 'TON 定投计划'; // 计划名称
  String _maxDuration = '--'; // 最长期限
  String _limitPrice = '--'; // 限价
  int _recurringPlansCount = 0; // 定投计划数量
  String _exchangeRate = '0.000023';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvestmentAmountSection(),
          const SizedBox(height: 24),
          _buildTargetCurrencySection(),
          const SizedBox(height: 24),
          _buildFrequencyDropdown(),
          const SizedBox(height: 16),
          _buildTargetWalletDropdown(),
          const SizedBox(height: 16),
          _buildPlanNameDropdown(),
          const SizedBox(height: 16),
          _buildMaxDurationDropdown(),
          const SizedBox(height: 16),
          _buildLimitPriceDropdown(),
          const SizedBox(height: 24),
          _buildActionButton(),
          const SizedBox(height: 16),
          _buildRecurringPlansSection(),
        ],
      ),
    );
  }

  Widget _buildInvestmentAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投资金额',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CurrencySelector(
              currency: _fromCurrency,
              isPrimary: false,
              onTap: () {
                // TODO: 显示货币选择对话框
              },
            ),
            Expanded(
              child: Text(
                _investmentAmount,
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '≈ ¥ ${(double.parse(_investmentAmount) * 7.2).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '买入币种',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        CurrencySelector(
          currency: _toCurrency,
          isPrimary: true,
          onTap: () {
            // TODO: 显示货币选择对话框
          },
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown() {
    return _buildDropdownField('频率', _frequency, () {
      _showFrequencyPicker();
    });
  }

  Widget _buildTargetWalletDropdown() {
    return _buildDropdownField('目标钱包', _targetWallet, () {
      _showTargetWalletPicker();
    });
  }

  Widget _buildPlanNameDropdown() {
    return _buildDropdownField('计划名称', _planName, () {
      _showPlanNamePicker();
    });
  }

  Widget _buildMaxDurationDropdown() {
    return _buildDropdownField('最长期限', _maxDuration, () {
      _showMaxDurationPicker();
    });
  }

  Widget _buildLimitPriceDropdown() {
    return _buildDropdownField('限价', _limitPrice, () {
      _showLimitPricePicker();
    });
  }

  Widget _buildDropdownField(String label, String value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildRecurringPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '定投计划 ($_recurringPlansCount)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                '暂无记录',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5C842).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: null, // 禁用状态
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.grey.shade400,
        ),
        child: const Text(
          '创建计划',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showFrequencyPicker() {
    // TODO: 实现频率选择器
  }

  void _showTargetWalletPicker() {
    // TODO: 实现目标钱包选择器
  }

  void _showPlanNamePicker() {
    // TODO: 实现计划名称选择器
  }

  void _showMaxDurationPicker() {
    // TODO: 实现最长期限选择器
  }

  void _showLimitPricePicker() {
    // TODO: 实现限价选择器
  }
}
