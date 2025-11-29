import '../../../../domain/entity/futures/position.dart';
import '../../../../domain/entity/futures/funding_rate.dart';
import '../../../../domain/entity/futures/leverage.dart';
import '../../../../domain/entity/futures/mark_price.dart';
import '../../../mock/mock_market_data.dart';

/// 永续合约API（模拟数据）
class FuturesApi {
  Future<List<Position>> getPositions({String? symbol}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generatePositions(symbol: symbol);
  }

  Future<Position?> getPositionById(String positionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final positions = await getPositions();
    try {
      return positions.firstWhere((p) => p.id == positionId);
    } catch (e) {
      return null;
    }
  }

  Future<FundingRate?> getFundingRate({String? symbol}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generateFundingRate(symbol: symbol);
  }

  Future<List<FundingRate>> getAllFundingRates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generateAllFundingRates();
  }

  Future<Leverage?> getLeverage(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generateLeverage(symbol);
  }

  Future<bool> setLeverage(String symbol, int leverage) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<MarkPrice?> getMarkPrice({String? symbol}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generateMarkPrice(symbol: symbol);
  }

  Future<List<MarkPrice>> getAllMarkPrices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockMarketData.generateAllMarkPrices();
  }
}

