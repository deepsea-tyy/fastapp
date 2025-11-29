import 'dart:async';

import '../entity/futures/position.dart';
import '../entity/futures/funding_rate.dart';
import '../entity/futures/leverage.dart';
import '../entity/futures/mark_price.dart';

/// 永续合约仓库接口
abstract class FuturesRepository {
  /// 获取持仓列表
  /// [symbol] 交易对符号（可选）
  Future<List<Position>> getPositions({String? symbol});

  /// 根据ID获取持仓
  Future<Position?> getPositionById(String positionId);

  /// 获取资金费率
  /// [symbol] 交易对符号（可选）
  Future<FundingRate?> getFundingRate({String? symbol});

  /// 获取所有资金费率
  Future<List<FundingRate>> getAllFundingRates();

  /// 获取杠杆设置
  /// [symbol] 交易对符号
  Future<Leverage?> getLeverage(String symbol);

  /// 设置杠杆
  /// [symbol] 交易对符号
  /// [leverage] 杠杆倍数
  Future<bool> setLeverage(String symbol, int leverage);

  /// 获取标记价格
  /// [symbol] 交易对符号（可选）
  Future<MarkPrice?> getMarkPrice({String? symbol});

  /// 获取所有标记价格
  Future<List<MarkPrice>> getAllMarkPrices();
}

