import 'package:flutter/material.dart';
import 'grid_trading_screen.dart';
import 'grid_strategy_detail_screen.dart';
import 'grid_bot_orders_screen.dart';
import 'widgets/bot_investment_sheet.dart';
import 'grid_bot_detail_screen.dart';

/// 网格交易主页面容器，管理交易机器人、交易、所有订单三个页面
class GridContainerScreen extends StatefulWidget {
  final int initialIndex;
  
  const GridContainerScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<GridContainerScreen> createState() => _GridContainerScreenState();
}

class _GridContainerScreenState extends State<GridContainerScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _TradingBotContent(),
          GridStrategyDetailScreen(strategyType: '现货网格'),
          GridBotOrdersScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: '交易机器人',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '交易策略',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '所有订单',
          ),
        ],
      ),
    );
  }
}

/// 交易机器人内容页面（无底部导航栏）
class _TradingBotContent extends StatefulWidget {
  const _TradingBotContent();

  @override
  State<_TradingBotContent> createState() => _TradingBotContentState();
}

class _TradingBotContentState extends State<_TradingBotContent> {
  String _selectedCategory = '全部';
  String _selectedBotType = '现货网格';
  String _selectedMarket = '现货网格';
  String _sortBy = '收益额最高';

  // 模拟数据
  final List<Map<String, dynamic>> _bots = [
    {
      'pair': 'BTC/JPY',
      'type': '现货网格',
      'status': '上移',
      'highLowCount': 42,
      'profit': 3969.30,
      'profitRate': 1.98,
      'runningTime': '5天 18时 31分',
      'minInvestment': '2493 JPY',
      'winRate24h': '35/167',
      'maxDrawdown7d': 6.48,
      'chartData': [0.2, 0.3, 0.15, 0.4, 0.35, 0.5, 0.6, 0.55, 0.7, 0.65],
    },
    {
      'pair': 'ETH/USDT',
      'type': '合约网格',
      'status': '中性',
      'highLowCount': 28,
      'profit': 1580.50,
      'profitRate': 3.25,
      'runningTime': '3天 12时 45分',
      'minInvestment': '500 USDT',
      'winRate24h': '28/98',
      'maxDrawdown7d': 4.32,
      'chartData': [0.1, 0.25, 0.2, 0.35, 0.3, 0.45, 0.5, 0.48, 0.6, 0.58],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('交易机器人', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
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
          // 搜索交易机器人卡片
          _buildSearchCard(),
          // 分类标签
          _buildCategoryTabs(),
          // 机器人类型图标
          _buildBotTypeIcons(),
          // 策略广场和筛选
          _buildStrategyHeader(),
          // 筛选器
          _buildFilters(),
          // 机器人列表
          Expanded(
            child: _buildBotList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '探索交易机器人',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '更多资讯',
                      style: TextStyle(fontSize: 14, color: Colors.amber.shade700),
                    ),
                    const Spacer(),
                    Text(
                      '1/1',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.smart_toy, size: 32, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['全部', '算法订单', '横盘整理', '看涨', '看跌'];
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildBotTypeIcons() {
    final botTypes = [
      {'icon': Icons.show_chart, 'label': '现货网格'},
      {'icon': Icons.description, 'label': '合约网格'},
      {'icon': Icons.loop, 'label': '套利机器人'},
      {'icon': Icons.pie_chart, 'label': '智能持仓'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: botTypes.map((type) {
          final isSelected = _selectedBotType == type['label'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedBotType = type['label'] as String);
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  type['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrategyHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Text(
            '策略广场',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.star_border, color: Colors.grey.shade600, size: 18),
            label: Text(
              '每日精选',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          Icon(Icons.menu, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildFilterButton(_selectedMarket),
          const SizedBox(width: 12),
          _buildFilterButton(_sortBy),
          const Spacer(),
          Icon(Icons.filter_list, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  Widget _buildBotList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bots.length,
      itemBuilder: (context, index) {
        final bot = _bots[index];
        return _buildBotCard(bot);
      },
    );
  }

  Widget _buildBotCard(Map<String, dynamic> bot) {
    final botType = bot['type'] ?? _selectedBotType;
    final isContract = botType == '合约网格';
    
    return GestureDetector(
      onTap: () {
        // 点击卡片跳转到机器人详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GridBotDetailScreen(botData: bot),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 标题行
          Row(
            children: [
              Text(
                bot['pair'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bot['status'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '高${bot['highLowCount']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '复制',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 收益和图表
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '收益额 (USD)',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${bot['profit'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00C087),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: CustomPaint(
                    painter: MiniChartPainter(
                      data: List<double>.from(bot['chartData']),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 数据行
          Row(
            children: [
              _buildDataItem('收益率', '${bot['profitRate']}%'),
              _buildDataItem('运行时间', bot['runningTime']),
              _buildDataItem('最小投资额', bot['minInvestment']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDataItem('24小时/总配对次数', bot['winRate24h']),
              const Spacer(),
              _buildDataItem('7天最大回撤', '${bot['maxDrawdown7d']}%'),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

/// 迷你图表绘制器
class MiniChartPainter extends CustomPainter {
  final List<double> data;

  MiniChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF00C087)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
