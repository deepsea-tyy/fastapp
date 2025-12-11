import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/l10n/app_localizations.dart';
import 'package:fastapp/core/services/message_service.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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

  @override
  void initState() {
    super.initState();
    _messageService = MessageService(getIt());
    // 启动时下载页面配置
    _downloadPageContent();
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

  @override
  void dispose() {
    _messageService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final localeParts = _languageStore.locale.split('_');
        final locale = localeParts.length > 1
            ? Locale(localeParts[0], localeParts[1])
            : Locale(localeParts[0]);
        
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
            // 初始化消息服务（只初始化一次）
            if (!_messageServiceInitialized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _messageService.init(context, navigatorKey: _navigatorKey);
                  _messageServiceInitialized = true;
                }
              });
            } else {
              // 如果已经初始化，只更新 context
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _messageService.init(context, navigatorKey: _navigatorKey);
                }
              });
            }
            return child ?? const SizedBox();
          },
          home: const MainScreen(),
        );
      },
    );
  }
}
