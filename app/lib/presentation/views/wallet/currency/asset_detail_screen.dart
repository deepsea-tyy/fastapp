import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/market/ticker_data.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/presentation/store/wallet/balance_log_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_currency_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/common/balance_log_detail_item.dart';
import 'package:fastapp/presentation/views/wallet/widgets/common/balance_log_simple_item.dart';
import 'package:fastapp/presentation/views/wallet/widgets/overview/currency_formatter.dart';
import 'package:fastapp/utils/balance_log_utils.dart';
import 'package:fastapp/utils/image_utils.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 资产详情页面
class AssetDetailScreen extends StatefulWidget {
  final String symbol;
  final String name;
  final Color iconColor;
  final String iconText;
  final WalletType walletType;

  const AssetDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.iconColor,
    required this.iconText,
    required this.walletType,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}
class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final WalletStore _walletStore = getIt<WalletStore>();
  final MarketStore _marketStore = getIt<MarketStore>();
  final MarketDataStore _marketDataStore = getIt<MarketDataStore>();
  final WalletCurrencyStore _walletCurrencyStore = getIt<WalletCurrencyStore>();
  final BalanceLogStore _balanceLogStore = getIt<BalanceLogStore>();

  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    // 确保数据已加载
    if (_walletStore.accountBalance == null) {
      _walletStore.loadAsset();
    }
    // 加载当前币种的历史记录
    _balanceLogStore.setSelectedWalletType(widget.walletType.name);
    _balanceLogStore.setSelectedSymbol(widget.symbol);
    _balanceLogStore.loadLogs();
  }

  // 刷新数据
  Future<void> _refreshData() async {
    await _walletStore.refreshAsset();
  }

  // 获取当前账户中当前币种的余额
  Balance? _getBalance() {
    return _walletStore.accountBalance?.getBalance(widget.walletType, widget.symbol);
  }

  // 获取账户类型显示名称
  String _getWalletTypeName() {
    switch (widget.walletType) {
      case WalletType.SPOT:
        return '现货账户';
      case WalletType.FUNDING:
        return '资金账户';
      case WalletType.FUTURES:
        return '合约账户';
      case WalletType.OPTIONS:
        return '期权账户';
      case WalletType.MARGIN:
        return '杠杆账户';
      case WalletType.EARN:
        return '理财账户';
    }
  }

  // 获取价格数据
  TickerData? _getTicker() {
    if (widget.symbol == 'USDT') return null;

    final tickerList = _marketStore.tickerList;
    final possibleSymbols = [
      '${widget.symbol}_USDT',
      '${widget.symbol}/USDT',
      '${widget.symbol}USDT',
    ];

    for (final tickerSymbol in possibleSymbols) {
      try {
        return tickerList.firstWhere((t) => t.symbol == tickerSymbol);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // 计算USDT价值
  double _calculateUsdtValue(double amount) {
    if (widget.symbol == 'USDT') return amount;
    final ticker = _getTicker();
    return ticker != null ? amount * ticker.lastPrice : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    // 获取币种信息以显示logo
    final currency = _marketDataStore.getCurrency(widget.symbol);
    final logoUrl = currency?.logo != null
        ? ImageUtils.formatSingleImagePath(currency!.logo)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: backgroundTheme.input,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl != null
                  ? Image.network(
                      logoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          widget.iconText,
                          style: TextStyle(
                            color: textTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.iconText,
                        style: TextStyle(
                          color: textTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.symbol,
              style: TextStyle(
                color: textTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final balance = _getBalance();
          final quoteCurrency = _walletCurrencyStore.currency;
          final isLoading = _walletStore.isLoadingAsset;

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading && balance == null)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    _buildBalanceSection(balance, quoteCurrency),
                  const SizedBox(height: 24),
                  _buildHistorySection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBalanceSection(Balance? balance, String quoteCurrency) {
    final textTheme = context.textTheme;

    // 如果没有余额数据，显示加载状态或空数据
    if (balance == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getWalletTypeName()}余额',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: textTheme.secondary,
              ),
            ),
          ],
        ),
      );
    }

    // 计算USDT等值
    final usdtValue = _calculateUsdtValue(balance.total);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getWalletTypeName()}余额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textTheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  _balanceVisible ? Icons.visibility : Icons.visibility_off,
                  color: textTheme.secondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _balanceVisible = !_balanceVisible;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _balanceVisible ? balance.total.toStringAsFixed(8) : '****',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _balanceVisible
                    ? '≈ ${CurrencyFormatter.formatFiatCurrencyForApprox(quoteCurrency)}${usdtValue.toStringAsFixed(2)}'
                    : '',
                style: TextStyle(
                  fontSize: 14,
                  color: textTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo('可用余额', _balanceVisible ? balance.available.toStringAsFixed(8) : '****'),
              ),
              Expanded(
                child: _buildBalanceInfo('不可用', _balanceVisible ? balance.frozen.toStringAsFixed(8) : '****'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo(
                  '平均成本',
                  balance.avgPrice != null
                      ? '${balance.avgPrice!.toStringAsFixed(2)} USDT'
                      : '--',
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _buildBalanceInfo(
                      '今日盈亏',
                      balance.profit != null
                          ? '${balance.profit! >= 0 ? '+' : ''}${balance.profit!.toStringAsFixed(8)} USDT'
                          : '--',
                      valueColor: balance.profit != null
                          ? (balance.profit! >= 0 ? context.statusTheme.success : context.statusTheme.error)
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: context.textTheme.hint),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String value, {Color? valueColor}) {
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textTheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? textTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Observer(
      builder: (_) {
        final logs = _balanceLogStore.logs;
        final isLoading = _balanceLogStore.isLoading;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '历史',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textTheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Row(
                      children: [
                        Text(
                          _getFilterLabel(),
                          style: TextStyle(
                            fontSize: 14,
                            color: textTheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 16, color: textTheme.secondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading && logs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (logs.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: backgroundTheme.input,
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.description, size: 40, color: textTheme.hint),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Icon(Icons.search, size: 20, color: textTheme.hint),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无历史记录',
                        style: TextStyle(
                          fontSize: 14,
                          color: textTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    ...logs.take(5).map((log) => BalanceLogSimpleItem(
                          log: log,
                          onTap: _showAllHistory,
                        )),
                    if (logs.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextButton(
                          onPressed: _showAllHistory,
                          child: Text(
                            '查看全部 ${logs.length} 条记录',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _getFilterLabel() {
    return BalanceLogUtils.getChangeTypeLabel(_balanceLogStore.selectedChangeType);
  }

  void _showFilterDialog() {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    final types = [
      null,
      'DEPOSIT',
      'WITHDRAW',
      'TRANSFER_IN',
      'TRANSFER_OUT',
      'TRADE_BUY',
      'TRADE_SELL',
      'ORDER_FREEZE',
      'ORDER_UNFREEZE',
      'FEE',
      'REBATE',
      'INTEREST',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: types.map((type) {
                return ListTile(
                  title: Text(
                    BalanceLogUtils.getChangeTypeLabel(type),
                    style: TextStyle(color: textTheme.primary),
                  ),
                  trailing: _balanceLogStore.selectedChangeType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _balanceLogStore.setSelectedChangeType(type);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showAllHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HistoryDetailScreen(
          symbol: widget.symbol,
          balanceLogStore: _balanceLogStore,
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final textTheme = context.textTheme;
    final borderTheme = context.borderTheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: borderTheme.defaultColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => WalletNavigator.toDeposit(
                  context,
                  symbol: widget.symbol,
                  name: widget.name,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '添加 ${widget.symbol}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => WalletNavigator.toTransferToUser(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: borderTheme.defaultColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '转账',
                  style: TextStyle(fontSize: 16, color: textTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => WalletNavigator.toTransfer(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: borderTheme.defaultColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '划转',
                  style: TextStyle(fontSize: 16, color: textTheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 历史记录详情页面
class _HistoryDetailScreen extends StatefulWidget {
  final String symbol;
  final BalanceLogStore balanceLogStore;

  const _HistoryDetailScreen({
    required this.symbol,
    required this.balanceLogStore,
  });

  @override
  State<_HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<_HistoryDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.balanceLogStore.loadLogs(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Scaffold(
      backgroundColor: backgroundTheme.page,
      appBar: AppBar(
        backgroundColor: backgroundTheme.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.symbol} 历史记录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          final logs = widget.balanceLogStore.logs;
          final isLoading = widget.balanceLogStore.isLoading;

          if (isLoading && logs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (logs.isEmpty) {
            return Center(
              child: Text(
                '暂无历史记录',
                style: TextStyle(fontSize: 14, color: textTheme.hint),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.balanceLogStore.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: logs.length + (widget.balanceLogStore.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == logs.length) {
                  return isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final log = logs[index];
                return BalanceLogDetailItem(log: log);
              },
            ),
          );
        },
      ),
    );
  }
}
