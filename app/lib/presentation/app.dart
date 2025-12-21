import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/l10n/app_localizations.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/core/data/network/dio/interceptors/token_refresh_interceptor.dart';
import 'package:fastapp/presentation/views/home/widgets/quick/quick_entrance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import 'package:fastapp/di/service_locator.dart';

class App extends StatefulWidget {
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late MessageService _messageService;
  bool _messageServiceInitialized = false;
  StreamSubscription<ForceLogoutEvent>? _forceLogoutSubscription;

  @override
  void initState() {
    super.initState();
    _messageService = MessageService(getIt());
    // 启动时下载页面配置
    _downloadPageContent();
    // 启动时下载市场数据配置
    _downloadMarketData();
    // 监听强制登出事件
    _listenToForceLogout();
  }

  /// 监听强制登出事件
  void _listenToForceLogout() {
    final eventBus = getIt<EventBus>();
    _forceLogoutSubscription = eventBus.on<ForceLogoutEvent>().listen((event) {
      // 清除 UserStore 状态
      try {
        runInAction(() {
          final userStore = getIt<UserStore>();
          userStore.isLoggedIn = false;
          userStore.currentUser = null;
        });
      } catch (e) {
        // 忽略错误
      }
      
      // 跳转到登录页
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = _navigatorKey.currentState;
        if (navigator != null) {
          navigator.pushNamedAndRemoveUntil(Routes.login, (route) => false);
          if (event.message.isNotEmpty) {
            MessageService.snackBar(event.message);
          }
        }
      });
    });
  }

  /// 下载页面配置（后台静默下载，不影响启动）
  /// 每次启动都会请求服务器更新配置，无缓存则保存，有缓存则更新
  void _downloadPageContent() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 初始化页面内容管理器
        // initialize() 会先请求服务器，成功则保存/更新本地缓存，失败则使用本地缓存
        final pageContentManager = getIt<PageContentManager>();
        await pageContentManager.initialize();
      } catch (e) {
        // 下载失败不影响app启动，静默失败
      }
    });
  }

  /// 下载市场数据配置（后台静默下载，不影响启动）
  /// APP启动时从服务器获取币种、现货、合约、期权配置
  void _downloadMarketData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final marketDataStore = getIt<MarketDataStore>();
        await marketDataStore.loadMarketData();
      } catch (e) {
        // 下载失败不影响app启动，静默失败
      }
    });
  }

  @override
  void dispose() {
    _forceLogoutSubscription?.cancel();
    _messageService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QuickEntranceState(),
        ),
      ],
      child: Observer(
        builder: (context) {
          final locale = _parseLocale(_languageStore.locale);
          
          return MaterialApp(
            key: const ValueKey('main_material_app'),
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: _themeStore.themeData,
            routes: Routes.routes,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) {
              _initMessageService(context);
              return child ?? const SizedBox();
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }

  /// 解析 locale 字符串
  Locale _parseLocale(String localeStr) {
    final parts = localeStr.split('_');
    return parts.length > 1 
        ? Locale(parts[0], parts[1])
        : Locale(parts[0]);
  }

  /// 初始化消息服务
  void _initMessageService(BuildContext context) {
    if (!_messageServiceInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _messageService.init(context, navigatorKey: _navigatorKey);
          _messageServiceInitialized = true;
        }
      });
    } else {
      // 已初始化，只更新 context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _messageService.init(context, navigatorKey: _navigatorKey);
        }
      });
    }
  }
}
