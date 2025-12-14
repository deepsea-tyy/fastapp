import 'package:flutter/material.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/data/network/apis/user/user_api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'widgets.dart';

/// VIP特权页面 - 展示VIP等级配置信息
class VipPrivilegeScreen extends StatefulWidget {
  const VipPrivilegeScreen({super.key});

  @override
  State<VipPrivilegeScreen> createState() => _VipPrivilegeScreenState();
}

class _VipPrivilegeScreenState extends State<VipPrivilegeScreen> {
  Map<String, dynamic>? _vipData;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 延迟获取路由参数并初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVipData();
    });
  }

  /// 初始化VIP数据
  void _initVipData() {
    // 尝试从路由参数获取VIP数据
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        _vipData = args;
        _isLoading = false;
      });
    } else {
      // 如果没有传递数据，则请求接口
      _loadVipDetail();
    }
  }

  /// 加载VIP详情数据
  Future<void> _loadVipDetail() async {
    // 防止重复请求
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userApi = getIt<UserApi>();
      final response = await userApi.getVipDetail();

      if (mounted) {
        setState(() {
          _vipData = response;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败: ${e.toString()}';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SettingAppBar(title: 'VIP特权'),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : RefreshIndicator(
                          onRefresh: _loadVipDetail,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // VIP等级卡片
                                _buildVipLevelCard(context),
                                const SizedBox(height: 24),
                                // VIP详细介绍（HTML格式）
                                if (_vipData?['description'] != null && (_vipData!['description'] as String).isNotEmpty)
                                  ...[
                                    _buildVipDescription(context),
                                    const SizedBox(height: 24),
                                  ],
                                // VIP升级进度（如果不是最高等级）
                                if ((_vipData?['level'] as int? ?? 0) < 9)
                                  ...[
                                    _buildUpgradeProgress(context),
                                    const SizedBox(height: 24),
                                  ],
                                // 费率部分
                                _buildFeeRateSection(context),
                                const SizedBox(height: 24),
                                // 提现额度部分
                                _buildWithdrawLimitSection(context),
                                const SizedBox(height: 24),
                                // VIP特权部分
                                _buildPrivilegesSection(context),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建错误提示
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '加载失败',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadVipDetail,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建VIP等级卡片
  Widget _buildVipLevelCard(BuildContext context) {
    final vipLevel = _vipData?['level'] as int? ?? 0;
    final levelName = _vipData?['name'] as String? ?? _getVipLevelName(vipLevel);
    final colorStr = _vipData?['color'] as String?;
    final vipColor = _parseColor(colorStr) ?? _getDefaultVipColor(vipLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              vipColor,
              vipColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: vipColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vipLevel == 0 ? '普通用户' : '尊享VIP专属特权',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // VIP等级数字徽章
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    vipLevel == 0 ? 'LV0' : 'LV$vipLevel',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // 降级保护提示（如果在保护期内）
            if (_isInProtectionPeriod()) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getProtectionText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建VIP详细介绍（HTML格式）
  Widget _buildVipDescription(BuildContext context) {
    final description = _vipData?['description'] as String? ?? '';

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'VIP介绍',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingCard(
            padding: const EdgeInsets.all(16),
            child: Html(
              data: description,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(14),
                  lineHeight: const LineHeight(1.6),
                ),
                "p": Style(
                  margin: Margins.only(bottom: 8),
                ),
                "h1": Style(
                  fontSize: FontSize(20),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 8, top: 8),
                ),
                "h2": Style(
                  fontSize: FontSize(18),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 8, top: 8),
                ),
                "h3": Style(
                  fontSize: FontSize(16),
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(bottom: 6, top: 6),
                ),
                "ul": Style(
                  margin: Margins.only(left: 16, bottom: 8),
                ),
                "ol": Style(
                  margin: Margins.only(left: 16, bottom: 8),
                ),
                "li": Style(
                  margin: Margins.only(bottom: 4),
                ),
                "strong": Style(
                  fontWeight: FontWeight.bold,
                ),
                "em": Style(
                  fontStyle: FontStyle.italic,
                ),
                "a": Style(
                  color: Theme.of(context).colorScheme.primary,
                  textDecoration: TextDecoration.underline,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建VIP升级进度
  Widget _buildUpgradeProgress(BuildContext context) {
    final currentLevel = _vipData?['level'] as int? ?? 0;
    final holderLevel = _vipData?['holder_level'] as int? ?? 0;
    final tradingLevel = _vipData?['trading_level'] as int? ?? 0;

    // 如果已经是最高等级，不显示升级进度
    if (currentLevel >= 9) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'VIP升级进度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingCard(
            child: Column(
              children: [
                // 持有者计划等级
                _buildLevelProgressItem(
                  context,
                  title: '持有者计划',
                  icon: Icons.account_balance_wallet,
                  currentLevel: holderLevel,
                  color: Colors.blue,
                ),
                if (holderLevel != tradingLevel) const Divider(height: 24),
                // 交易型VIP等级
                if (holderLevel != tradingLevel)
                  _buildLevelProgressItem(
                    context,
                    title: '交易型VIP',
                    icon: Icons.show_chart,
                    currentLevel: tradingLevel,
                    color: Colors.orange,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建等级进度项
  Widget _buildLevelProgressItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int currentLevel,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentLevel == 0 ? '普通用户' : 'VIP$currentLevel',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'LV$currentLevel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建费率部分
  Widget _buildFeeRateSection(BuildContext context) {
    final feeRates = _vipData?['fee_rates'] as Map<String, dynamic>?;

    if (feeRates == null || feeRates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.percent, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                '交易费率',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '您的挂单/吃单费率',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          _buildFeeRatesGrid(context, feeRates),
        ],
      ),
    );
  }

  /// 构建费率网格
  Widget _buildFeeRatesGrid(BuildContext context, Map<String, dynamic> feeRates) {
    final rates = [
      if (feeRates['spot'] != null)
        {'name': '现货', 'data': feeRates['spot']},
      if (feeRates['margin'] != null)
        {'name': '杠杆', 'data': feeRates['margin']},
      if (feeRates['usdt_futures'] != null)
        {'name': 'U本位合约', 'data': feeRates['usdt_futures']},
      if (feeRates['coin_futures'] != null)
        {'name': '币本位合约', 'data': feeRates['coin_futures']},
      if (feeRates['option'] != null)
        {'name': '期权', 'data': feeRates['option']},
    ];

    return Column(
      children: rates.map((rate) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildFeeRateCard(
            context,
            rate['name'] as String,
            rate['data'] as Map<String, dynamic>,
          ),
        );
      }).toList(),
    );
  }

  /// 构建费率卡片
  Widget _buildFeeRateCard(
    BuildContext context,
    String type,
    Map<String, dynamic> rates,
  ) {
    final makerRate = _parseDouble(rates['maker']);
    final takerRate = _parseDouble(rates['taker']);
    final maker = '${(makerRate * 100).toStringAsFixed(4)}%';
    final taker = '${(takerRate * 100).toStringAsFixed(4)}%';

    return SettingCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Maker',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    maker,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Taker',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    taker,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建提现额度部分
  Widget _buildWithdrawLimitSection(BuildContext context) {
    final withdrawLimit = _vipData?['withdraw_limit_24h_usdt']?.toString() ?? '0.00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                size: 20,
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                '提现额度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24小时提现额度',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(withdrawLimit),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'USDT',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建VIP特权部分
  Widget _buildPrivilegesSection(BuildContext context) {
    final privileges = _vipData?['privileges'] as Map<String, dynamic>?;

    if (privileges == null || privileges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars,
                size: 20,
                color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'VIP特权',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              if (privileges['api_rate_limit'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.speed,
                  title: 'API请求频率',
                  value: '${privileges['api_rate_limit']}/分钟',
                ),
              if (privileges['api_rate_limit_ws'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.wifi,
                  title: 'WebSocket连接数',
                  value: '${privileges['api_rate_limit_ws']}个',
                ),
              if (privileges['customer_service'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.support_agent,
                  title: '客户服务',
                  value: _getCustomerServiceText(privileges['customer_service'].toString()),
                ),
              if (privileges['withdraw_fee_discount'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.discount,
                  title: '提现手续费折扣',
                  value: '${((1 - _parseDouble(privileges['withdraw_fee_discount'])) * 100).toStringAsFixed(0)}%折',
                ),
              if (privileges['dedicated_account_manager'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.person_pin,
                  title: '专属客户经理',
                  value: privileges['dedicated_account_manager'] == 1 ? '是' : '否',
                  highlight: privileges['dedicated_account_manager'] == 1,
                ),
              if (privileges['exclusive_events'] != null && privileges['exclusive_events'] == 1)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.event,
                  title: '专属活动',
                  value: '专享',
                  highlight: true,
                ),
              if (privileges['airdrop_priority'] != null && privileges['airdrop_priority'] == 1)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.card_giftcard,
                  title: '空投优先权',
                  value: '优先',
                  highlight: true,
                ),
              if (privileges['trading_rebate_rate'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.attach_money,
                  title: '交易返佣比例',
                  value: '${(_parseDouble(privileges['trading_rebate_rate']) * 100).toStringAsFixed(1)}%',
                ),
              if (privileges['loan_interest_discount'] != null)
                _buildPrivilegeItem(
                  context,
                  icon: Icons.trending_down,
                  title: '借贷利息折扣',
                  value: '${(_parseDouble(privileges['loan_interest_discount']) * 100).toStringAsFixed(1)}%',
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建特权项
  Widget _buildPrivilegeItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SettingCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlight
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: highlight
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取客户服务文本
  String _getCustomerServiceText(String type) {
    switch (type.toLowerCase()) {
      case 'priority':
        return '优先服务';
      case 'vip':
        return 'VIP专线';
      case 'normal':
      default:
        return '标准服务';
    }
  }

  /// 获取VIP等级名称
  String _getVipLevelName(int level) {
    if (level == 0) {
      return '普通用户';
    }
    return 'VIP $level';
  }

  /// 判断是否在降级保护期内
  bool _isInProtectionPeriod() {
    final protectionUntil = _vipData?['protection_until'] as String?;
    if (protectionUntil == null || protectionUntil.isEmpty) {
      return false;
    }

    try {
      final protectionDate = DateTime.parse(protectionUntil);
      return protectionDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// 获取降级保护文本
  String _getProtectionText() {
    final protectionUntil = _vipData?['protection_until'] as String?;
    if (protectionUntil == null || protectionUntil.isEmpty) {
      return '降级保护期已结束';
    }

    try {
      final protectionDate = DateTime.parse(protectionUntil);
      final now = DateTime.now();
      final difference = protectionDate.difference(now);

      if (difference.inDays > 0) {
        return '降级保护期：剩余${difference.inDays}天';
      } else if (difference.inHours > 0) {
        return '降级保护期：剩余${difference.inHours}小时';
      } else {
        return '降级保护期即将结束';
      }
    } catch (e) {
      return '降级保护期已结束';
    }
  }

  /// 解析颜色字符串
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;

    try {
      // 移除 # 号
      String hexColor = colorStr.replaceAll('#', '');

      // 如果是6位，添加完全不透明的alpha值
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }

  /// 获取默认VIP颜色
  Color _getDefaultVipColor(int level) {
    if (level == 0) {
      return Colors.orange[400]!;
    }
    // VIP用户使用紫色渐变
    return Colors.purple[400]!;
  }

  /// 格式化数字（添加千分位）
  String _formatNumber(String numberStr) {
    try {
      final number = double.tryParse(numberStr);
      if (number == null) return numberStr;

      if (number >= 1000) {
        return number.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
      }
      return number.toStringAsFixed(2);
    } catch (e) {
      return numberStr;
    }
  }

  /// 解析双精度浮点数（支持字符串和数字类型）
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
