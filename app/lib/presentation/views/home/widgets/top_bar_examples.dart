// ============================================
// TopBar 搜索图标配置示例
// ============================================

import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/home/widgets/top_bar.dart';
import 'package:fastapp/utils/color_utils.dart';

// ============================================
// 示例 1: 使用默认配置（火焰图标 + "MBL"）
// ============================================
class Example1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        unreadMessageCount: 5,
      ),
      body: Center(child: Text('默认配置示例')),
    );
  }
}

// ============================================
// 示例 2: 从服务器获取的热门搜索词配置
// ============================================
class Example2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 假设从服务器获取的热门搜索关键词数据
    final hotKeyword = {
      'keyword': 'BTC',
      'icon': 'material-symbols:trending-up', // 趋势上升图标
      'color': '#4CAF50', // 自定义颜色（绿色）
    };

    return Scaffold(
      appBar: TopBar(
        searchIconName: hotKeyword['icon'] as String?,
        searchKeyword: hotKeyword['keyword'] as String?,
        searchIconColor: ColorUtils.fromHex(hotKeyword['color'] as String?), // 解析颜色
        unreadMessageCount: 3,
      ),
      body: Center(child: Text('服务器配置示例')),
    );
  }
}

// ============================================
// 示例 3: 使用自定义颜色
// ============================================
class Example3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        searchIconName: 'material-symbols:star',
        searchKeyword: 'HOT',
        searchIconColor: Colors.amber, // 自定义颜色
        unreadMessageCount: 0,
      ),
      body: Center(child: Text('自定义颜色示例')),
    );
  }
}

// ============================================
// 示例 4: 动态更新搜索图标（完整示例）
// ============================================
class Example4 extends StatefulWidget {
  @override
  _Example4State createState() => _Example4State();
}

class _Example4State extends State<Example4> {
  String? _currentIcon;
  String? _currentKeyword;
  Color? _currentColor;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHotKeyword();
  }

  // 从服务器加载热门搜索关键词
  Future<void> _loadHotKeyword() async {
    // TODO: 调用实际的 API
    // final response = await api.getHotKeyword();

    // 模拟 API 响应
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _currentIcon = 'material-symbols:local-fire-department';
      _currentKeyword = 'BTC/USDT';
      _currentColor = ColorUtils.fromHex('#FF6B35'); // 解析服务器返回的颜色
      _unreadCount = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        searchIconName: _currentIcon,
        searchKeyword: _currentKeyword,
        searchIconColor: _currentColor,
        unreadMessageCount: _unreadCount,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('动态更新示例'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 切换到其他热门关键词
                setState(() {
                  _currentIcon = 'material-symbols:star';
                  _currentKeyword = 'ETH';
                  _currentColor = ColorUtils.fromHex('#FFD700'); // 金色
                });
              },
              child: Text('切换关键词'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// 示例 5: 与 API 集成（推荐方式）
// ============================================

// 1. 首先定义搜索关键词数据模型
class SearchKeyword {
  final String keyword;
  final String? icon;
  final String? color; // 新增：自定义颜色
  final int hitCount;

  SearchKeyword({
    required this.keyword,
    this.icon,
    this.color,
    required this.hitCount,
  });

  factory SearchKeyword.fromJson(Map<String, dynamic> json) {
    return SearchKeyword(
      keyword: json['keyword'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?, // 从 API 获取颜色
      hitCount: json['hit_count'] as int? ?? 0,
    );
  }
}

// 2. 创建搜索关键词服务
class SearchKeywordService {
  // 获取热门搜索关键词（点击次数最高的）
  Future<SearchKeyword?> getHotKeyword() async {
    try {
      // TODO: 调用实际的 API
      // final response = await http.get('/api/search/keywords/hot');
      // return SearchKeyword.fromJson(response.data);

      // 模拟返回数据
      return SearchKeyword(
        keyword: 'BTC',
        icon: 'material-symbols:local-fire-department',
        color: '#FF6B35', // 服务器返回的自定义颜色
        hitCount: 1000,
      );
    } catch (e) {
      print('获取热门关键词失败: $e');
      return null;
    }
  }

  // 获取推荐搜索关键词列表
  Future<List<SearchKeyword>> getRecommendedKeywords() async {
    try {
      // TODO: 调用实际的 API
      // final response = await http.get('/api/search/keywords/recommended');
      // return (response.data as List)
      //     .map((json) => SearchKeyword.fromJson(json))
      //     .toList();

      // 模拟返回数据
      return [
        SearchKeyword(
          keyword: 'BTC',
          icon: 'material-symbols:local-fire-department',
          color: '#FF6B35',
          hitCount: 1000,
        ),
        SearchKeyword(
          keyword: 'ETH',
          icon: 'material-symbols:trending-up',
          color: '#4CAF50',
          hitCount: 800,
        ),
        SearchKeyword(
          keyword: 'HOT',
          icon: 'material-symbols:star',
          color: '#FFD700',
          hitCount: 600,
        ),
      ];
    } catch (e) {
      print('获取推荐关键词失败: $e');
      return [];
    }
  }
}

// 3. 在主页中使用
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SearchKeywordService _searchService = SearchKeywordService();
  SearchKeyword? _hotKeyword;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 并行加载热门关键词和未读消息数
    final results = await Future.wait([
      _searchService.getHotKeyword(),
      _loadUnreadMessageCount(),
    ]);

    setState(() {
      _hotKeyword = results[0] as SearchKeyword?;
      _unreadMessageCount = results[1] as int;
    });
  }

  Future<int> _loadUnreadMessageCount() async {
    // TODO: 从实际 API 获取未读消息数
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        searchIconName: _hotKeyword?.icon,
        searchKeyword: _hotKeyword?.keyword,
        searchIconColor: ColorUtils.fromHex(_hotKeyword?.color), // 解析颜色字符串
        unreadMessageCount: _unreadMessageCount,
      ),
      body: Center(
        child: Text('首页内容'),
      ),
    );
  }
}

// ============================================
// 可用的图标配置清单
// ============================================
/*
以下是所有可用的图标及其对应的 Web 端名称：

1. 火焰图标(热门): 'material-symbols:local-fire-department'
2. 搜索图标: 'material-symbols:search'
3. 时钟图标(历史): 'material-symbols:history'
4. 星标图标(收藏): 'material-symbols:star'
5. 趋势图标(上升): 'material-symbols:trending-up'
6. 位置图标(附近): 'material-symbols:location-on'
7. 标签图标: 'material-symbols:label'
8. 闪电图标(快速): 'material-symbols:flash-on'
9. 新品图标: 'material-symbols:new-releases'
10. 推荐图标: 'material-symbols:recommend'

使用方法：
TopBar(
  searchIconName: '从上面列表中选择',
  searchKeyword: '显示的文字',
)

注意：
- 如果不提供 searchIconName，将使用默认的火焰图标
- 如果不提供 searchKeyword，将显示 "MBL"
- 图标颜色会自动匹配配置，也可以通过 searchIconColor 自定义
*/
