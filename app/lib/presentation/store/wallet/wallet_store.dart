import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/wallet/account_balance.dart';
import 'package:fastapp/domain/entity/wallet/asset.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/domain/entity/wallet/transaction.dart';
import 'package:fastapp/domain/usecase/wallet/get_account_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_transactions_usecase.dart';
import 'package:mobx/mobx.dart';

part 'wallet_store.g.dart';

class WalletStore = _WalletStore with _$WalletStore;

abstract class _WalletStore with Store {
  final GetAssetUseCase _getAssetUseCase;
  final GetAccountBalanceUseCase _getAccountBalanceUseCase;
  final GetBalanceUseCase _getBalanceUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final ErrorStore _errorStore;

  _WalletStore(
    this._getAssetUseCase,
    this._getAccountBalanceUseCase,
    this._getBalanceUseCase,
    this._getTransactionsUseCase,
    this._errorStore,
  );

  @observable
  Asset? asset;

  @observable
  AccountBalance? accountBalance;

  @observable
  ObservableList<Balance> balances = ObservableList<Balance>();

  @observable
  ObservableList<Transaction> transactions = ObservableList<Transaction>();

  @observable
  String? selectedCurrency;

  @observable
  TransactionType? selectedType;

  @observable
  bool isLoadingAsset = false;

  @observable
  bool isLoadingTransactions = false;

  @observable
  String? errorMessage;

  @action
  void setSelectedCurrency(String? currency) {
    selectedCurrency = currency;
    loadTransactions();
  }

  @action
  void setSelectedType(TransactionType? type) {
    selectedType = type;
    loadTransactions();
  }

  @action
  Future<void> loadAsset() async {
    isLoadingAsset = true;
    errorMessage = null;

    try {
      final results = await Future.wait([
        _getAccountBalanceUseCase.call(params: null),
        _getAssetUseCase.call(params: null),
      ]);

      accountBalance = results[0] as AccountBalance;
      asset = results[1] as Asset;
      balances.clear();
      balances.addAll(asset!.balances);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingAsset = false;
    }
  }

  @action
  Future<void> loadTransactions({int? limit}) async {
    isLoadingTransactions = true;
    errorMessage = null;

    try {
      final txList = await _getTransactionsUseCase.call(
        params: GetTransactionsParams(
          currency: selectedCurrency,
          type: selectedType,
          limit: limit ?? 50,
        ),
      );
      transactions.clear();
      transactions.addAll(txList);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingTransactions = false;
    }
  }

  @action
  Future<void> refreshAsset() => loadAsset();

  @action
  Future<void> refreshTransactions() => loadTransactions();

  @computed
  List<Balance> get filteredBalances {
    if (selectedCurrency == null) return balances.toList();
    return balances.where((b) => b.symbol == selectedCurrency).toList();
  }

  @computed
  List<Transaction> get filteredTransactions {
    var result = transactions.toList();

    if (selectedCurrency != null) {
      result = result.where((t) => t.currency == selectedCurrency).toList();
    }
    if (selectedType != null) {
      result = result.where((t) => t.type == selectedType).toList();
    }

    return result;
  }

  @computed
  Map<WalletType, double> get accountTotals {
    if (accountBalance == null) return {};

    final totals = <WalletType, double>{};
    accountBalance!.balances.forEach((type, balanceList) {
      final total = balanceList.fold(0.0, (sum, b) => sum + b.total);
      if (total > 0) totals[type] = total;
    });

    return totals;
  }

  void dispose() {}
}

