import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/futures/funding_rate.dart';
import 'package:fastapp/domain/entity/futures/mark_price.dart';
import 'package:fastapp/domain/entity/futures/position.dart';
import 'package:fastapp/domain/entity/market/depth_data.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/domain/entity/trade/trade_request.dart';
import 'package:fastapp/domain/entity/trade/trade_response.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart';
import 'package:fastapp/domain/usecase/market/get_depth_usecase.dart' as depth_usecase;
import 'package:fastapp/domain/usecase/trade/place_order_usecase.dart';
import 'package:fastapp/domain/usecase/wallet/get_balance_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_positions_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_funding_rate_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_mark_price_usecase.dart';
import 'package:fastapp/domain/usecase/futures/get_leverage_usecase.dart';
import 'package:fastapp/domain/usecase/futures/set_leverage_usecase.dart';
import 'package:fastapp/domain/entity/wallet/balance.dart';
import 'package:mobx/mobx.dart';

part 'futures_trade_store.g.dart';

class FuturesTradeStore = _FuturesTradeStore with _$FuturesTradeStore;

abstract class _FuturesTradeStore with Store {
  final PlaceOrderUseCase _placeOrderUseCase;
  final GetDepthUseCase _getDepthUseCase;
  final GetBalanceUseCase _getBalanceUseCase;
  final GetPositionsUseCase _getPositionsUseCase;
  final GetFundingRateUseCase _getFundingRateUseCase;
  final GetMarkPriceUseCase _getMarkPriceUseCase;
  final GetLeverageUseCase _getLeverageUseCase;
  final SetLeverageUseCase _setLeverageUseCase;
  final ErrorStore _errorStore;

  _FuturesTradeStore(
    this._placeOrderUseCase,
    this._getDepthUseCase,
    this._getBalanceUseCase,
    this._getPositionsUseCase,
    this._getFundingRateUseCase,
    this._getMarkPriceUseCase,
    this._getLeverageUseCase,
    this._setLeverageUseCase,
    this._errorStore,
  );

  // 当前交易对
  @observable
  String selectedSymbol = 'BTC/USDT';

  // 买入/卖出状态（对应做多/做空）
  @observable
  OrderSide tradeSide = OrderSide.buy;

  // 持仓方向（做多/做空）
  @observable
  PositionSide positionSide = PositionSide.long;

  // 订单类型（限价/市价）
  @observable
  OrderType orderType = OrderType.limit;

  // 杠杆倍数
  @observable
  int leverage = 10;

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

  // 当前持仓
  @observable
  Position? currentPosition;

  // 资金费率
  @observable
  FundingRate? fundingRate;

  // 标记价格
  @observable
  MarkPrice? markPrice;

  // 是否正在提交订单
  @observable
  bool isSubmitting = false;

  // 是否正在加载订单簿
  @observable
  bool isLoadingOrderBook = false;

  // 是否正在加载余额
  @observable
  bool isLoadingBalance = false;

  // 是否正在加载持仓
  @observable
  bool isLoadingPosition = false;

  // 是否正在加载资金费率
  @observable
  bool isLoadingFundingRate = false;

  // 是否正在加载标记价格
  @observable
  bool isLoadingMarkPrice = false;

  // 是否正在设置杠杆
  @observable
  bool isSettingLeverage = false;

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
    loadPosition();
    loadFundingRate();
    loadMarkPrice();
    loadLeverage();
  }

  @action
  void setTradeSide(OrderSide side) {
    tradeSide = side;
    positionSide = side == OrderSide.buy ? PositionSide.long : PositionSide.short;
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
  void setLeverage(int value) {
    leverage = value;
  }

  @action
  Future<void> loadLeverage() async {
    try {
      final leverageData = await _getLeverageUseCase.call(
        params: GetLeverageParams(symbol: selectedSymbol),
      );
      if (leverageData != null) {
        leverage = leverageData.leverage;
      }
    } catch (e) {
      // 忽略错误，使用默认值
    }
  }

  @action
  Future<bool> setLeverageValue(int value) async {
    isSettingLeverage = true;
    errorMessage = null;

    try {
      final success = await _setLeverageUseCase.call(
        params: SetLeverageParams(symbol: selectedSymbol, leverage: value),
      );
      if (success) {
        leverage = value;
        return true;
      } else {
        errorMessage = '设置杠杆失败';
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      return false;
    } finally {
      isSettingLeverage = false;
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

    if (orderType == OrderType.market) {
      // 市价：使用金额
      final totalAmount = balance * percentage;
      setAmount(totalAmount.toStringAsFixed(2));
    } else {
      // 限价：使用金额计算数量
      final p = double.tryParse(price);
      if (p != null && p > 0) {
        final totalAmount = balance * percentage;
        final q = totalAmount / p;
        setQuantity(q.toStringAsFixed(8));
      }
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
      final parts = selectedSymbol.split('/');
      if (parts.length == 2) {
        final currency = parts[1]; // 永续合约使用USDT作为保证金
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
  Future<void> loadPosition() async {
    isLoadingPosition = true;
    errorMessage = null;

    try {
      final positions = await _getPositionsUseCase.call(
        params: GetPositionsParams(symbol: selectedSymbol),
      );
      if (positions.isNotEmpty) {
        currentPosition = positions.first;
      } else {
        currentPosition = null;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingPosition = false;
    }
  }

  @action
  Future<void> loadFundingRate() async {
    isLoadingFundingRate = true;
    errorMessage = null;

    try {
      final rate = await _getFundingRateUseCase.call(
        params: GetFundingRateParams(symbol: selectedSymbol),
      );
      fundingRate = rate;
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingFundingRate = false;
    }
  }

  @action
  Future<void> loadMarkPrice() async {
    isLoadingMarkPrice = true;
    errorMessage = null;

    try {
      final mark = await _getMarkPriceUseCase.call(
        params: GetMarkPriceParams(symbol: selectedSymbol),
      );
      markPrice = mark;
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoadingMarkPrice = false;
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
        // 刷新数据
        await loadOrderBookData();
        await loadBalance();
        await loadPosition();
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

