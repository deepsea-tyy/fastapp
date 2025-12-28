import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 充币页面
class DepositScreen extends StatefulWidget {
  final String symbol;
  final String? name;

  const DepositScreen({
    super.key,
    required this.symbol,
    this.name,
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String? _selectedNetwork;
  final List<Map<String, dynamic>> _networks = [
    {
      'name': 'TRC20',
      'minDeposit': '10 USDT',
      'confirmations': '1',
      'address': 'TXg7KqLhQzMsVx4N8RqZP6vY3WnJdKfGhL',
      'memo': '',
    },
    {
      'name': 'ERC20',
      'minDeposit': '10 USDT',
      'confirmations': '12',
      'address': '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb2',
      'memo': '',
    },
    {
      'name': 'BEP20',
      'minDeposit': '10 USDT',
      'confirmations': '15',
      'address': '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
      'memo': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedNetwork = _networks.first['name'];
  }

  String get _currentAddress {
    final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
    return network['address'] ?? '';
  }

  String get _currentMemo {
    final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
    return network['memo'] ?? '';
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label已复制'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('充币 ${widget.symbol}'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 跳转到充币历史
            },
            child: const Text('历史'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarningBanner(),
              const SizedBox(height: 16),
              _buildNetworkSelection(),
              const SizedBox(height: 24),
              _buildQRCode(),
              const SizedBox(height: 24),
              _buildAddressSection(),
              if (_currentMemo.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildMemoSection(),
              ],
              const SizedBox(height: 24),
              _buildNetworkInfo(),
              const SizedBox(height: 16),
              _buildTipsSection(),
            ],
          ),
        ),
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
              '请勿向该地址充值任何非${widget.symbol}资产，否则资产将不可找回',
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
        Text(
          '充币网络',
          style: TextStyle(
            fontSize: 14,
            color: textTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectNetwork,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: backgroundTheme.input,
              borderRadius: BorderRadius.circular(8),
            ),
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
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    final borderTheme = context.borderTheme;
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderTheme.defaultColor),
        ),
        child: QrImageView(
          data: _currentAddress,
          version: QrVersions.auto,
          size: 200,
          backgroundColor: theme.cardColor,
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '充币地址',
          style: TextStyle(
            fontSize: 14,
            color: textTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundTheme.input,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                _currentAddress,
                style: TextStyle(fontSize: 14, color: textTheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(_currentAddress, '充币地址'),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('复制地址'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemoSection() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memo',
          style: TextStyle(
            fontSize: 14,
            color: textTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundTheme.input,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                _currentMemo,
                style: TextStyle(fontSize: 14, color: textTheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _copyToClipboard(_currentMemo, 'Memo'),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('复制Memo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkInfo() {
    final network = _networks.firstWhere((n) => n['name'] == _selectedNetwork);
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundTheme.input,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '网络信息',
            style: TextStyle(
              fontSize: 14,
              color: textTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('最小充值数量', network['minDeposit']),
          const SizedBox(height: 8),
          _buildInfoRow('网络确认数', '${network['confirmations']} 个区块确认'),
          const SizedBox(height: 8),
          _buildInfoRow('到账时间', '${network['confirmations']} 个区块确认后到账'),
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
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: textTheme.primary),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    final statusTheme = context.statusTheme;
    final textTheme = context.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusTheme.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusTheme.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusTheme.info, size: 16),
              const SizedBox(width: 8),
              Text(
                '温馨提示',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('最小充值数量小于最小数量的充值将不会上账且无法退回'),
          const SizedBox(height: 8),
          _buildTipItem('您充值至以上地址后，需要整个网络节点的确认'),
          const SizedBox(height: 8),
          _buildTipItem('充值成功后可在历史记录中查看'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    final statusTheme = context.statusTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: statusTheme.info,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: statusTheme.info),
          ),
        ),
      ],
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
                  subtitle: Text('最小充值: ${network['minDeposit']} · 确认数: ${network['confirmations']}'),
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
