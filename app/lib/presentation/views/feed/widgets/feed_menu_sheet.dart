import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/common/action_bottom_sheet.dart';
import 'feed_report_page.dart';

class FeedMenuSheet extends StatelessWidget {
  final String? username;
  final String? topic;
  final int? targetId;
  final int targetType;

  const FeedMenuSheet({
    super.key,
    this.username,
    this.topic,
    this.targetId,
    this.targetType = 1,
  });

  static void show(
    BuildContext context, {
    String? username,
    String? topic,
    int? targetId,
    int targetType = 1, // 1=帖子 2=文章 3=评论
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext modalContext) {
        return FeedMenuSheet(
          username: username,
          topic: topic,
          targetId: targetId,
          targetType: targetType,
        );
      },
    ).then((result) {
      // 如果返回值是 'report'，导航到举报页面
      if (result == 'report' && targetId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FeedReportPage(
              targetType: targetType,
              targetId: targetId,
            ),
          ),
        );
      }
    });
  }

  List<ActionSheetSection> _buildSections() {
    return [
      ActionSheetSection(
        title: '不感兴趣',
        items: [
          ActionSheetItem(
            icon: Icons.sentiment_dissatisfied_outlined,
            text: '对这篇文章不感兴趣',
            onTap: () {},
          ),
          if (username != null)
            ActionSheetItem(
              icon: Icons.person_off_outlined,
              text: '对 @$username 不感兴趣',
              onTap: () {},
            ),
          if (topic != null)
            ActionSheetItem(
              icon: Icons.label_off_outlined,
              text: '对 $topic 不感兴趣',
              onTap: () {},
            ),
        ],
      ),
      ActionSheetSection(
        title: '内容质量差',
        items: [
          ActionSheetItem(
            icon: Icons.description_outlined,
            text: '对投资没有帮助',
            onTap: () {},
          ),
          ActionSheetItem(
            icon: Icons.thumb_down_outlined,
            text: '内容质量差',
            onTap: () {},
          ),
        ],
      ),
      ActionSheetSection(
        showDivider: false,
        items: [
          ActionSheetItem.danger(
            icon: Icons.warning_outlined,
            text: '举报',
            value: 'report',
            closeOnTap: true,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(),
            if (sections.isNotEmpty)
              ...sections.map((section) => _buildSection(context, section)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSection(BuildContext context, ActionSheetSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              section.title!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        ...section.items.map((item) => _buildMenuItem(context, item)),
        if (section.showDivider)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, ActionSheetItem item) {
    return InkWell(
      onTap: () {
        if (item.closeOnTap) {
          Navigator.pop(context, item.value);
        }
        item.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 24,
                color: item.iconColor ?? Colors.grey.shade700,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 16,
                  color: item.textColor ?? Colors.black87,
                  fontWeight: item.fontWeight,
                ),
              ),
            ),
            if (item.trailing != null) item.trailing!,
          ],
        ),
      ),
    );
  }
}
