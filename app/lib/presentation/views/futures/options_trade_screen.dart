import 'package:flutter/material.dart';

/// 期权交易页面
class OptionsTradeScreen extends StatefulWidget {
  const OptionsTradeScreen({super.key});

  @override
  State<OptionsTradeScreen> createState() => _OptionsTradeScreenState();
}

class _OptionsTradeScreenState extends State<OptionsTradeScreen> {
  int _selectedTopTab = 2; // 0: U本位, 1: 币本位, 2: 期权
  int _selectedTypeTab = 1; // 0: 自选, 1: 全部, 2: 看涨期权, 3: 看跌期权, 4: T字报价
  int _selectedDateTab = 0; // 选中的到期日期索引
  String _selectedSymbol = 'ETH';
  
  final List<String> _expirationDates = [
    '25-12-01',
    '25-12-02',
    '25-12-03',
    '25-12-04',
    '25-12-05',
    '25-12-06',
    '25-12-07',
    '25-12-08',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部导航栏
          _buildTopNavigation(),
          
          // 资产信息和操作图标
          _buildAssetInfo(),
          
          // 期权类型筛选
          _buildTypeFilters(),
          
          // 到期日期选择
          _buildDateSelector(),
          
          // 指数价格
          _buildIndexPrice(),
          
          // 期权合约表格
          Expanded(
            child: _buildOptionsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Row(
              children: [
                _buildTopTab('U本位', 0),
                const SizedBox(width: 16),
                _buildTopTab('币本位', 1),
                const SizedBox(width: 16),
                _buildTopTab('期权', 2),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              // TODO: 显示菜单
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, int index) {
    final isSelected = _selectedTopTab == index;
    return GestureDetector(
      onTap: () {
        if (index != 2) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 资产选择
          GestureDetector(
            onTap: () {
              // TODO: 显示资产选择器
            },
            child: Row(
              children: [
                Text(
                  '$_selectedSymbol 期权',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 指数价格
          Text(
            '3014.3',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'BVOL:74.41',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          // 操作图标
          IconButton(
            icon: const Icon(Icons.crop_free, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.percent, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, size: 20),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters() {
    final types = ['自选', '全部', '看涨期权', '看跌期权', 'T字报价'];
    
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...types.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = _selectedTypeTab == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTypeTab = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._expirationDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isSelected = _selectedDateTab == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateTab = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIndexPrice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '指数价格: 3,014.3',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          headingRowHeight: 40,
          dataRowHeight: 56,
          columns: const [
            DataColumn(
              label: Text(
                '行权价格',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '类型',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '买价 / IV',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '标记价',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '卖价 / IV',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '到期时间',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
          rows: _buildTableRows(),
        ),
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    // 模拟期权合约数据
    final options = [
      {'strike': 2700.0, 'type': '看涨', 'bid': 254.6, 'bidIV': '0.00%', 'mark': 314.7, 'markIV': '80.60%', 'ask': null, 'askIV': null},
      {'strike': 2700.0, 'type': '看跌', 'bid': 0.2, 'bidIV': '91.56%', 'mark': 0.1, 'markIV': '91.56%', 'ask': 0.4, 'askIV': '99.28%'},
      {'strike': 2800.0, 'type': '看涨', 'bid': 183.4, 'bidIV': '0.00%', 'mark': 215.3, 'markIV': '75.44%', 'ask': null, 'askIV': null},
      {'strike': 2800.0, 'type': '看跌', 'bid': 0.5, 'bidIV': '85.23%', 'mark': 0.3, 'markIV': '85.23%', 'ask': 0.7, 'askIV': '90.15%'},
      {'strike': 2900.0, 'type': '看涨', 'bid': 120.5, 'bidIV': '0.00%', 'mark': 145.2, 'markIV': '70.30%', 'ask': 150.0, 'askIV': '72.15%'},
      {'strike': 2900.0, 'type': '看跌', 'bid': 1.2, 'bidIV': '78.45%', 'mark': 0.9, 'markIV': '78.45%', 'ask': 1.5, 'askIV': '82.30%'},
      {'strike': 3000.0, 'type': '看涨', 'bid': 80.3, 'bidIV': '0.00%', 'mark': 95.6, 'markIV': '65.20%', 'ask': 100.0, 'askIV': '67.50%'},
      {'strike': 3000.0, 'type': '看跌', 'bid': 2.5, 'bidIV': '72.10%', 'mark': 2.0, 'markIV': '72.10%', 'ask': 3.0, 'askIV': '75.80%'},
    ];

    return options.map((option) {
      final bid = option['bid'] as double?;
      final ask = option['ask'] as double?;
      
      return DataRow(
        cells: [
          DataCell(
            Row(
              children: [
                Text(
                  '${(option['strike'] as double).toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              '${option['type']}...',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid != null ? bid.toStringAsFixed(1) : '--',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: bid != null ? Colors.green : Colors.grey.shade400,
                  ),
                ),
                Text(
                  option['bidIV'] as String? ?? '--%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (option['mark'] as num).toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  option['markIV'] as String? ?? '--%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ask != null ? ask.toStringAsFixed(1) : '--',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ask != null ? Colors.red : Colors.grey.shade400,
                  ),
                ),
                Text(
                  option['askIV'] as String? ?? '--%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            Text(
              _expirationDates[_selectedDateTab],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
