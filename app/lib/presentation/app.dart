import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/presentation/views/main/main_screen.dart';
import 'package:fastapp/presentation/store/app/language_store.dart';
import 'package:fastapp/presentation/store/app/theme_store.dart';
import 'package:fastapp/utils/routes/routes.dart';
import 'package:fastapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'package:fastapp/di/service_locator.dart';

class App extends StatelessWidget {
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final localeParts = _languageStore.locale.split('_');
        final locale = localeParts.length > 1
            ? Locale(localeParts[0], localeParts[1])
            : Locale(localeParts[0]);
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: _themeStore.themeData,
          routes: Routes.routes,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const MainScreen(),
        );
      },
    );
  }
}
