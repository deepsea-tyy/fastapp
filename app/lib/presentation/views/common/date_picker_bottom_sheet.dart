import 'package:flutter/material.dart';

/// 日期选择底部弹框
class DatePickerBottomSheet extends StatefulWidget {
  final String title;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerBottomSheet({
    super.key,
    required this.title,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();

  /// 显示日期选择弹框
  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerBottomSheet(
        title: title,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late int _minYear;
  late int _maxYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initial = widget.initialDate ?? now;

    _selectedYear = initial.year;
    _selectedMonth = initial.month;
    _selectedDay = initial.day;

    _minYear = widget.firstDate?.year ?? 1900;
    _maxYear = widget.lastDate?.year ?? now.year;
  }

  /// 获取当前选中年月的天数
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 获取年份列表
  List<int> get _years {
    return List.generate(_maxYear - _minYear + 1, (index) => _minYear + index);
  }

  /// 获取月份列表
  List<int> get _months {
    return List.generate(12, (index) => index + 1);
  }

  /// 获取日期列表
  List<int> get _days {
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    return List.generate(daysInMonth, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          _buildDragHandle(),
          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          // 日期选择器
          Container(
            height: 250,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // 年份选择
                Expanded(
                  child: _buildPicker(
                    items: _years,
                    selectedValue: _selectedYear,
                    suffix: '年',
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        // 确保日期有效
                        final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
                        if (_selectedDay > daysInMonth) {
                          _selectedDay = daysInMonth;
                        }
                      });
                    },
                  ),
                ),
                // 月份选择
                Expanded(
                  child: _buildPicker(
                    items: _months,
                    selectedValue: _selectedMonth,
                    suffix: '月',
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                        // 确保日期有效
                        final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
                        if (_selectedDay > daysInMonth) {
                          _selectedDay = daysInMonth;
                        }
                      });
                    },
                  ),
                ),
                // 日期选择
                Expanded(
                  child: _buildPicker(
                    items: _days,
                    selectedValue: _selectedDay,
                    suffix: '日',
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
                      Navigator.of(context).pop(selectedDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade200,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// 构建滚动选择器
  Widget _buildPicker({
    required List<int> items,
    required int selectedValue,
    required String suffix,
    required Function(int) onChanged,
  }) {
    final controller = FixedExtentScrollController(
      initialItem: items.indexOf(selectedValue),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // 选中项背景
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // 滚动列表
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 40,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            onChanged(items[index]);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: items.length,
            builder: (context, index) {
              final value = items[index];
              final isSelected = value == selectedValue;
              return Center(
                child: Text(
                  '$value$suffix',
                  style: TextStyle(
                    fontSize: isSelected ? 18 : 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
