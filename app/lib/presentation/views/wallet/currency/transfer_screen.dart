import 'package:fastapp/presentation/views/wallet/currency/currency_select.dart';
import 'package:flutter/material.dart';

/// 划转页面
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _fromAccount = 'U本位合约账户';
  String _toAccount = '现货账户';
  String? _selectedCurrency;
  final TextEditingController _amountController = TextEditingController();
  String _availableBalance = '--';

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '划转',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              // TODO: 跳转到划转历史
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 账户选择区域
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildAccountSelector(
                      label: '从',
                      account: _fromAccount,
                      onTap: () {
                        // TODO: 选择来源账户
                      },
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Icon(
                        Icons.swap_vert,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAccountSelector(
                      label: '到',
                      account: _toAccount,
                      onTap: () {
                        // TODO: 选择目标账户
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 币种选择
              const Text(
                '币种',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final currency = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CurrencySelect(),
                    ),
                  );
                  if (currency != null) {
                    setState(() {
                      _selectedCurrency = currency;
                      _availableBalance = '--';
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCurrency ?? '请选择币种',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedCurrency != null
                              ? Colors.black87
                              : Colors.grey.shade400,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedCurrency != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '当前币种无可划转资产，请选择其他币种',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // 数量输入
              const Text(
                '数量',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '请输入数量',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_selectedCurrency != null) ...[
                      Text(
                        _selectedCurrency!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // TODO: 填入最大可用余额
                          _amountController.text = _availableBalance;
                        },
                        child: Text(
                          '最大',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '可用$_availableBalance ${_selectedCurrency ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              // 确认划转按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCurrency != null &&
                          _amountController.text.isNotEmpty
                      ? () {
                          // TODO: 执行划转
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade200,
                    foregroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '确认划转',
                    style: TextStyle(
                      fontSize: 16,
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
  }

  Widget _buildAccountSelector({
    required String label,
    required String account,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              account,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
