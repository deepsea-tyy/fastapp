import 'package:flutter/material.dart';
import 'package:fastapp/constants/country_data.dart';

/// 国家/地区选择器（用于电话号码）
///
/// 显示国旗和电话区号，用于登录/注册等需要选择电话区号的场景
class CountrySelector extends StatefulWidget {
  final String selectedCode;
  final String selectedFlag;
  final Function(String code, String flag) onChanged;

  const CountrySelector({
    Key? key,
    required this.selectedCode,
    required this.selectedFlag,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CountrySelectorState createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  '选择国家/地区',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              // 常用国家
              if (Countries.popular.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '常用',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                ...Countries.popular.map((country) => _buildCountryItem(country)),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '全部国家/地区',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // 所有国家列表
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: Countries.all.length,
                  itemBuilder: (context, index) {
                    return _buildCountryItem(Countries.all[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryItem(CountryData country) {
    final isSelected = widget.selectedCode == country.phoneCode;

    return ListTile(
      leading: Text(
        country.flag,
        style: const TextStyle(fontSize: 24.0),
      ),
      title: Text(
        country.nameCn,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            country.phoneCode,
            style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ],
        ],
      ),
      onTap: () {
        widget.onChanged(country.phoneCode, country.flag);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCountryCodePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.selectedFlag, style: const TextStyle(fontSize: 20.0)),
            const SizedBox(width: 4.0),
            Text(
              widget.selectedCode,
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
            ),
            const SizedBox(width: 4.0),
            const Icon(Icons.arrow_drop_down, size: 20.0, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

