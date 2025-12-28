import 'package:fastapp/presentation/views/c2c/c2c_screen.dart';
import 'package:fastapp/utils/wallet_navigator.dart';
import 'package:flutter/material.dart';

/// 操作按钮组件
class ActionButtons extends StatelessWidget {
  final String primaryButtonText;
  final String secondaryButtonText;
  final String tertiaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onTertiaryPressed;

  const ActionButtons({
    super.key,
    this.primaryButtonText = '转入',
    this.secondaryButtonText = '转出',
    this.tertiaryButtonText = '划转',
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.onTertiaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimaryPressed ?? () {
                _showDepositMethodBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                primaryButtonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onSecondaryPressed ?? () {
                _showWithdrawalMethodBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                secondaryButtonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: onTertiaryPressed ?? () => WalletNavigator.toTransfer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                tertiaryButtonText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: const Text(
                '选择充值方式',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 选项列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildWithdrawalOption(
                    context,
                    icon: Icons.download,
                    title: '链上充值',
                    description: '将其他交易平台/钱包中的加密货币存入账户',
                    onTap: () {
                      Navigator.of(context).pop();
                      WalletNavigator.toCurrencyListForDeposit(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildWithdrawalOption(
                    context,
                    icon: Icons.people_outline,
                    title: 'C2C 交易',
                    description: '点对点交易,价格从优,支持多种本地支付方式',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const C2CScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: const Text(
                '选择提现方式',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // 选项列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildWithdrawalOption(
                    context,
                    icon: Icons.person_add_outlined,
                    title: '转账给用户',
                    description: '站内转账,通过邮箱/手机号/ID 发送',
                    onTap: () {
                      Navigator.of(context).pop();
                      WalletNavigator.toTransferToUser(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildWithdrawalOption(
                    context,
                    icon: Icons.upload_outlined,
                    title: '链上提现',
                    description: '将加密货币提现到其他交易平台/钱包',
                    onTap: () {
                      Navigator.of(context).pop();
                      WalletNavigator.toCurrencySelectForWithdraw(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildWithdrawalOption(
                    context,
                    icon: Icons.people_outline,
                    title: 'C2C 交易',
                    description: '点对点交易,价格从优,支持多种本地支付方式。',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const C2CScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // 底部安全区域
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
