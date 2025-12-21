import 'package:flutter/material.dart';
import 'service_constants.dart';
import 'service_item_model.dart';

/// 服务网格布局
class ServiceGrid extends StatelessWidget {
  final List<AppServiceItem> services;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const ServiceGrid({
    super.key,
    required this.services,
    this.crossAxisCount = ServiceConstants.gridCrossAxisCount,
    this.crossAxisSpacing = ServiceConstants.gridSpacing,
    this.mainAxisSpacing = ServiceConstants.gridSpacing,
    this.childAspectRatio = ServiceConstants.gridAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) => ServiceGridItem(item: services[index]),
    );
  }
}

/// 服务网格项
class ServiceGridItem extends StatelessWidget {
  final AppServiceItem item;

  const ServiceGridItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => item.onTap?.call(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ServiceConstants.iconContainerSize,
            height: ServiceConstants.iconContainerSize,
            decoration: BoxDecoration(
              color: item.backgroundColor ?? ServiceConstants.iconBackgroundColor,
              borderRadius: BorderRadius.circular(ServiceConstants.iconBorderRadius),
            ),
            child: Icon(
              item.icon,
              size: ServiceConstants.iconSize,
              color: item.iconColor ?? ServiceConstants.textPrimary,
            ),
          ),
          const SizedBox(height: ServiceConstants.paddingSmall),
          Text(
            item.label,
            style: ServiceConstants.itemLabelStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 分组标题
class ServiceSectionTitle extends StatelessWidget {
  final String title;
  final bool bold;

  const ServiceSectionTitle({
    super.key,
    required this.title,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: bold
          ? ServiceConstants.sectionTitleBoldStyle
          : ServiceConstants.sectionTitleStyle,
    );
  }
}

/// 服务Tab页面通用布局
class ServiceTabView extends StatelessWidget {
  final List<ServiceSection> sections;
  final EdgeInsets padding;

  const ServiceTabView({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.all(ServiceConstants.paddingLarge),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (section.title != null) ...[
                ServiceSectionTitle(
                  title: section.title!,
                  bold: section.boldTitle,
                ),
                const SizedBox(height: ServiceConstants.paddingMedium),
              ],
              ServiceGrid(services: section.services),
              if (section != sections.last)
                const SizedBox(height: ServiceConstants.paddingXLarge),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// 服务分组数据类
class ServiceSection {
  final String? title;
  final List<AppServiceItem> services;
  final bool boldTitle;

  const ServiceSection({
    this.title,
    required this.services,
    this.boldTitle = false,
  });
}


