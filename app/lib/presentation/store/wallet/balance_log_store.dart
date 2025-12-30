import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/wallet/balance_log.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_logs_usecase.dart';
import 'package:mobx/mobx.dart';

part 'balance_log_store.g.dart';

class BalanceLogStore = _BalanceLogStore with _$BalanceLogStore;

abstract class _BalanceLogStore with Store {
  final GetBalanceLogsUseCase _getBalanceLogsUseCase;
  final ErrorStore _errorStore;

  _BalanceLogStore(
    this._getBalanceLogsUseCase,
    this._errorStore,
  );

  @observable
  ObservableList<BalanceLog> logs = ObservableList<BalanceLog>();

  @observable
  String? selectedWalletType;

  @observable
  String? selectedSymbol;

  @observable
  String? selectedChangeType;

  @observable
  bool isLoading = false;

  @observable
  bool hasMore = true;

  @observable
  int currentPage = 1;

  @observable
  String? errorMessage;

  @action
  void setSelectedWalletType(String? walletType) {
    selectedWalletType = walletType;
    refresh();
  }

  @action
  void setSelectedSymbol(String? symbol) {
    selectedSymbol = symbol;
    refresh();
  }

  @action
  void setSelectedChangeType(String? changeType) {
    selectedChangeType = changeType;
    refresh();
  }

  @action
  Future<void> loadLogs({bool loadMore = false}) async {
    if (isLoading) return;
    if (loadMore && !hasMore) return;

    isLoading = true;
    errorMessage = null;

    if (!loadMore) {
      currentPage = 1;
      logs.clear();
    } else {
      currentPage++;
    }

    try {
      final logList = await _getBalanceLogsUseCase.call(
        params: GetBalanceLogsParams(
          walletType: selectedWalletType,
          symbol: selectedSymbol,
          changeType: selectedChangeType,
          page: currentPage,
          pageSize: 20,
        ),
      );

      if (logList.isEmpty) {
        hasMore = false;
      } else {
        logs.addAll(logList);
        hasMore = logList.length >= 20;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      if (loadMore) {
        currentPage--;
      }
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> refresh() => loadLogs(loadMore: false);

  void dispose() {}
}
