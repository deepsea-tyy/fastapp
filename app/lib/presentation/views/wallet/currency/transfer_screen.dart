import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/domain/repository/wallet_repository.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/currency/account_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 划转页面
class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const _accountNames = {
    WalletType.FUNDING: '资金账户',
    WalletType.SPOT: '现货账户',
    WalletType.FUTURES: 'U本位合约账户',
    WalletType.MARGIN: '杠杆账户',
    WalletType.OPTIONS: '期权账户',
    WalletType.EARN: '赚币账户',
  };

  final WalletStore _walletStore = getIt<WalletStore>();
  final WalletRepository _walletRepository = getIt<WalletRepository>();
  WalletType _fromAccount = WalletType.FUTURES;
  WalletType _toAccount = WalletType.SPOT;
  String? _selectedCurrency;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _getAccountName(WalletType type) => _accountNames[type]!;

  Balance? _getBalance([String? symbol]) {
    final curr = symbol ?? _selectedCurrency;
    if (curr == null) return null;
    return _walletStore.accountBalance?.getBalance(_fromAccount, curr);
  }

  List<String> _getAvailableCurrencies() {
    final balances = _walletStore.accountBalance?.getBalancesByType(_fromAccount);
    if (balances == null || balances.isEmpty) return [];
    return balances.where((b) => b.available > 0).map((b) => b.symbol).toList();
  }

  void _validateAndClearCurrency() {
    if (_selectedCurrency != null) {
      final balance = _getBalance();
      if (balance == null || balance.available <= 0) {
        _selectedCurrency = null;
        _amountController.clear();
      }
    }
  }

  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
      _validateAndClearCurrency();
    });
  }

  Future<void> _selectAccount(bool isFromAccount) async {
    final result = await Navigator.of(context).push<WalletType>(
      MaterialPageRoute(
        builder: (context) => AccountSelect(
          currentAccount: isFromAccount ? _fromAccount : _toAccount,
          excludeAccount: isFromAccount ? _toAccount : _fromAccount,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isFromAccount) {
          _fromAccount = result;
          _validateAndClearCurrency();
        } else {
          _toAccount = result;
        }
      });
    }
  }

  Future<void> _selectCurrency() async {
    final availableCurrencies = _getAvailableCurrencies();

    if (availableCurrencies.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getAccountName(_fromAccount)}暂无可划转资产'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final currency = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildCurrencyPicker(availableCurrencies),
    );

    if (currency != null) {
      setState(() {
        _selectedCurrency = currency;
        _amountController.clear();
      });
    }
  }

  void _fillMaxAmount(double availableBalance) {
    if (availableBalance > 0) {
      _amountController.text = availableBalance.toString();
      setState(() {});
    }
  }

  Future<void> _confirmTransfer() async {
    if (_selectedCurrency == null || _amountController.text.isEmpty) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入有效的划转数量')),
        );
      }
      return;
    }

    final availableBalance = _getBalance()?.available ?? 0.0;
    if (amount > availableBalance) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('划转数量不能超过可用余额')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _walletRepository.transfer(
        fromWalletType: _fromAccount.name,
        toWalletType: _toAccount.name,
        symbol: _selectedCurrency!,
        amount: _amountController.text,
      );

      // 刷新余额
      await _walletStore.loadAsset();

      // 返回上一页
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('划转失败: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('划转'),
      ),
      body: Observer(
        builder: (_) {
          final availableBalance = _getBalance()?.available ?? 0.0;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountSelection(),
                  const SizedBox(height: 16),
                  _buildCurrencySelection(availableBalance),
                  const SizedBox(height: 16),
                  _buildAmountInput(availableBalance),
                  const SizedBox(height: 32),
                  _buildConfirmButton(availableBalance),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSelection() {
    final backgroundTheme = context.backgroundTheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAccountSelector(
            label: '从',
            account: _getAccountName(_fromAccount),
            onTap: () => _selectAccount(true),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _swapAccounts,
            child: Icon(Icons.swap_vert, size: 24, color: textTheme.secondary),
          ),
          const SizedBox(height: 12),
          _buildAccountSelector(
            label: '到',
            account: _getAccountName(_toAccount),
            onTap: () => _selectAccount(false),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSelector({
    required String label,
    required String account,
    required VoidCallback onTap,
  }) {
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: textTheme.secondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(account, style: TextStyle(fontSize: 14, color: textTheme.primary)),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: textTheme.hint),
        ],
      ),
    );
  }

  Widget _buildCurrencySelection(double availableBalance) {
    final textTheme = context.textTheme;
    final statusTheme = context.statusTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('币种', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          onTap: _selectCurrency,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCurrency ?? '请选择币种',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedCurrency != null ? textTheme.primary : textTheme.hint,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: textTheme.hint),
            ],
          ),
        ),
        if (_selectedCurrency != null && availableBalance == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '当前币种无可划转资产，请选择其他币种',
              style: TextStyle(fontSize: 12, color: statusTheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildAmountInput(double availableBalance) {
    final textTheme = context.textTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('数量', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '请输入数量',
                    hintStyle: TextStyle(color: textTheme.hint, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 14, color: textTheme.primary),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_selectedCurrency != null) ...[
                Text(_selectedCurrency!, style: TextStyle(fontSize: 14, color: textTheme.primary)),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _fillMaxAmount(availableBalance),
                  child: Text('最大', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '可用 ${availableBalance.toStringAsFixed(8)} ${_selectedCurrency ?? ''}',
          style: TextStyle(fontSize: 12, color: textTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildFieldContainer({VoidCallback? onTap, required Widget child}) {
    final backgroundTheme = context.backgroundTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundTheme.input,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  Widget _buildConfirmButton(double availableBalance) {
    final isEnabled = !_isLoading &&
        _selectedCurrency != null &&
        _amountController.text.isNotEmpty &&
        availableBalance > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _confirmTransfer : null,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                '确认划转',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCurrencyPicker(List<String> currencies) {
    final textTheme = context.textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '选择币种',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textTheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final symbol = currencies[index];
                final balance = _getBalance(symbol);
                return ListTile(
                  title: Text(symbol),
                  subtitle: Text('可用: ${balance?.available.toStringAsFixed(8) ?? '0'}'),
                  selected: _selectedCurrency == symbol,
                  onTap: () => Navigator.of(context).pop(symbol),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
