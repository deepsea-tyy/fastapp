import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/presentation/store/app/user_store.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:fastapp/presentation/store/market/market_data_store.dart';
import 'package:fastapp/presentation/store/market/market_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/l10n/app_localizations.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/core/services/app_startup_state.dart';
import 'package:fastapp/core/services/exchange_rate_service.dart';
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
    // 启动时先完成页面配置下载，然后并发执行其他请求
    _initStartupRequests();
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

  /// 初始化启动请求
  /// 先完成 pageContentDownload，然后并发执行其他请求
  void _initStartupRequests() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // 先完成页面配置下载
        final pageContentManager = getIt<PageContentManager>();
        await pageContentManager.initialize();
      } catch (e) {
        // 下载失败不影响启动流程
      } finally {
        // 无论成功失败都标记完成，确保其他页面不会一直等待
        AppStartupState.markPageContentDownloaded();
        // 并发执行其他请求
        _startConcurrentRequests();
      }
    });
  }

  /// 启动并发请求（不等待彼此完成）
  void _startConcurrentRequests() {
    // 并发执行，不等待彼此完成
    // 市场数据配置下载
    Future.microtask(() async {
      try {
        final marketDataStore = getIt<MarketDataStore>();
        await marketDataStore.loadMarketData();
      } catch (e) {
        // 下载失败不影响app启动，静默失败
      }
    });

    // 预加载汇率
    Future.microtask(() async {
      try {
        final exchangeRateService = getIt<ExchangeRateService>();
        await exchangeRateService.getExchangeRate();
      } catch (e) {
        // 下载失败不影响app启动，静默失败
      }
    });

    // 初始化用户信息（如果已登录）
    Future.microtask(() async {
      try {
        final userStore = getIt<UserStore>();
        await userStore.initializeUser();
      } catch (e) {
        // 请求失败不影响app启动，静默失败
      }
    });

    // 初始化 WebSocket 连接（游客模式或认证模式）
    Future.microtask(() async {
      try {
        final marketStore = getIt<MarketStore>();
        final sharedPrefHelper = getIt<SharedPreferenceHelper>();
        final token = await sharedPrefHelper.authToken;

        // 如果用户已登录且有 token，使用 token 连接（认证模式）
        // 否则使用游客模式连接
        if (token != null && token.isNotEmpty) {
          await marketStore.webSocket.connect(token: token);
        } else {
          await marketStore.ensureWebSocketConnected();
        }
      } catch (e) {
        // 连接失败不影响app启动，静默失败
      }
    });

    // 其他需要启动时执行的请求可以在这里添加
    // 它们会并发执行，不等待彼此完成
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
