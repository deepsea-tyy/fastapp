import 'package:flutter/material.dart';

class CountryCode {
  final String flag;
  final String code;
  final String name;

  const CountryCode({
    required this.flag,
    required this.code,
    required this.name,
  });
}

class CountryCodeSelector extends StatefulWidget {
  final String selectedCode;
  final String selectedFlag;
  final Function(String code, String flag) onChanged;

  const CountryCodeSelector({
    Key? key,
    required this.selectedCode,
    required this.selectedFlag,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CountryCodeSelectorState createState() => _CountryCodeSelectorState();
}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  static const List<CountryCode> _countryCodes = [
    CountryCode(flag: '🇨🇳', code: '+86', name: '中国'),
    CountryCode(flag: '🇺🇸', code: '+1', name: '美国'),
    CountryCode(flag: '🇬🇧', code: '+44', name: '英国'),
    CountryCode(flag: '🇯🇵', code: '+81', name: '日本'),
    CountryCode(flag: '🇰🇷', code: '+82', name: '韩国'),
  ];

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300.0,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '选择国家/地区',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: _countryCodes.map((country) {
                  return _buildCountryCodeItem(country);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryCodeItem(CountryCode country) {
    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 24.0)),
      title: Text(country.name),
      trailing: Text(country.code),
      onTap: () {
        widget.onChanged(country.code, country.flag);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
