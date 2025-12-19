import 'dart:async';

import 'package:fastapp/core/data/local/sembast/sembast_client.dart';
import 'package:fastapp/core/services/blocked_users_service.dart';
import 'package:fastapp/core/services/not_interested_service.dart';
import 'package:fastapp/data/local/constants/db_constants.dart';
import 'package:fastapp/data/sharedpref/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastapp/di/service_locator.dart';

class LocalModule {
  static Future<void> configureLocalModuleInjection() async {
    // preference manager:------------------------------------------------------
    getIt.registerSingletonAsync<SharedPreferences>(
        SharedPreferences.getInstance);
    getIt.registerSingleton<SharedPreferenceHelper>(
      SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()),
    );
    getIt.registerSingleton<BlockedUsersService>(
      BlockedUsersService(await getIt.getAsync<SharedPreferences>()),
    );
    getIt.registerSingleton<NotInterestedService>(
      NotInterestedService(await getIt.getAsync<SharedPreferences>()),
    );

    // database:----------------------------------------------------------------

    getIt.registerSingletonAsync<SembastClient>(
      () async => SembastClient.provideDatabase(
        databaseName: DBConstants.DB_NAME,
        databasePath: kIsWeb
            ? "/assets/db"
            : (await getApplicationDocumentsDirectory()).path,
      ),
    );

    // data sources:------------------------------------------------------------
  }
}
