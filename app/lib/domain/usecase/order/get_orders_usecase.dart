import '../../../core/domain/usecase/use_case.dart';
import '../../entity/order/order.dart';
import '../../entity/order/order_status.dart';
import '../../repository/order_repository.dart';

/// 获取订单列表的参数
class GetOrdersParams {
  final String? symbol;
  final OrderStatus? status;
  final int? startTime;
  final int? endTime;
  final int? page;
  final int? limit;

  GetOrdersParams({
    this.symbol,
    this.status,
    this.startTime,
    this.endTime,
    this.page,
    this.limit,
  });
}

/// 获取订单列表UseCase
class GetOrdersUseCase implements UseCase<List<Order>, GetOrdersParams> {
  final OrderRepository _orderRepository;

  GetOrdersUseCase(this._orderRepository);

  @override
  Future<List<Order>> call({required GetOrdersParams params}) async {
    return _orderRepository.getOrders(
      symbol: params.symbol,
      status: params.status,
      startTime: params.startTime,
      endTime: params.endTime,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// 获取订单详情的参数
class GetOrderDetailParams {
  final String orderId;

  GetOrderDetailParams({required this.orderId});
}

/// 获取订单详情UseCase
class GetOrderDetailUseCase
    implements UseCase<Order?, GetOrderDetailParams> {
  final OrderRepository _orderRepository;

  GetOrderDetailUseCase(this._orderRepository);

  @override
  Future<Order?> call({required GetOrderDetailParams params}) async {
    return _orderRepository.getOrderById(params.orderId);
  }
}

