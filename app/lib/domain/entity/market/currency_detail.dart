/// 币种详情实体
class CurrencyDetail {
  /// 币种ID
  final int id;

  /// 币种符号（如：BTC）
  final String symbol;

  /// 币种名称
  final String name;

  /// Logo URL
  final String? logo;

  /// 链名称（如：BNB）
  final String chain;

  /// 合约地址
  final String? contractAddress;

  /// 精度（小数位数）
  final int decimals;

  /// 类型
  final int type;

  /// 是否为基础货币
  final bool isBaseCurrency;

  /// 是否为计价货币
  final bool isQuoteCurrency;

  /// 是否允许充值
  final bool depositEnabled;

  /// 是否允许提现
  final bool withdrawEnabled;

  /// 最小充值金额
  final String? minDepositAmount;

  /// 最小提现金额
  final String? minWithdrawAmount;

  /// 提现手续费
  final String? withdrawFee;

  /// 提现手续费类型（fixed/percentage）
  final String withdrawFeeType;

  /// 市值
  final String? marketCap;

  /// 市值排名
  final int? marketCapRank;

  /// 完全稀释市值
  final String? fullyDilutedMarketCap;

  /// 流通供应量
  final String? circulatingSupply;

  /// 总供应量
  final String? totalSupply;

  /// 最大供应量
  final String? maxSupply;

  /// 发行日期
  final String? launchDate;

  /// 共识算法
  final String? consensusAlgorithm;

  /// 算法
  final String? algorithm;

  /// 描述（HTML格式）
  final String? description;

  /// 链接信息
  final CurrencyLinks links;

  /// 标签列表
  final List<String> tags;

  /// 人气排名
  final int? popularityRank;

  /// 交易量排名
  final int? tradingVolumeRank;

  /// 状态（1: 启用, 0: 禁用）
  final int status;

  /// 是否热门
  final bool isHot;

  /// 是否推荐
  final bool isRecommended;

  /// 排序
  final int sort;

  /// 创建时间
  final String? createdAt;

  /// 更新时间
  final String? updatedAt;

  CurrencyDetail({
    required this.id,
    required this.symbol,
    required this.name,
    this.logo,
    required this.chain,
    this.contractAddress,
    required this.decimals,
    required this.type,
    required this.isBaseCurrency,
    required this.isQuoteCurrency,
    required this.depositEnabled,
    required this.withdrawEnabled,
    this.minDepositAmount,
    this.minWithdrawAmount,
    this.withdrawFee,
    required this.withdrawFeeType,
    this.marketCap,
    this.marketCapRank,
    this.fullyDilutedMarketCap,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.launchDate,
    this.consensusAlgorithm,
    this.algorithm,
    this.description,
    required this.links,
    required this.tags,
    this.popularityRank,
    this.tradingVolumeRank,
    required this.status,
    required this.isHot,
    required this.isRecommended,
    required this.sort,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建
  factory CurrencyDetail.fromJson(Map<String, dynamic> json) {
    // 处理 links
    CurrencyLinks links;
    if (json['links'] is Map) {
      links = CurrencyLinks.fromJson(json['links'] as Map<String, dynamic>);
    } else {
      links = CurrencyLinks.empty();
    }

    // 处理 tags
    List<String> tags = [];
    if (json['tags'] is List) {
      tags = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return CurrencyDetail(
      id: (json['id'] ?? 0) as int,
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      chain: json['chain'] as String? ?? '',
      contractAddress: json['contract_address'] as String?,
      decimals: (json['decimals'] ?? 18) as int,
      type: (json['type'] ?? 0) as int,
      isBaseCurrency: (json['is_base_currency'] ?? 0) == 1,
      isQuoteCurrency: (json['is_quote_currency'] ?? 0) == 1,
      depositEnabled: (json['deposit_enabled'] ?? 0) == 1,
      withdrawEnabled: (json['withdraw_enabled'] ?? 0) == 1,
      minDepositAmount: json['min_deposit_amount']?.toString(),
      minWithdrawAmount: json['min_withdraw_amount']?.toString(),
      withdrawFee: json['withdraw_fee']?.toString(),
      withdrawFeeType: json['withdraw_fee_type'] as String? ?? 'fixed',
      marketCap: json['market_cap']?.toString(),
      marketCapRank: json['market_cap_rank'] as int?,
      fullyDilutedMarketCap: json['fully_diluted_market_cap']?.toString(),
      circulatingSupply: json['circulating_supply']?.toString(),
      totalSupply: json['total_supply']?.toString(),
      maxSupply: json['max_supply']?.toString(),
      launchDate: json['launch_date'] as String?,
      consensusAlgorithm: json['consensus_algorithm'] as String?,
      algorithm: json['algorithm'] as String?,
      description: json['description'] as String?,
      links: links,
      tags: tags,
      popularityRank: json['popularity_rank'] as int?,
      tradingVolumeRank: json['trading_volume_rank'] as int?,
      status: (json['status'] ?? 1) as int,
      isHot: (json['is_hot'] ?? 0) == 1,
      isRecommended: (json['is_recommended'] ?? 0) == 1,
      sort: (json['sort'] ?? 100) as int,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'logo': logo,
      'chain': chain,
      'contract_address': contractAddress,
      'decimals': decimals,
      'type': type,
      'is_base_currency': isBaseCurrency ? 1 : 0,
      'is_quote_currency': isQuoteCurrency ? 1 : 0,
      'deposit_enabled': depositEnabled ? 1 : 0,
      'withdraw_enabled': withdrawEnabled ? 1 : 0,
      'min_deposit_amount': minDepositAmount,
      'min_withdraw_amount': minWithdrawAmount,
      'withdraw_fee': withdrawFee,
      'withdraw_fee_type': withdrawFeeType,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'fully_diluted_market_cap': fullyDilutedMarketCap,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
      'launch_date': launchDate,
      'consensus_algorithm': consensusAlgorithm,
      'algorithm': algorithm,
      'description': description,
      'links': links.toJson(),
      'tags': tags,
      'popularity_rank': popularityRank,
      'trading_volume_rank': tradingVolumeRank,
      'status': status,
      'is_hot': isHot ? 1 : 0,
      'is_recommended': isRecommended ? 1 : 0,
      'sort': sort,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 是否启用
  bool get isEnabled => status == 1;
}

/// 币种链接信息
class CurrencyLinks {
  final String? github;
  final String? medium;
  final String? reddit;
  final String? discord;
  final String? twitter;
  final String? website;
  final String? youtube;
  final String? explorer;
  final String? facebook;
  final String? telegram;
  final String? whitepaper;

  CurrencyLinks({
    this.github,
    this.medium,
    this.reddit,
    this.discord,
    this.twitter,
    this.website,
    this.youtube,
    this.explorer,
    this.facebook,
    this.telegram,
    this.whitepaper,
  });

  /// 从JSON创建
  factory CurrencyLinks.fromJson(Map<String, dynamic> json) {
    return CurrencyLinks(
      github: json['github'] as String?,
      medium: json['medium'] as String?,
      reddit: json['reddit'] as String?,
      discord: json['discord'] as String?,
      twitter: json['twitter'] as String?,
      website: json['website'] as String?,
      youtube: json['youtube'] as String?,
      explorer: json['explorer'] as String?,
      facebook: json['facebook'] as String?,
      telegram: json['telegram'] as String?,
      whitepaper: json['whitepaper'] as String?,
    );
  }

  /// 创建空链接对象
  factory CurrencyLinks.empty() {
    return CurrencyLinks();
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'github': github,
      'medium': medium,
      'reddit': reddit,
      'discord': discord,
      'twitter': twitter,
      'website': website,
      'youtube': youtube,
      'explorer': explorer,
      'facebook': facebook,
      'telegram': telegram,
      'whitepaper': whitepaper,
    };
  }

  /// 获取非空链接列表
  List<MapEntry<String, String>> get nonEmptyLinks {
    final List<MapEntry<String, String>> result = [];
    if (github != null && github!.isNotEmpty) {
      result.add(MapEntry('GitHub', github!));
    }
    if (medium != null && medium!.isNotEmpty) {
      result.add(MapEntry('Medium', medium!));
    }
    if (reddit != null && reddit!.isNotEmpty) {
      result.add(MapEntry('Reddit', reddit!));
    }
    if (discord != null && discord!.isNotEmpty) {
      result.add(MapEntry('Discord', discord!));
    }
    if (twitter != null && twitter!.isNotEmpty) {
      result.add(MapEntry('Twitter', twitter!));
    }
    if (website != null && website!.isNotEmpty) {
      result.add(MapEntry('官网', website!));
    }
    if (youtube != null && youtube!.isNotEmpty) {
      result.add(MapEntry('YouTube', youtube!));
    }
    if (explorer != null && explorer!.isNotEmpty) {
      result.add(MapEntry('区块浏览器', explorer!));
    }
    if (facebook != null && facebook!.isNotEmpty) {
      result.add(MapEntry('Facebook', facebook!));
    }
    if (telegram != null && telegram!.isNotEmpty) {
      result.add(MapEntry('Telegram', telegram!));
    }
    if (whitepaper != null && whitepaper!.isNotEmpty) {
      result.add(MapEntry('白皮书', whitepaper!));
    }
    return result;
  }
}

