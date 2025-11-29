/// 深度图数据实体
class DepthData {
  /// 价格
  final double price;
  
  /// 数量
  final double quantity;
  
  /// 累计数量
  final double cumulativeQuantity;

  DepthData({
    required this.price,
    required this.quantity,
    required this.cumulativeQuantity,
  });

  /// 从JSON创建
  factory DepthData.fromJson(Map<String, dynamic> json) {
    return DepthData(
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      cumulativeQuantity: (json['cumulativeQuantity'] as num).toDouble(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'quantity': quantity,
      'cumulativeQuantity': cumulativeQuantity,
    };
  }
}

/// 深度图完整数据
class DepthChartData {
  /// 买盘深度（价格从高到低）
  final List<DepthData> bids;
  
  /// 卖盘深度（价格从低到高）
  final List<DepthData> asks;
  
  /// 最新价格
  final double lastPrice;
  
  /// 时间戳
  final int timestamp;

  DepthChartData({
    required this.bids,
    required this.asks,
    required this.lastPrice,
    required this.timestamp,
  });

  /// 从JSON创建
  factory DepthChartData.fromJson(Map<String, dynamic> json) {
    return DepthChartData(
      bids: (json['bids'] as List<dynamic>)
          .map((item) => DepthData.fromJson(item as Map<String, dynamic>))
          .toList(),
      asks: (json['asks'] as List<dynamic>)
          .map((item) => DepthData.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastPrice: (json['lastPrice'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'bids': bids.map((item) => item.toJson()).toList(),
      'asks': asks.map((item) => item.toJson()).toList(),
      'lastPrice': lastPrice,
      'timestamp': timestamp,
    };
  }
}

