import 'package:flutter/material.dart';

/// 基础理财产品模型
class FinanceProduct {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String rate;
  final String? rateLabel;
  final String? protocol;
  final String? duration;
  final String? priceChange;
  final String? expiryDate;
  final String? targetPrice;

  const FinanceProduct({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.rate,
    this.rateLabel,
    this.protocol,
    this.duration,
    this.priceChange,
    this.expiryDate,
    this.targetPrice,
  });

  /// 创建推荐产品
  factory FinanceProduct.recommended({
    required String name,
    required IconData icon,
    required Color iconColor,
    required String rate,
    String rateLabel = '年化收益率',
  }) {
    return FinanceProduct(
      name: name,
      icon: icon,
      iconColor: iconColor,
      rate: rate,
      rateLabel: rateLabel,
    );
  }

  /// 创建普通产品
  factory FinanceProduct.simple({
    required String name,
    required IconData icon,
    required Color iconColor,
    required String rate,
  }) {
    return FinanceProduct(
      name: name,
      icon: icon,
      iconColor: iconColor,
      rate: rate,
    );
  }

  /// 创建链上产品
  factory FinanceProduct.onChain({
    required String name,
    required String protocol,
    required IconData icon,
    required Color iconColor,
    required String rate,
    String duration = '定期',
  }) {
    return FinanceProduct(
      name: name,
      protocol: protocol,
      icon: icon,
      iconColor: iconColor,
      rate: rate,
      duration: duration,
    );
  }

  /// 创建双币投资产品
  factory FinanceProduct.dualInvestment({
    required String targetPrice,
    required String priceChange,
    required String apr,
    required String expiryDate,
  }) {
    return FinanceProduct(
      name: '',
      icon: Icons.currency_bitcoin,
      iconColor: const Color(0xFFF7931A),
      rate: apr,
      targetPrice: targetPrice,
      priceChange: priceChange,
      expiryDate: expiryDate,
    );
  }
}

/// 双币投资产品模型
class DualInvestmentProduct {
  final String targetPrice;
  final String priceChange;
  final String apr;
  final String expiryDate;

  DualInvestmentProduct({
    required this.targetPrice,
    required this.priceChange,
    required this.apr,
    required this.expiryDate,
  });
}

/// 链上赚币产品模型
class OnChainProduct {
  final String name;
  final String protocol;
  final IconData icon;
  final Color iconColor;
  final String rate;
  final String duration;

  OnChainProduct({
    required this.name,
    required this.protocol,
    required this.icon,
    required this.iconColor,
    required this.rate,
    required this.duration,
  });
}
