import '../../network/apis/futures/futures_api.dart';
import '../../../domain/entity/futures/position.dart';
import '../../../domain/entity/futures/funding_rate.dart';
import '../../../domain/entity/futures/leverage.dart';
import '../../../domain/entity/futures/mark_price.dart';
import '../../../domain/repository/futures_repository.dart';

/// 永续合约仓库实现
class FuturesRepositoryImpl implements FuturesRepository {
  final FuturesApi _futuresApi;

  FuturesRepositoryImpl(this._futuresApi);

  @override
  Future<List<Position>> getPositions({String? symbol}) async {
    try {
      return await _futuresApi.getPositions(symbol: symbol);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Position?> getPositionById(String positionId) async {
    try {
      return await _futuresApi.getPositionById(positionId);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<FundingRate?> getFundingRate({String? symbol}) async {
    try {
      return await _futuresApi.getFundingRate(symbol: symbol);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<FundingRate>> getAllFundingRates() async {
    try {
      return await _futuresApi.getAllFundingRates();
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<Leverage?> getLeverage(String symbol) async {
    try {
      return await _futuresApi.getLeverage(symbol);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<bool> setLeverage(String symbol, int leverage) async {
    try {
      return await _futuresApi.setLeverage(symbol, leverage);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<MarkPrice?> getMarkPrice({String? symbol}) async {
    try {
      return await _futuresApi.getMarkPrice(symbol: symbol);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<List<MarkPrice>> getAllMarkPrices() async {
    try {
      return await _futuresApi.getAllMarkPrices();
    } catch (e) {
      throw e;
    }
  }
}

