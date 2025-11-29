import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/wallet/asset.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:fastapp/domain/entity/wallet/transaction.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_transactions_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart' as asset_usecase;
import 'package:mobx/mobx.dart';

part 'wallet_store.g.dart';

class WalletStore = _WalletStore with _$WalletStore;

abstract class _WalletStore with Store {
  final GetAssetUseCase _getAssetUseCase;
  final GetBalanceUseCase _getBalanceUseCase;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final ErrorStore _errorStore;

  _WalletStore(
    this._getAssetUseCase,
    this._getBalanceUseCase,
    this._getTransactionsUseCase,
    this._errorStore,
  );

  // 资产信息
  @observable
  Asset? asset;

  // 余额列表
  @observable
  ObservableList<Balance> balances = ObservableList<Balance>();

  // 交易记录列表
  @observable
  ObservableList<Transaction> transactions = ObservableList<Transaction>();

  // 选中的币种（筛选用）
  @observable
  String? selectedCurrency;

  // 选中的交易类型（筛选用）
  @observable
  TransactionType? selectedType;

  // 是否正在加载资产
  @observable
  bool isLoadingAsset = false;

  // 是否正在加载交易记录
  @observable
  bool isLoadingTransactions = false;

  // 错误消息
  @observable
  String? errorMessage;

  // Actions
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
      final assetData = await _getAssetUseCase.call(params: null);
      asset = assetData;
      balances.clear();
      balances.addAll(assetData.balances);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingAsset = false;
    }
  }

  @action
  Future<void> loadTransactions({
    int? limit,
  }) async {
    isLoadingTransactions = true;
    errorMessage = null;

    try {
      final params = GetTransactionsParams(
        currency: selectedCurrency,
        type: selectedType,
        limit: limit ?? 50,
      );
      final txList = await _getTransactionsUseCase.call(params: params);
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
  Future<void> refreshAsset() async {
    await loadAsset();
  }

  @action
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  @computed
  List<Balance> get filteredBalances {
    if (selectedCurrency == null) {
      return balances.toList();
    }
    return balances.where((b) => b.currency == selectedCurrency).toList();
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

  void dispose() {}
}

