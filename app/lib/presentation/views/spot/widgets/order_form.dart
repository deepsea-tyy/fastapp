import 'package:fastapp/constants/app_config.dart';
import 'package:fastapp/di/service_locator.dart';
import 'package:fastapp/domain/entity/order/order_side.dart';
import 'package:fastapp/domain/entity/order/order_type.dart';
import 'package:fastapp/presentation/store/spot/spot_trade_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// 订单表单组件
class OrderForm extends StatelessWidget {
  const OrderForm({super.key});

  @override
  Widget build(BuildContext context) {
    final SpotTradeStore store = getIt<SpotTradeStore>();

    return Observer(
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 买入/卖出切换按钮
            _buildTradeSideSelector(context, store),
            const SizedBox(height: 16),
            
            // 订单类型选择
            _buildOrderTypeSelector(context, store),
            const SizedBox(height: 16),
            
            // 价格输入（限价单显示）
            if (store.orderType == OrderType.limit) ...[
              _buildPriceInput(context, store),
              const SizedBox(height: 16),
            ],
            
            // 数量输入
            _buildQuantityInput(context, store),
            const SizedBox(height: 16),
            
            // 金额输入（市价买入显示）
            if (store.orderType == OrderType.market && store.tradeSide == OrderSide.buy) ...[
              _buildAmountInput(context, store),
              const SizedBox(height: 16),
            ],
            
            // 百分比快捷按钮
            _buildPercentageButtons(context, store),
            const SizedBox(height: 16),
            
            // 可用余额显示
            _buildAvailableBalance(context, store),
            const SizedBox(height: 16),
            
            // 提交订单按钮
            _buildSubmitButton(context, store),
            
            // 错误/成功消息
            if (store.errorMessage != null || store.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  store.errorMessage ?? store.successMessage ?? '',
                  style: TextStyle(
                    color: store.errorMessage != null
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeSideSelector(BuildContext context, SpotTradeStore store) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => store.setTradeSide(OrderSide.buy),
            style: ElevatedButton.styleFrom(
              backgroundColor: store.tradeSide == OrderSide.buy
                  ? Colors.green
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: store.tradeSide == OrderSide.buy
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('买入'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () => store.setTradeSide(OrderSide.sell),
            style: ElevatedButton.styleFrom(
              backgroundColor: store.tradeSide == OrderSide.sell
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: store.tradeSide == OrderSide.sell
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('卖出'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTypeSelector(BuildContext context, SpotTradeStore store) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setOrderType(OrderType.limit),
            style: OutlinedButton.styleFrom(
              backgroundColor: store.orderType == OrderType.limit
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('限价'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setOrderType(OrderType.market),
            style: OutlinedButton.styleFrom(
              backgroundColor: store.orderType == OrderType.market
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('市价'),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInput(BuildContext context, SpotTradeStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '价格',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: store.price)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: store.price.length),
            ),
          onChanged: (value) => store.setPrice(value),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '请输入价格',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
            ),
            suffixText: 'USDT',
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInput(BuildContext context, SpotTradeStore store) {
    final parts = store.selectedSymbol.split('/');
    final baseCurrency = parts.isNotEmpty ? parts[0] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数量',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: store.quantity)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: store.quantity.length),
            ),
          onChanged: (value) => store.setQuantity(value),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '请输入数量',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
            ),
            suffixText: baseCurrency,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(BuildContext context, SpotTradeStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '金额',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: store.amount)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: store.amount.length),
            ),
          onChanged: (value) => store.setAmount(value),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '请输入金额',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
            ),
            suffixText: 'USDT',
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageButtons(BuildContext context, SpotTradeStore store) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setQuantityByPercentage(0.25),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('25%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setQuantityByPercentage(0.5),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('50%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setQuantityByPercentage(0.75),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('75%'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => store.setQuantityByPercentage(1.0),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: const Text('100%'),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableBalance(BuildContext context, SpotTradeStore store) {
    return Observer(
      builder: (_) {
        if (store.isLoadingBalance) {
          return const SizedBox(
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (store.availableBalance == null) {
          return const SizedBox.shrink();
        }

        final parts = store.selectedSymbol.split('/');
        final currency = store.tradeSide == OrderSide.buy
            ? (parts.length > 1 ? parts[1] : '')
            : (parts.isNotEmpty ? parts[0] : '');

        return Text(
          '可用余额: ${store.availableBalance!.available.toStringAsFixed(2)} $currency',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, SpotTradeStore store) {
    return Observer(
      builder: (_) => ElevatedButton(
        onPressed: store.isSubmitting ? null : () => store.submitOrder(),
        style: ElevatedButton.styleFrom(
          backgroundColor: store.tradeSide == OrderSide.buy
              ? Colors.green
              : Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
          ),
        ),
        child: store.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                store.tradeSide == OrderSide.buy ? '买入' : '卖出',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

