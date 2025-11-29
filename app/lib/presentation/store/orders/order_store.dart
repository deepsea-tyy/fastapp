import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/entity/order/order.dart';
import 'package:fastapp/domain/entity/order/order_status.dart';
import 'package:fastapp/domain/usecase/order/get_orders_usecase.dart';
import 'package:fastapp/domain/usecase/trade/cancel_order_usecase.dart';
import 'package:mobx/mobx.dart';

part 'order_store.g.dart';

class OrderStore = _OrderStore with _$OrderStore;

abstract class _OrderStore with Store {
  final GetOrdersUseCase _getOrdersUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  final ErrorStore _errorStore;

  _OrderStore(
    this._getOrdersUseCase,
    this._cancelOrderUseCase,
    this._errorStore,
  );

  // 订单列表
  @observable
  ObservableList<Order> orders = ObservableList<Order>();

  // 选中的订单状态（筛选用）
  @observable
  OrderStatus? selectedStatus;

  // 选中的交易对（筛选用）
  @observable
  String? selectedSymbol;

  // 是否正在加载订单
  @observable
  bool isLoading = false;

  // 是否正在取消订单
  @observable
  bool isCancelling = false;

  // 错误消息
  @observable
  String? errorMessage;

  // 成功消息
  @observable
  String? successMessage;

  // Actions
  @action
  void setSelectedStatus(OrderStatus? status) {
    selectedStatus = status;
  }

  @action
  void setSelectedSymbol(String? symbol) {
    selectedSymbol = symbol;
  }

  @action
  Future<void> loadOrders({
    int? limit,
  }) async {
    isLoading = true;
    errorMessage = null;

    try {
      final params = GetOrdersParams(
        symbol: selectedSymbol,
        status: selectedStatus,
        limit: limit ?? 50,
      );
      final orderList = await _getOrdersUseCase.call(params: params);
      orders.clear();
      orders.addAll(orderList);
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> cancelOrder(String orderId) async {
    isCancelling = true;
    errorMessage = null;
    successMessage = null;

    try {
      final success = await _cancelOrderUseCase.call(
        params: CancelOrderParams(orderId: orderId),
      );

      if (success) {
        successMessage = '订单取消成功';
        // 刷新订单列表
        await loadOrders();
        return true;
      } else {
        errorMessage = '订单取消失败';
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      _errorStore.setErrorMessage(e.toString());
      return false;
    } finally {
      isCancelling = false;
    }
  }

  @action
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  @computed
  List<Order> get currentOrders {
    return orders.where((order) => order.canCancel).toList();
  }

  @computed
  List<Order> get historyOrders {
    return orders.where((order) => !order.canCancel).toList();
  }

  @computed
  List<Order> get filteredOrders {
    var result = orders.toList();

    if (selectedSymbol != null) {
      result = result.where((o) => o.symbol == selectedSymbol).toList();
    }

    if (selectedStatus != null) {
      result = result.where((o) => o.status == selectedStatus).toList();
    }

    return result;
  }

  @action
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
  }

  void dispose() {}
}

