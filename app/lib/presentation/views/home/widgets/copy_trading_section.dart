import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/copy_trading/trader_card.dart';
import 'package:fastapp/presentation/store/home/home_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CopyTradingSection extends StatelessWidget {
  const CopyTradingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final store = getIt<HomeStore>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '交易"智"变，轻松跟单！',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStats(context),
          const SizedBox(height: 20),
          Text(
            '热门交易员',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Observer(
            builder: (_) => SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: store.traderCards.length,
                itemBuilder: (context, index) {
                  return _buildTraderCard(context, store.traderCards[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatItem(context, '190,000', '交易专家人数', theme),
          _buildStatItem(context, '\$20,000,000+', '总利润分成', theme),
          _buildStatItem(context, '\$4,500,000,000', '跟单者资产规模', theme),
          _buildStatItem(context, '\$500,000,000+', '跟单者盈亏', theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, ThemeData theme) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 10.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraderCard(BuildContext context, TraderCard trader) {
    final isPositive = trader.roi30Days >= 0;

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: trader.avatarUrl,
                width: 40,
                height: 40,
                placeholder: (context, url) => CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trader.username,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${trader.copyCount}/${trader.maxCopyCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '30日跟单者收益',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 10.0,
                    ),
                  ),
                  Text(
                    '\$${trader.profit30Days.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${trader.roi30Days.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Theme.of(context).colorScheme.error,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '30天 ROI',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 跟单操作
              },
              child: const Text(
                '跟单',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

