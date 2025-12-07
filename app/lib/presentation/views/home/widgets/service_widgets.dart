import 'package:flutter/material.dart';
import '../constants/service_constants.dart';
import '../models/service_item.dart';

/// 服务页面AppBar
class ServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ServiceAppBar({
    super.key,
    this.title = '服务',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ServiceConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 搜索栏
class ServiceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const ServiceSearchBar({
    super.key,
    required this.controller,
    this.hintText = '搜索更多服务',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ServiceConstants.paddingLarge,
        vertical: ServiceConstants.paddingMedium,
      ),
      child: Container(
        height: ServiceConstants.searchBarHeight,
        decoration: BoxDecoration(
          color: ServiceConstants.searchBarColor,
          borderRadius: BorderRadius.circular(ServiceConstants.searchBorderRadius),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: ServiceConstants.hintTextStyle,
            prefixIcon: const Icon(
              Icons.search,
              color: ServiceConstants.hintColor,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ServiceConstants.paddingMedium,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }
}

/// 服务Tab栏
class ServiceTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const ServiceTabBar({
    super.key,
    required this.controller,
    this.tabs = ServiceConstants.tabLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ServiceConstants.backgroundColor,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        labelColor: ServiceConstants.primaryColor,
        unselectedLabelColor: ServiceConstants.textPrimary,
        indicatorColor: ServiceConstants.primaryColor,
        indicatorWeight: 2,
        labelStyle: const TextStyle(
          fontSize: ServiceConstants.fontSizeMedium,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: ServiceConstants.fontSizeMedium,
        ),
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }
}

/// 服务网格布局
class ServiceGrid extends StatelessWidget {
  final List<ServiceItem> services;
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
      itemBuilder: (context, index) {
        return ServiceGridItem(item: services[index]);
      },
    );
  }
}

/// 服务网格项
class ServiceGridItem extends StatelessWidget {
  final ServiceItem item;

  const ServiceGridItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.onTap != null) {
          item.onTap!(context);
        }
      },
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
  final List<ServiceItem> services;
  final bool boldTitle;

  const ServiceSection({
    this.title,
    required this.services,
    this.boldTitle = false,
  });
}

/// 空状态页面
class EmptyServiceTab extends StatelessWidget {
  final String message;

  const EmptyServiceTab({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: ServiceConstants.emptyStateStyle,
      ),
    );
  }
}
