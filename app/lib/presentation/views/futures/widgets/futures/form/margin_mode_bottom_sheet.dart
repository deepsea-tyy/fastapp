import 'package:fastapp/presentation/views/futures/widgets/futures/form/constants.dart';
import 'package:fastapp/presentation/views/futures/widgets/futures/form/utils.dart';
import 'package:flutter/material.dart';

/// 保证金模式选择弹窗
class MarginModeBottomSheet extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;

  const MarginModeBottomSheet({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildDragHandle(),
            
            // 标题
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '保证金模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 全仓选项
            _buildMarginModeOption(
              context,
              marginModeCross,
              '保证金资产相同的全仓仓位共享该资产的全仓保证金。在强平事件中，交易者可能会损失全部该保证金和该保证金资产下的所有全仓仓位。',
              currentMode == marginModeCross,
              () {
                onModeChanged(marginModeCross);
                Navigator.pop(context);
              },
            ),

            // 逐仓选项
            _buildMarginModeOption(
              context,
              marginModeIsolated,
              '一定数量保证金被分配到仓位上。如果仓位保证金亏损到低于维持保证金的水平，仓位将被强平。在逐仓模式下，您可以为这个仓位添加和减少保证金。',
              currentMode == marginModeIsolated,
              () {
                onModeChanged(marginModeIsolated);
                Navigator.pop(context);
              },
            ),

            // 底部提示
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                '* 调整保证金模式仅对当前合约生效。',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginModeOption(
    BuildContext context,
    String title,
    String description,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
