import '../../../core/domain/usecase/use_case.dart';
import '../../repository/order_repository.dart';

/// 取消订单的参数
class CancelOrderParams {
  final String orderId;

  CancelOrderParams({required this.orderId});
}

/// 取消订单UseCase
class CancelOrderUseCase implements UseCase<bool, CancelOrderParams> {
  final OrderRepository _orderRepository;

  CancelOrderUseCase(this._orderRepository);

  @override
  Future<bool> call({required CancelOrderParams params}) async {
    return _orderRepository.cancelOrder(params.orderId);
  }
}

