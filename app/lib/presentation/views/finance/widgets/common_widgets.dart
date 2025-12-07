import 'package:flutter/material.dart';
import '../constants/finance_constants.dart';
import '../models/finance_product.dart';

/// 通用AppBar
class FinanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const FinanceAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: FinanceConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: FinanceConstants.titleStyle,
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 通用TabBar
class FinanceTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const FinanceTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FinanceConstants.backgroundColor,
      child: TabBar(
        controller: controller,
        labelColor: FinanceConstants.textPrimary,
        unselectedLabelColor: FinanceConstants.textSecondary,
        indicatorColor: FinanceConstants.primaryColorDark,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: FinanceConstants.fontSizeRegular,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: FinanceConstants.fontSizeRegular,
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

/// 产品图标
class ProductIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const ProductIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.55,
        color: color,
      ),
    );
  }
}

/// 申购按钮
class SubscribeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double? width;

  const SubscribeButton({
    super.key,
    this.onPressed,
    this.text = '申购',
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: FinanceConstants.paddingMedium + 4,
        vertical: FinanceConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: FinanceConstants.primaryColor,
        borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusSmall),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: FinanceConstants.fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 产品卡片
class ProductCard extends StatelessWidget {
  final FinanceProduct product;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FinanceConstants.paddingMedium),
        decoration: BoxDecoration(
          color: FinanceConstants.backgroundColor,
          borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusMedium),
          border: Border.all(color: FinanceConstants.borderColor),
        ),
        child: Row(
          children: [
            ProductIcon(
              icon: product.icon,
              color: product.iconColor,
            ),
            const SizedBox(width: FinanceConstants.paddingSmall + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: FinanceConstants.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (product.protocol != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.protocol!,
                      style: FinanceConstants.secondaryStyle(null),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// 产品列表项（带收益率）
class ProductListItem extends StatelessWidget {
  final FinanceProduct product;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      product: product,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            product.rate,
            style: FinanceConstants.rateStyle(null),
          ),
          const SizedBox(width: FinanceConstants.paddingMedium),
          SubscribeButton(onPressed: onTap),
        ],
      ),
    );
  }
}

/// 推荐产品卡片
class RecommendedProductCard extends StatelessWidget {
  final FinanceProduct product;
  final VoidCallback? onTap;

  const RecommendedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(FinanceConstants.paddingMedium),
        decoration: BoxDecoration(
          color: FinanceConstants.backgroundColor,
          borderRadius: BorderRadius.circular(FinanceConstants.borderRadiusMedium),
          border: Border.all(color: FinanceConstants.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProductIcon(
                  icon: product.icon,
                  color: product.iconColor,
                  size: 28,
                ),
                const SizedBox(width: FinanceConstants.paddingSmall),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: FinanceConstants.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.rate,
                  style: const TextStyle(
                    fontSize: FinanceConstants.fontSizeHeading,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.rateLabel ?? '年化收益率',
                  style: FinanceConstants.secondaryStyle(null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 分组标题
class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: FinanceConstants.titleStyle),
              const SizedBox(height: 4),
              Text(subtitle, style: FinanceConstants.secondaryStyle(null)),
            ],
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: FinanceConstants.iconSizeMedium - 4,
              color: FinanceConstants.textTertiary,
            ),
        ],
      ),
    );
  }
}
