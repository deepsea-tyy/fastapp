import 'package:flutter/material.dart';
import 'package:fastapp/presentation/views/common/pagination_controller.dart';

/// 活动数据模型
class ActivityData {
  final String brand;
  final String title;
  final String subtitle;
  final String? buttonText;
  final String label;
  final bool showGradientIcon;

  ActivityData({
    required this.brand,
    required this.title,
    required this.subtitle,
    this.buttonText,
    required this.label,
    this.showGradientIcon = false,
  });
}

/// 活动列表页面
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final PaginationController<ActivityData> _paginationController;
  
  @override
  void initState() {
    super.initState();
    _paginationController = PaginationController<ActivityData>(
      pageSize: 20,
      onStateChanged: () => setState(() {}),
      isMounted: () => mounted,
      loadDataCallback: _loadData,
    );
    _paginationController.init();
    _paginationController.loadMore();
  }

  @override
  void dispose() {
    _paginationController.dispose();
    super.dispose();
  }

  Future<List<ActivityData>> _loadData(int page, int pageSize) async {
    // TODO: 替换为真实的 API 调用
    // 示例：模拟 API 延迟和数据返回
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟数据：第一页返回20条，后续页面返回少于20条表示没有更多数据
    if (page == 1) {
      return List.generate(pageSize, (index) {
        return ActivityData(
          brand: 'ZEX合约',
          title: '交易合约赢奖励 ${index + 1}',
          subtitle: '完成任务,瓜分540,000 XPL + 380,000 NXPC奖励!',
          buttonText: index % 2 == 0 ? '立即参与' : null,
          label: '交易合约赢奖励',
          showGradientIcon: index % 2 == 0,
        );
      });
    } else {
      // 模拟没有更多数据
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('活动'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _paginationController.dataList.isEmpty && !_paginationController.isLoading
          ? const Center(
              child: Text('暂无活动'),
            )
          : RefreshIndicator(
              onRefresh: () => _paginationController.refresh(),
              child: ListView.builder(
                controller: _paginationController.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _paginationController.dataList.length + 1,
                itemBuilder: (context, index) {
                  if (index == _paginationController.dataList.length) {
                    return _paginationController.buildLoadMoreIndicator();
                  }
                  final activity = _paginationController.dataList[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < _paginationController.dataList.length - 1 ? 16 : 0),
                    child: _buildActivityCard(
                      brand: activity.brand,
                      title: activity.title,
                      subtitle: activity.subtitle,
                      buttonText: activity.buttonText,
                      label: activity.label,
                      showGradientIcon: activity.showGradientIcon,
                      onTap: () {
                        // TODO: 跳转到活动详情
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildActivityCard({
    required String brand,
    required String title,
    required String subtitle,
    String? buttonText,
    required String label,
    required VoidCallback onTap,
    bool showGradientIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandHeader(brand),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildContent(title, subtitle),
                    ),
                    const SizedBox(width: 16),
                    _buildRightIcon(showGradientIcon),
                  ],
                ),
                if (buttonText != null) ...[
                  const SizedBox(height: 20),
                  _buildActionButton(buttonText),
                ],
                const SizedBox(height: 12),
                _buildDisclaimer(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(String brand) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.diamond,
            size: 10,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          brand,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRightIcon(bool showGradientIcon) {
    if (showGradientIcon) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'N',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBar(20, Colors.green.shade400),
          const SizedBox(height: 4),
          _buildBar(15, Colors.red.shade400),
          const SizedBox(height: 4),
          _buildBar(18, Colors.green.shade400),
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 30,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 参与活动
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      '数字资产价格波动剧烈，投资数字资产存在较大风险，请谨慎投资。',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade400,
        height: 1.4,
      ),
    );
  }
}
