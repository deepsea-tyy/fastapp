import 'package:fastapp/presentation/views/spot/widgets/common/constants.dart';
import 'package:fastapp/presentation/views/spot/widgets/common/utils.dart';
import 'package:flutter/material.dart';

/// 持仓模式（资产模式）选择弹窗
class PositionModeBottomSheet extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onModeChanged;

  const PositionModeBottomSheet({
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
                  '资产模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 单币种保证金模式
            _buildPositionModeOption(
              context,
              '单币种保证金模式',
              [
                '仅支持使用合约的保证金资产交易U本位合约。',
                '保证金资产相同的全仓仓位间盈亏互相抵消。',
                '支持全仓和逐仓。',
              ],
              currentMode == positionModeSingle,
              Icons.account_balance_wallet,
              () {
                onModeChanged(positionModeSingle);
                Navigator.pop(context);
              },
            ),

            // 联合保证金模式
            _buildPositionModeOption(
              context,
              '联合保证金模式',
              [
                '可跨保证金资产交易U本位合约。',
                '不同保证金资产全仓仓位间盈亏互相抵消。',
                '目前仅支持全仓。',
              ],
              currentMode == positionModeUnified,
              Icons.layers,
              () {
                onModeChanged(positionModeUnified);
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionModeOption(
    BuildContext context,
    String title,
    List<String> descriptions,
    bool isSelected,
    IconData icon,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标区域
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.teal,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 文字内容
            Expanded(
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
                  ...descriptions.map((desc) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '· ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
