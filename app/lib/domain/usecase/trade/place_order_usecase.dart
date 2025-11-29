import '../../../core/domain/usecase/use_case.dart';
import '../../entity/trade/trade_request.dart';
import '../../entity/trade/trade_response.dart';
import '../../repository/trade_repository.dart';

/// 下单UseCase
class PlaceOrderUseCase implements UseCase<TradeResponse, TradeRequest> {
  final TradeRepository _tradeRepository;

  PlaceOrderUseCase(this._tradeRepository);

  @override
  Future<TradeResponse> call({required TradeRequest params}) async {
    // 验证请求
    if (!params.isValid()) {
      return TradeResponse.failure('Invalid trade request');
    }
    return _tradeRepository.placeOrder(params);
  }
}

