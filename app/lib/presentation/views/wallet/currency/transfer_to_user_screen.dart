import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 转账给用户页面
class TransferToUserScreen extends StatefulWidget {
  const TransferToUserScreen({super.key});

  @override
  State<TransferToUserScreen> createState() => _TransferToUserScreenState();
}

class _TransferToUserScreenState extends State<TransferToUserScreen> {
  final WalletStore _walletStore = getIt<WalletStore>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  String? _selectedCurrency;
  int _selectedInputMethod = 0; // 0: 邮箱, 1: 手机号, 2: ID

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Balance? _getBalance([String? symbol]) {
    final curr = symbol ?? _selectedCurrency;
    if (curr == null) return null;
    return _walletStore.accountBalance?.getBalance(WalletType.FUNDING, curr);
  }

  List<String> _getAvailableCurrencies() {
    final balances = _walletStore.accountBalance?.getBalancesByType(WalletType.FUNDING);
    if (balances == null || balances.isEmpty) return [];
    return balances.where((b) => b.available > 0).map((b) => b.symbol).toList();
  }

  Future<void> _selectCurrency() async {
    final availableCurrencies = _getAvailableCurrencies();

    if (availableCurrencies.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('资金账户暂无可转账资产'),
            duration: Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('转账给用户'),
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
                  _buildInputMethodSelector(),
                  const SizedBox(height: 16),
                  _buildRecipientInput(),
                  const SizedBox(height: 16),
                  _buildCurrencySelection(availableBalance),
                  const SizedBox(height: 16),
                  _buildAmountInput(availableBalance),
                  const SizedBox(height: 16),
                  _buildRemarkInput(),
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

  Widget _buildInputMethodSelector() {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('收款方式', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMethodChip('邮箱', 0),
            const SizedBox(width: 12),
            _buildMethodChip('手机号', 1),
            const SizedBox(width: 12),
            _buildMethodChip('用户ID', 2),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodChip(String label, int index) {
    final isSelected = _selectedInputMethod == index;
    final theme = Theme.of(context);
    final backgroundTheme = context.backgroundTheme;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedInputMethod = index;
          _recipientController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : backgroundTheme.input,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : textTheme.secondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientInput() {
    final textTheme = context.textTheme;
    String hint;
    switch (_selectedInputMethod) {
      case 0:
        hint = '请输入收款人邮箱';
        break;
      case 1:
        hint = '请输入收款人手机号';
        break;
      case 2:
        hint = '请输入收款人ID';
        break;
      default:
        hint = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('收款人', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: TextField(
            controller: _recipientController,
            keyboardType: _selectedInputMethod == 1
                ? TextInputType.phone
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
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
      ],
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
              '当前币种无可转账资产，请选择其他币种',
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
        Text('转账金额', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '请输入转账金额',
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
                  child: Text('全部', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
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

  Widget _buildRemarkInput() {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('备注(可选)', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: TextField(
            controller: _remarkController,
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: '添加转账备注',
              hintStyle: TextStyle(color: textTheme.hint, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
            style: TextStyle(fontSize: 14, color: textTheme.primary),
          ),
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
    final isEnabled = _recipientController.text.isNotEmpty &&
        _selectedCurrency != null &&
        _amountController.text.isNotEmpty &&
        availableBalance > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleConfirm : null,
        child: const Text(
          '确认转账',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleConfirm() {
    // TODO: 执行转账逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认转账'),
        content: Text(
          '转账给: ${_recipientController.text}\n'
          '金额: ${_amountController.text} $_selectedCurrency\n'
          '备注: ${_remarkController.text.isEmpty ? '无' : _remarkController.text}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 调用转账接口
            },
            child: const Text('确认'),
          ),
        ],
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
