import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/crypto/crypto_coin.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MobileCryptoListSection extends StatelessWidget {
  const MobileCryptoListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<HomeStore>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '行情',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Observer(
            builder: (_) => DefaultTabController(
              length: 3,
              initialIndex: store.cryptoTabIndex,
              child: Column(
                children: [
                  TabBar(
                    onTap: (index) {
                      store.setCryptoTabIndex(index);
                    },
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    dividerColor: Colors.transparent,
                    tabs: [
                      const Tab(text: '热门榜'),
                      const Tab(text: '涨幅榜'),
                      const Tab(text: '新币榜'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildCryptoList(context, store.cryptoCoins),
                        _buildCryptoList(context, store.cryptoCoins),
                        _buildCryptoList(context, store.cryptoCoins),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // TODO: 跳转到全部代币页面
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              label: Text(
                '查看全部',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoList(BuildContext context, List<CryptoCoin> coins) {
    return ListView.builder(
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        final isPositive = coin.changePercent >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              coin.logoUrl.isEmpty
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.currency_bitcoin,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: coin.logoUrl,
                      width: 40,
                      height: 40,
                      placeholder: (context, url) => SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.currency_bitcoin,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.symbol,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      coin.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    coin.price.toStringAsFixed(coin.price < 1 ? 4 : 2),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${coin.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Theme.of(context).colorScheme.error,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  // TODO: 跳转到交易页面
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
                  '交易',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

