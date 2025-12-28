import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 提币页面
class WithdrawScreen extends StatefulWidget {
  final String symbol;
  final String? name;

  const WithdrawScreen({
    super.key,
    required this.symbol,
    this.name,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final WalletStore _walletStore = getIt<WalletStore>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  String? _selectedNetwork;
  final List<Map<String, dynamic>> _networks = [
    {'name': 'TRC20', 'fee': '1 USDT', 'minAmount': '10 USDT', 'arrivalTime': '2分钟'},
    {'name': 'ERC20', 'fee': '5 USDT', 'minAmount': '10 USDT', 'arrivalTime': '5分钟'},
    {'name': 'BEP20', 'fee': '0.5 USDT', 'minAmount': '10 USDT', 'arrivalTime': '3分钟'},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Balance? _getBalance() {
    return _walletStore.accountBalance?.getBalance(WalletType.SPOT, widget.symbol);
  }

  void _fillMaxAmount(double availableBalance) {
    if (availableBalance > 0 && _selectedNetwork != null) {
      final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
      final fee = double.tryParse(network['fee'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      final maxAmount = availableBalance - fee;
      if (maxAmount > 0) {
        _amountController.text = maxAmount.toString();
        setState(() {});
      }
    }
  }

  Future<void> _selectNetwork() async {
    final network = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildNetworkPicker(),
    );

    if (network != null) {
      setState(() => _selectedNetwork = network);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提币 ${widget.symbol}'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 跳转到提币历史
            },
            child: const Text('历史'),
          ),
        ],
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
                  _buildWarningBanner(),
                  const SizedBox(height: 16),
                  _buildNetworkSelection(),
                  const SizedBox(height: 16),
                  _buildAddressInput(),
                  const SizedBox(height: 16),
                  _buildMemoInput(),
                  const SizedBox(height: 16),
                  _buildAmountInput(availableBalance),
                  if (_selectedNetwork != null) ...[
                    const SizedBox(height: 16),
                    _buildNetworkInfo(),
                  ],
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

  Widget _buildWarningBanner() {
    final statusTheme = context.statusTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusTheme.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: statusTheme.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '请勿向非${widget.symbol}地址充值任何资产，否则资产将不可找回',
              style: TextStyle(fontSize: 12, color: statusTheme.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelection() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('网络', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          onTap: _selectNetwork,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedNetwork ?? '请选择网络',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedNetwork != null ? textTheme.primary : textTheme.hint,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: textTheme.hint),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInput() {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('提币地址', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: '请输入或粘贴提币地址',
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
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                color: textTheme.secondary,
                onPressed: () {
                  // TODO: 扫描二维码
                },
              ),
              IconButton(
                icon: const Icon(Icons.content_paste, size: 20),
                color: textTheme.secondary,
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _addressController.text = data!.text!;
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoInput() {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Memo', style: TextStyle(fontSize: 14, color: textTheme.primary)),
            const SizedBox(width: 4),
            Text('(选填)', style: TextStyle(fontSize: 12, color: textTheme.secondary)),
          ],
        ),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: TextField(
            controller: _memoController,
            decoration: InputDecoration(
              hintText: '请输入Memo/Tag',
              hintStyle: TextStyle(color: textTheme.hint, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: 14, color: textTheme.primary),
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
        Text('提币数量', style: TextStyle(fontSize: 14, color: textTheme.primary)),
        const SizedBox(height: 8),
        _buildFieldContainer(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '请输入提币数量',
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
              Text(widget.symbol, style: TextStyle(fontSize: 14, color: textTheme.primary)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _fillMaxAmount(availableBalance),
                child: Text('全部', style: TextStyle(fontSize: 14, color: theme.colorScheme.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '可用 ${availableBalance.toStringAsFixed(8)} ${widget.symbol}',
          style: TextStyle(fontSize: 12, color: textTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildNetworkInfo() {
    final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('手续费', network['fee']),
          const SizedBox(height: 8),
          _buildInfoRow('最小提币数量', network['minAmount']),
          const SizedBox(height: 8),
          _buildInfoRow('预计到账时间', network['arrivalTime']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final textTheme = context.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: textTheme.secondary)),
        Text(value, style: TextStyle(fontSize: 12, color: textTheme.primary)),
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
    final theme = Theme.of(context);
    final isEnabled = _addressController.text.isNotEmpty &&
        _selectedNetwork != null &&
        _amountController.text.isNotEmpty &&
        availableBalance > 0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleConfirm : null,
        child: const Text(
          '确认提币',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleConfirm() {
    final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认提币'),
        content: Text(
          '网络: $_selectedNetwork\n'
          '地址: ${_addressController.text}\n'
          '数量: ${_amountController.text} ${widget.symbol}\n'
          '手续费: ${network['fee']}\n'
          '${_memoController.text.isNotEmpty ? 'Memo: ${_memoController.text}\n' : ''}'
          '预计到账: ${network['arrivalTime']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 调用提币接口
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('提币申请已提交')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkPicker() {
    final textTheme = context.textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                  '选择网络',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textTheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _networks.length,
              itemBuilder: (context, index) {
                final network = _networks[index];
                return ListTile(
                  title: Text(network['name']),
                  subtitle: Text('手续费: ${network['fee']} · 到账时间: ${network['arrivalTime']}'),
                  selected: _selectedNetwork == network['name'],
                  onTap: () => Navigator.pop(context, network['name']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
