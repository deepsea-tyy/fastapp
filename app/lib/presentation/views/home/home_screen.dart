/// 移动端首页
///
/// 这是加密货币交易平台的移动端首页，包含以下主要模块：
/// - 加密货币行情：热门榜、涨幅榜、新币榜
/// - 开始您的加密货币之旅：功能介绍
/// - 交易"智"变跟单：跟单交易员展示
/// - 值得您信赖的平台：安全特性
/// - 底部导航栏：首页、行情、交易、合约、资产
///
/// 使用 Bitget 深色主题，适配移动端屏幕尺寸（375x667）。
///
/// 示例：
/// ```dart
/// MaterialApp(
///   home: HomeScreen(),
/// )
/// ```
import 'package:fastapp/presentation/views/home/widgets/top_bar.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/copy_trading_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/journey_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/mobile_crypto_list_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/trust_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/tologin_section.dart';
import 'package:fastapp/presentation/views/home/widgets/sections/quick_entrance_section.dart';
import 'package:fastapp/presentation/views/home/widgets/feed/feed_section.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 移动端首页组件
///
/// 这是一个有状态的 Widget，使用 [StatefulWidget] 实现。
/// 页面采用垂直滚动的单列布局，所有内容模块按顺序排列。
///
/// 页面结构：
/// 1. [TopBar] - 顶部导航栏（Logo、搜索、菜单）
/// 2. [ToLoginSection] - 未登录时的欢迎区域（仅在未登录时显示）
/// 3. [MobileCryptoListSection] - 加密货币行情列表
/// 4. [JourneySection] - 开始您的加密货币之旅
/// 5. [CopyTradingSection] - 交易"智"变跟单
/// 6. [TrustSection] - 值得您信赖的平台
/// 7. [BottomNavBar] - 底部导航栏
class HomeScreen extends StatefulWidget {
  /// 创建移动端首页
  ///
  /// [key] 用于标识此 Widget 的键值
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserStore _userStore = getIt<UserStore>();

  @override
  void initState() {
    super.initState();
    // 页面初始化时，如果已登录但用户信息未加载，则获取用户信息
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当页面重新可见时（例如从其他页面返回），检查是否需要刷新用户信息
    if (_userStore.isLoggedIn && _userStore.currentUser == null) {
      _userStore.getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // 使用浅灰色作为背景色
      backgroundColor: Colors.grey[200],
      
      // 顶部导航栏
      appBar: TopBar(
        onMenuPressed: () {
          Navigator.of(context).pushNamed(Routes.userCenter);
        },
      ),
      
      // 页面主体内容，使用可滚动视图
      body: Observer(
        builder: (_) {
          // 确保访问 observable，即使条件为 false
          final isLoggedIn = _userStore.isLoggedIn;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // 登录后显示快捷入口
                if (isLoggedIn) ...[
                  const QuickEntranceSection(),
                  
                  // 信息流区域
                  const FeedSection(),
                ],
                
                // 未登录时显示的内容
                if (!isLoggedIn) ...[
                  Container(
                    color: Colors.white,
                    child: const ToLoginSection(),
                  ),
                  
                  // 加密货币行情区域：热门榜、涨幅榜、新币榜
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    child: const MobileCryptoListSection(),
                  ),
                  
                  // 开始您的加密货币之旅：功能介绍
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    child: const JourneySection(),
                  ),
                  
                  // 交易"智"变跟单：跟单交易员展示
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    child: const CopyTradingSection(),
                  ),
                  
                  // 值得您信赖的平台：安全特性
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 8),
                    child: const TrustSection(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

