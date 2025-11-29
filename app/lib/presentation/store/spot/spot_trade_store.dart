import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/domain/entity/trade/trade_request.dart';
import 'package:fastapp/domain/entity/trade/trade_response.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart' as depth_usecase;
import 'package:fastapp/domain/usecase/trade/place_order_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:mobx/mobx.dart';

part 'spot_trade_store.g.dart';

class SpotTradeStore = _SpotTradeStore with _$SpotTradeStore;

abstract class _SpotTradeStore with Store {
  final PlaceOrderUseCase _placeOrderUseCase;
  final GetDepthUseCase _getDepthUseCase;
  final GetBalanceUseCase _getBalanceUseCase;
  final ErrorStore _errorStore;

  _SpotTradeStore(
    this._placeOrderUseCase,
    this._getDepthUseCase,
    this._getBalanceUseCase,
    this._errorStore,
  );

  // 当前交易对
  @observable
  String selectedSymbol = 'BTC/USDT';

  // 买入/卖出状态
  @observable
  OrderSide tradeSide = OrderSide.buy;

  // 订单类型（限价/市价）
  @observable
  OrderType orderType = OrderType.limit;

  // 价格输入
  @observable
  String price = '';

  // 数量输入
  @observable
  String quantity = '';

  // 金额输入
  @observable
  String amount = '';

  // 订单簿数据
  @observable
  DepthChartData? orderBookData;

  // 可用余额
  @observable
  Balance? availableBalance;

  // 是否正在提交订单
  @observable
  bool isSubmitting = false;

  // 是否正在加载订单簿
  @observable
  bool isLoadingOrderBook = false;

  // 是否正在加载余额
  @observable
  bool isLoadingBalance = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 下单成功消息
  @observable
  String? successMessage;

  // Actions
  @action
  void setSelectedSymbol(String symbol) {
    selectedSymbol = symbol;
    price = '';
    quantity = '';
    amount = '';
    loadOrderBookData();
    loadBalance();
  }

  @action
  void setTradeSide(OrderSide side) {
    tradeSide = side;
    quantity = '';
    amount = '';
  }

  @action
  void setOrderType(OrderType type) {
    orderType = type;
    if (type == OrderType.market && tradeSide == OrderSide.buy) {
      price = '';
    }
  }

  @action
  void setPrice(String value) {
    price = value;
    if (value.isNotEmpty && quantity.isNotEmpty) {
      final p = double.tryParse(value);
      final q = double.tryParse(quantity);
      if (p != null && q != null) {
        amount = (p * q).toStringAsFixed(2);
      }
    }
  }

  @action
  void setQuantity(String value) {
    quantity = value;
    if (value.isNotEmpty && price.isNotEmpty) {
      final p = double.tryParse(price);
      final q = double.tryParse(value);
      if (p != null && q != null) {
        amount = (p * q).toStringAsFixed(2);
      }
    }
  }

  @action
  void setAmount(String value) {
    amount = value;
    if (value.isNotEmpty && price.isNotEmpty && orderType == OrderType.market && tradeSide == OrderSide.buy) {
      final a = double.tryParse(value);
      final p = double.tryParse(price);
      if (a != null && p != null && p > 0) {
        quantity = (a / p).toStringAsFixed(8);
      }
    }
  }

  @action
  void setPriceFromOrderBook(double priceValue) {
    price = priceValue.toStringAsFixed(2);
    if (quantity.isNotEmpty) {
      final q = double.tryParse(quantity);
      if (q != null) {
        amount = (priceValue * q).toStringAsFixed(2);
      }
    }
  }

  @action
  void setQuantityByPercentage(double percentage) {
    if (availableBalance == null) return;

    final balance = availableBalance!.available;
    if (balance <= 0) return;

    if (tradeSide == OrderSide.buy) {
      // 买入：根据可用余额计算
      if (orderType == OrderType.market) {
        // 市价买入：使用金额
        final totalAmount = balance * percentage;
        setAmount(totalAmount.toStringAsFixed(2));
      } else {
        // 限价买入：使用金额计算数量
        final p = double.tryParse(price);
        if (p != null && p > 0) {
          final totalAmount = balance * percentage;
          final q = totalAmount / p;
          setQuantity(q.toStringAsFixed(8));
        }
      }
    } else {
      // 卖出：根据可用余额计算数量
      final q = balance * percentage;
      setQuantity(q.toStringAsFixed(8));
    }
  }

  @action
  Future<void> loadOrderBookData({int? limit}) async {
    isLoadingOrderBook = true;
    errorMessage = null;

    try {
      final data = await _getDepthUseCase.call(
        params: depth_usecase.GetDepthParams(
          symbol: selectedSymbol,
          limit: limit ?? 20,
        ),
      );
      orderBookData = data;
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingOrderBook = false;
    }
  }

  @action
  Future<void> loadBalance() async {
    isLoadingBalance = true;
    errorMessage = null;

    try {
      // 获取基础币种余额（例如 BTC/USDT 中的 USDT 或 BTC）
      final parts = selectedSymbol.split('/');
      if (parts.length == 2) {
        final currency = tradeSide == OrderSide.buy ? parts[1] : parts[0];
        final balance = await _getBalanceUseCase.call(
          params: GetBalanceParams(currency: currency),
        );
        availableBalance = balance;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingBalance = false;
    }
  }

  @action
  Future<bool> submitOrder() async {
    if (!_validateInput()) {
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    successMessage = null;

    try {
      final request = TradeRequest(
        symbol: selectedSymbol,
        type: orderType,
        side: tradeSide,
        price: orderType == OrderType.limit ? double.tryParse(price) : null,
        quantity: double.parse(quantity),
        amount: orderType == OrderType.market && tradeSide == OrderSide.buy
            ? double.tryParse(amount)
            : null,
      );

      final response = await _placeOrderUseCase.call(params: request);

      if (response.success) {
        successMessage = '订单提交成功';
        // 清空表单
        price = '';
        quantity = '';
        amount = '';
        // 刷新订单簿和余额
        await loadOrderBookData();
        await loadBalance();
        return true;
      } else {
        errorMessage = response.errorMessage ?? '订单提交失败';
        _errorStore.setErrorMessage(errorMessage!);
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      return false;
    } finally {
      isSubmitting = false;
    }
  }

  bool _validateInput() {
    if (quantity.isEmpty || double.tryParse(quantity) == null || double.parse(quantity) <= 0) {
      errorMessage = '请输入有效的数量';
      return false;
    }

    if (orderType == OrderType.limit) {
      if (price.isEmpty || double.tryParse(price) == null || double.parse(price) <= 0) {
        errorMessage = '请输入有效的价格';
        return false;
      }
    } else if (orderType == OrderType.market && tradeSide == OrderSide.buy) {
      if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
        errorMessage = '请输入有效的金额';
        return false;
      }
    }

    return true;
  }

  @action
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
  }

  void dispose() {}
}

