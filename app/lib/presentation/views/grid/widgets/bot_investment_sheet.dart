import 'package:flutter/material.dart';

/// 机器人投资金额底部弹窗
class BotInvestmentSheet extends StatefulWidget {
  final String botPair;
  final String botType; // 现货网格、合约网格
  final Map<String, dynamic> botDetails;

  const BotInvestmentSheet({
    super.key,
    required this.botPair,
    required this.botType,
    required this.botDetails,
  });

  static Future<void> show(
    BuildContext context, {
    required String botPair,
    required String botType,
    required Map<String, dynamic> botDetails,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BotInvestmentSheet(
        botPair: botPair,
        botType: botType,
        botDetails: botDetails,
      ),
    );
  }

  @override
  State<BotInvestmentSheet> createState() => _BotInvestmentSheetState();
}

class _BotInvestmentSheetState extends State<BotInvestmentSheet> {
  bool _showDetails = true;
  double _investmentAmount = 89.84;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = '>=${_investmentAmount.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 自定义参数标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.botType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '自定义参数',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 内容区域
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 投入金额
                  _buildInvestmentSection(),
                  const SizedBox(height: 16),
                  // 详情
                  _buildDetailsSection(),
                  const SizedBox(height: 24),
                  // 创建按钮
                  _buildCreateButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentSection() {
    final isSpotGrid = widget.botType == '现货网格';
    
    if (isSpotGrid) {
      return _buildSpotInvestmentSection();
    } else {
      return _buildContractInvestmentSection();
    }
  }

  // 现货投资额区域
  Widget _buildSpotInvestmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投入金额',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _amountController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Text(
                'USDT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '可用',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Row(
              children: [
                Text(
                  '0.00 USDT',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 投资额滑块（占位）
        Container(
          height: 24,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: List.generate(
                    6,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 合约投资额区域
  Widget _buildContractInvestmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '投入金额',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        // 带边框的输入框
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF6B6B),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '1',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: 选择杠杆
                },
                child: Row(
                  children: [
                    const Text(
                      '10x',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 红色提示
        Text(
          'ETH 余额不足。运行 ETH 网格策略的最小投资额为 0.0159。',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(height: 12),
        // 可用余额
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '可用',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            Row(
              children: [
                Text(
                  '0.0000 ETH',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.swap_horiz,
                  size: 18,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 投资额滑块（占位）
        Container(
          height: 24,
          child: Stack(
            children: [
              Positioned.fill(
                child: Row(
                  children: List.generate(
                    6,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 每笔数量
        _buildInfoRow('每笔数量', '62 张'),
        const SizedBox(height: 12),
        // 总投资额
        _buildInfoRow('总投资额', '10.0000 ETH'),
        const SizedBox(height: 12),
        // 保证金模式
        _buildInfoRow('保证金模式', '全仓'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    // 根据机器人类型显示不同的详情
    final isSpotGrid = widget.botType == '现货网格';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 详情标题
          InkWell(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '详情',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          // 详情内容
          if (_showDetails) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: isSpotGrid 
                    ? _buildSpotDetails() 
                    : _buildContractDetails(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 现货网格详情
  List<Widget> _buildSpotDetails() {
    return [
      _buildDetailRow('建议运行时长', widget.botDetails['suggestedDuration'] ?? '3-7 天'),
      const SizedBox(height: 12),
      _buildDetailRow('价格区间 (USDT)', widget.botDetails['priceRange'] ?? '89469.89 - 94791.21'),
      const SizedBox(height: 12),
      _buildDetailRow('网格数量', widget.botDetails['gridCount']?.toString() ?? '14'),
      const SizedBox(height: 12),
      _buildDetailRow('模式', widget.botDetails['mode'] ?? '等差网格'),
      const SizedBox(height: 12),
      _buildDetailRow('每格利润（已扣除费用）', widget.botDetails['profitPerGrid'] ?? '0.20% - 0.22%'),
      const SizedBox(height: 12),
      _buildDetailRow('终止时出售全部 BTC', widget.botDetails['sellAllOnStop'] ?? '已启用'),
    ];
  }

  // 合约网格详情
  List<Widget> _buildContractDetails() {
    return [
      _buildDetailRow('建议运行时长', widget.botDetails['suggestedDuration'] ?? '7-30 天'),
      const SizedBox(height: 12),
      _buildDetailRow('方向', widget.botDetails['direction'] ?? '中性'),
      const SizedBox(height: 12),
      _buildDetailRow('价格区间 (USD)', widget.botDetails['priceRange'] ?? '2798.89 - 3522.54'),
      const SizedBox(height: 12),
      _buildDetailRow('网格数量', widget.botDetails['gridCount']?.toString() ?? '39'),
      const SizedBox(height: 12),
      _buildDetailRow('模式', widget.botDetails['mode'] ?? '等差网格'),
      const SizedBox(height: 12),
      _buildDetailRow('每格利润（已扣除费用）', widget.botDetails['profitPerGrid'] ?? '0.48% - 0.62%'),
      const SizedBox(height: 12),
      _buildDetailRow('终止时全部平仓', widget.botDetails['closeAllOnStop'] ?? '已启用'),
    ];
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 创建机器人
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade400,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          '创建',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
