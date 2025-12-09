import 'package:fastapp/presentation/di/module/store_module.dart';
import 'package:fastapp/core/services/page_content_manager.dart';
import 'package:fastapp/core/services/page_content_service.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/di/service_locator.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection() async {
    await StoreModule.configureStoreModuleInjection();
    
    // 注册页面内容管理器（需要在 StoreModule 之后，因为依赖 LanguageStore）
    getIt.registerSingleton<PageContentManager>(
      PageContentManager(
        getIt<PageContentService>(),
        getIt<LanguageStore>(),
      ),
    );
  }
}
