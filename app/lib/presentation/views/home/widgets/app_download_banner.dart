import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AppDownloadBanner extends StatelessWidget {
  const AppDownloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<HomeStore>();

    return Observer(
      builder: (_) {
        if (!store.showAppBanner) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone_android,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bitget App',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '交易"智"变',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 打开 App
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                ),
                child: const Text(
                  '打开',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
                onPressed: () {
                  store.hideAppBanner();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}

