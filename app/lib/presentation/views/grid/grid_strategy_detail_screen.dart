import 'package:flutter/material.dart';
import 'widgets/strategy_type_selector.dart';
import 'widgets/bot_investment_sheet.dart';

/// 网格策略详情页面
class GridStrategyDetailScreen extends StatefulWidget {
  final String strategyType; // 现货网格、合约网格等
  
  const GridStrategyDetailScreen({
    super.key,
    required this.strategyType,
  });

  @override
  State<GridStrategyDetailScreen> createState() => _GridStrategyDetailScreenState();
}

class _GridStrategyDetailScreenState extends State<GridStrategyDetailScreen> {
  int _selectedTab = 0;
  String _selectedSymbol = 'ETHUSD CM';
  String _contractType = '永续';
  double _currentPrice = 3118.20;
  double _priceChange = -2.52;
  String? _currentStrategyType; // 当前策略类型
  
  // 策略数据
  final List<Map<String, dynamic>> _strategies = [
    {
      'name': '中短期横盘',
      'duration': '7-30 天',
      'priceRange': '2798.89 - 3522.54',
      'gridCount': 39,
      'profitPerGrid': '0.48% - 0.62%',
    },
    {
      'name': '中期波动',
      'duration': '1-2 月',
      'priceRange': '2458.18 - 3863.25',
      'gridCount': 52,
      'profitPerGrid': '0.66% - 1.05%',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentStrategyType = widget.strategyType; // 初始化当前策略类型
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            final result = await StrategyTypeSelector.show(context, _currentStrategyType ?? widget.strategyType);
            if (result != null && result != _currentStrategyType) {
              setState(() {
                _currentStrategyType = result;
                // 重置选项卡为默认的AI选项卡
                _selectedTab = 0;
              });
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentStrategyType ?? widget.strategyType,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ],
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 标签栏
          _buildTabBar(),
          // 内容区域
          Expanded(
            child: _selectedTab == 0 ? _buildAIContent() : _buildManualContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['AI', '手动创建'];
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTab == index;
          
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 16.0 : 0),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: 28,
                    height: 3,
                    child: isSelected
                        ? Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAIContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易对信息
          _buildSymbolHeader(),
          // 中性/做多/做空按钮
          _buildPositionTypeButtons(),
          // 策略列表
          _buildStrategyList(),
        ],
      ),
    );
  }

  Widget _buildManualContent() {
    final strategyType = _currentStrategyType ?? widget.strategyType;
    // 根据策略类型显示不同的创建表单
    if (strategyType == '现货网格') {
      return _buildSpotGridForm();
    } else if (strategyType == '合约网格') {
      return _buildContractGridForm();
    } else if (strategyType == '套利机器人') {
      return _buildArbitrageForm();
    } else if (strategyType == '智能持仓') {
      return _buildSmartHoldingForm();
    } else {
      return _buildContractGridForm(); // 默认使用合约网格表单
    }
  }
  
  // 套利机器人表单（占位）
  Widget _buildArbitrageForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_exchange, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '套利机器人',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '以风险中立策略轻松套利资金费率',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 智能持仓表单（占位）
  Widget _buildSmartHoldingForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '智能持仓',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '多币投资，智能持有',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 现货网格创建表单
  Widget _buildSpotGridForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易对选择器和价格显示
          _buildSpotSymbolHeader(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRangeSection(),
          const SizedBox(height: 16),
          _buildGridCountSection(),
          const SizedBox(height: 16),
          _buildSpotInvestmentSection(),
          const SizedBox(height: 16),
          _buildSpotAvailableInfo(),
          const SizedBox(height: 24),
          _buildSpotAdvancedOptions(),
          const SizedBox(height: 16),
          _buildCreateButton('创建'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 现货网格交易对头部
  Widget _buildSpotSymbolHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 交易对选择器
                GestureDetector(
                  onTap: () {
                    // TODO: 打开交易对选择器
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BTC/USDT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 价格和涨跌幅
                Row(
                  children: [
                    const Text(
                      '91274.75',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '-2.36%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 右侧图标
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.insert_chart_outlined, color: Colors.grey.shade600),
                onPressed: () {
                  // TODO: 打开图表
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.bar_chart, color: Colors.grey.shade600),
                onPressed: () {
                  // TODO: 打开深度图
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 合约网格创建表单
  Widget _buildContractGridForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交易对选择器和价格显示
          _buildContractSymbolHeader(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDirectionButtons(),
          const SizedBox(height: 16),
          _buildPriceRangeSection(),
          const SizedBox(height: 16),
          _buildGridCountSection(),
          const SizedBox(height: 16),
          _buildContractInvestmentSection(),
          const SizedBox(height: 16),
          _buildContractAvailableInfo(),
          const SizedBox(height: 24),
          _buildContractAdvancedOptions(),
          const SizedBox(height: 16),
          _buildCreateButton('创建（中性）'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 合约网格交易对头部
  Widget _buildContractSymbolHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 交易对选择器
                GestureDetector(
                  onTap: () {
                    // TODO: 打开交易对选择器
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ETHUSD CM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '永续',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 价格和涨跌幅
                Row(
                  children: [
                    Text(
                      _currentPrice.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_priceChange >= 0 ? '+' : ''}${_priceChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 右侧图标
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
                onPressed: () {
                  // TODO: 打开通知设置
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.bar_chart, color: Colors.grey.shade600),
                onPressed: () {
                  // TODO: 打开深度图
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 方向选择按钮（合约专用）
  String _selectedDirection = '中性';
  
  Widget _buildDirectionButtons() {
    return Row(
      children: [
        _buildDirectionButton('中性'),
        const SizedBox(width: 12),
        _buildDirectionButton('做多'),
        const SizedBox(width: 12),
        _buildDirectionButton('做空'),
      ],
    );
  }

  Widget _buildDirectionButton(String label) {
    final isSelected = _selectedDirection == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDirection = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black87 : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // 价格范围（通用）
  Widget _buildPriceRangeSection() {
    final strategyType = _currentStrategyType ?? widget.strategyType;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strategyType == '现货网格' ? '1. 价格区间' : '1. 价格范围',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      strategyType == '现货网格' ? '3天 AI' : '30天 AI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField('最低价格'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField('最高价格'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示投资金额弹窗
  // 网格数量（通用）
  Widget _buildGridCountSection() {
    final strategyType = _currentStrategyType ?? widget.strategyType;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. 网格数量',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  strategyType == '现货网格' ? '2-170' : '2-169',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      strategyType == '现货网格' ? '等差' : '等差网格',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '每格利润（已扣除费用）                --%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // 现货投资额
  Widget _buildSpotInvestmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3. 投资额',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Text(
                      'USDT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '>0',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                'USDT',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示投资金额弹窗
  // 合约投资额
  Widget _buildContractInvestmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. 投资额（保证金）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '>=0 ETH',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Text(
                      '10x',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 现货可用信息
  Widget _buildSpotAvailableInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '可用',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Text(
              '0.00 USDT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.add_circle_outline, size: 20, color: Colors.amber.shade700),
          ],
        ),
      ],
    );
  }

  // 合约可用信息
  Widget _buildContractAvailableInfo() {
    return Column(
      children: [
        _buildInfoRow('可用', '0.0000 ETH', true),
        const SizedBox(height: 8),
        _buildInfoRow('每笔数量', '-- 张'),
        const SizedBox(height: 8),
        _buildInfoRow('总投资额', '-- ETH'),
        const SizedBox(height: 8),
        _buildInfoRow('保证金模式', '全仓'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [bool highlight = false]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: highlight ? Colors.amber.shade700 : Colors.grey.shade600,
              ),
            ),
            if (highlight) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Colors.amber.shade700),
            ],
          ],
        ),
      ],
    );
  }

  // 现货进阶选项
  bool _enableUpMove = false;
  bool _enableGridTrigger = false;
  bool _enableStopProfit = false;
  bool _enableSellAll = true;

  Widget _buildSpotAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdvancedHeader(),
          const SizedBox(height: 16),
          _buildCheckboxOption('上移', _enableUpMove, (value) => setState(() => _enableUpMove = value)),
          const SizedBox(height: 16),
          _buildCheckboxOption('网格触发', _enableGridTrigger, (value) => setState(() => _enableGridTrigger = value)),
          const SizedBox(height: 16),
          _buildCheckboxOption('止盈/止损', _enableStopProfit, (value) => setState(() => _enableStopProfit = value)),
          const SizedBox(height: 16),
          _buildCheckboxOption('终止时出售全部 BTC', _enableSellAll, (value) => setState(() => _enableSellAll = value)),
        ],
      ),
    );
  }

  // 合约进阶选项
  bool _enableContractGridTrigger = true;
  bool _enableContractStopProfit = true;
  bool _enableStopLoss = true;

  Widget _buildContractAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdvancedHeader(),
          const SizedBox(height: 16),
          _buildCheckboxOption('网格触发', _enableContractGridTrigger, (value) => setState(() => _enableContractGridTrigger = value)),
          if (_enableContractGridTrigger) ...[
            const SizedBox(height: 8),
            _buildInputField('触发价格', suffix: '标记'),
          ],
          const SizedBox(height: 16),
          _buildCheckboxOption('止盈/止损', _enableContractStopProfit, (value) => setState(() => _enableContractStopProfit = value)),
          if (_enableContractStopProfit) ...[
            const SizedBox(height: 8),
            _buildDropdownField('全部平仓'),
            const SizedBox(height: 8),
            _buildInputField('终止最低价格', suffix: '标记'),
            const SizedBox(height: 8),
            _buildInputField('终止最高价格', suffix: '标记'),
          ],
          const SizedBox(height: 16),
          _buildCheckboxOption('终止时全部平仓', _enableStopLoss, (value) => setState(() => _enableStopLoss = value)),
        ],
      ),
    );
  }

  Widget _buildAdvancedHeader() {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                '进阶（可选）',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
            ],
          ),
          Icon(Icons.keyboard_arrow_up, size: 20, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String hint, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    suffix,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildCreateButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // TODO: 创建网格策略
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber.shade400,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSymbolHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedSymbol,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _contractType,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _currentPrice.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_priceChange >= 0 ? '+' : ''}${_priceChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: _priceChange >= 0 ? const Color(0xFF00C087) : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.notifications_outlined, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Icon(Icons.add_chart_outlined, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  String _selectedPositionType = '中性';

  Widget _buildPositionTypeButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildPositionTypeButton('中性', isSelected: _selectedPositionType == '中性'),
          const SizedBox(width: 12),
          _buildPositionTypeButton('做多', isSelected: _selectedPositionType == '做多'),
          const SizedBox(width: 12),
          _buildPositionTypeButton('做空', isSelected: _selectedPositionType == '做空'),
        ],
      ),
    );
  }

  Widget _buildPositionTypeButton(String label, {required bool isSelected}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPositionType = label;
            // TODO: 根据选择的类型筛选策略列表数据
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey.shade100 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _strategies.length,
      itemBuilder: (context, index) {
        return _buildStrategyCard(_strategies[index]);
      },
    );
  }

  Widget _buildStrategyCard(Map<String, dynamic> strategy) {
    return GestureDetector(
      onTap: () {
        // 点击整行显示投资金额弹窗
        _showInvestmentSheet(strategy);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和复制按钮
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strategy['duration'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 显示投资金额弹窗
                    _showInvestmentSheet(strategy);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '复制',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 策略参数
            _buildStrategyParam('价格区间 (USD)', strategy['priceRange']),
            const SizedBox(height: 12),
            _buildStrategyParam('网格数量', strategy['gridCount'].toString()),
            const SizedBox(height: 12),
            _buildStrategyParam('每格利润（已扣除费用）', strategy['profitPerGrid']),
            const SizedBox(height: 16),
            // 自定义参数按钮
            Row(
              children: [
                Text(
                  '自定义参数',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 显示投资金额弹窗
  void _showInvestmentSheet(Map<String, dynamic> strategy) {
    final strategyType = _currentStrategyType ?? widget.strategyType;
    final isSpotGrid = strategyType == '现货网格';
    
    BotInvestmentSheet.show(
      context,
      botPair: isSpotGrid ? 'BTC/USDT' : _selectedSymbol,
      botType: strategyType,
      botDetails: {
        'suggestedDuration': strategy['duration'] ?? '3-7 天',
        'priceRange': strategy['priceRange'] ?? '2798.89 - 3522.54',
        'gridCount': strategy['gridCount'] ?? 14,
        'mode': '等差网格',
        'profitPerGrid': strategy['profitPerGrid'] ?? '0.48% - 0.62%',
        if (isSpotGrid)
          'sellAllOnStop': '已启用',
        if (!isSpotGrid) ...{
          'direction': _selectedPositionType, // 使用当前选择的方向
          'closeAllOnStop': '已启用',
        },
      },
    );
  }

  Widget _buildStrategyParam(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
