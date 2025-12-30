import 'package:fastapp/core/theme/app_theme_extension.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/presentation/store/wallet/balance_log_store.dart';
import 'package:fastapp/presentation/store/wallet/wallet_store.dart';
import 'package:fastapp/presentation/views/wallet/widgets/common/balance_log_detail_item.dart';
import 'package:fastapp/utils/balance_log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

/// 钱包流水页面
class BalanceLogScreen extends StatefulWidget {
  const BalanceLogScreen({super.key});

  @override
  State<BalanceLogScreen> createState() => _BalanceLogScreenState();
}

class _BalanceLogScreenState extends State<BalanceLogScreen> {
  final BalanceLogStore _store = getIt<BalanceLogStore>();
  final WalletStore _walletStore = getIt<WalletStore>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _store.loadLogs();
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
      _store.loadLogs(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final backgroundTheme = context.backgroundTheme;

    return Scaffold(
      backgroundColor: backgroundTheme.page ?? Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: backgroundTheme.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '资金流水',
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
          return Column(
            children: [
              _buildFilterBar(textTheme, backgroundTheme),
              Expanded(
                child: _buildLogList(textTheme, backgroundTheme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundTheme.card,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: BalanceLogUtils.getWalletTypeLabel(_store.selectedWalletType),
                  onTap: () => _showWalletTypeFilter(textTheme, backgroundTheme),
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  label: _store.selectedSymbol ?? '全部币种',
                  onTap: () => _showSymbolFilter(textTheme, backgroundTheme),
                  textTheme: textTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterButton(
                  label: BalanceLogUtils.getChangeTypeLabel(_store.selectedChangeType),
                  onTap: () => _showChangeTypeFilter(textTheme, backgroundTheme),
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: _getTimeRangeLabel(),
                  onTap: () => _showTimeRangePicker(textTheme, backgroundTheme),
                  textTheme: textTheme,
                ),
              ),
              if (_store.startTime != null || _store.endTime != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _store.setTimeRange(null, null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.clear, size: 18, color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required VoidCallback onTap,
    required TextThemeColors textTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: textTheme.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: textTheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLogList(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    if (_store.isLoading && _store.logs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_store.logs.isEmpty) {
      return Center(
        child: Text(
          '暂无流水记录',
          style: TextStyle(fontSize: 14, color: textTheme.hint),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _store.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _store.logs.length + (_store.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _store.logs.length) {
            return _store.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }

          final log = _store.logs[index];
          return BalanceLogDetailItem(log: log);
        },
      ),
    );
  }

  void _showWalletTypeFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final options = [
          null,
          WalletType.SPOT.name,
          WalletType.FUTURES.name,
          WalletType.FUNDING.name,
          WalletType.MARGIN.name,
          WalletType.EARN.name,
          WalletType.OPTIONS.name,
        ];
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((type) {
                return ListTile(
                  title: Text(
                    BalanceLogUtils.getWalletTypeLabel(type),
                    style: TextStyle(color: textTheme.primary),
                  ),
                  trailing: _store.selectedWalletType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedWalletType(type);
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

  void _showSymbolFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
    final symbols = _walletStore.balances
        .where((b) => b.total > 0)
        .map((b) => b.symbol)
        .toSet()
        .toList()
      ..sort();

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
              children: [
                ListTile(
                  title: Text('全部币种', style: TextStyle(color: textTheme.primary)),
                  trailing: _store.selectedSymbol == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedSymbol(null);
                    Navigator.pop(context);
                  },
                ),
                ...symbols.map((symbol) {
                  return ListTile(
                    title: Text(symbol, style: TextStyle(color: textTheme.primary)),
                    trailing: _store.selectedSymbol == symbol
                        ? const Icon(Icons.check, color: Colors.blue)
                        : null,
                    onTap: () {
                      _store.setSelectedSymbol(symbol);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangeTypeFilter(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) {
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
                  trailing: _store.selectedChangeType == type
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    _store.setSelectedChangeType(type);
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

  String _getTimeRangeLabel() {
    if (_store.startTime == null && _store.endTime == null) {
      return '全部时间';
    }
    final format = DateFormat('yyyy-MM-dd');
    if (_store.startTime != null && _store.endTime != null) {
      return '${format.format(_store.startTime!)} 至 ${format.format(_store.endTime!)}';
    } else if (_store.startTime != null) {
      return '从 ${format.format(_store.startTime!)}';
    } else {
      return '至 ${format.format(_store.endTime!)}';
    }
  }

  Future<void> _showTimeRangePicker(
      TextThemeColors textTheme, BackgroundThemeColors backgroundTheme) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: backgroundTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        DateTime? tempStartTime = _store.startTime;
        DateTime? tempEndTime = _store.endTime;

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '选择时间范围',
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
                  const SizedBox(height: 16),
                  _buildDateTimeSelector(
                    label: '开始时间',
                    dateTime: tempStartTime,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempStartTime ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => tempStartTime = date);
                      }
                    },
                    onClear: () => setState(() => tempStartTime = null),
                    textTheme: textTheme,
                    backgroundTheme: backgroundTheme,
                  ),
                  const SizedBox(height: 12),
                  _buildDateTimeSelector(
                    label: '结束时间',
                    dateTime: tempEndTime,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempEndTime ?? DateTime.now(),
                        firstDate: tempStartTime ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => tempEndTime = date);
                      }
                    },
                    onClear: () => setState(() => tempEndTime = null),
                    textTheme: textTheme,
                    backgroundTheme: backgroundTheme,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _store.setTimeRange(tempStartTime, tempEndTime);
                        Navigator.pop(context);
                      },
                      child: const Text('确定'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required TextThemeColors textTheme,
    required BackgroundThemeColors backgroundTheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: textTheme.secondary),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateTime != null
                        ? DateFormat('yyyy-MM-dd').format(dateTime)
                        : '请选择日期',
                    style: TextStyle(
                      fontSize: 14,
                      color: dateTime != null ? textTheme.primary : textTheme.hint,
                    ),
                  ),
                ),
                if (dateTime != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.clear, size: 18, color: textTheme.hint),
                  )
                else
                  Icon(Icons.calendar_today, size: 18, color: textTheme.hint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
