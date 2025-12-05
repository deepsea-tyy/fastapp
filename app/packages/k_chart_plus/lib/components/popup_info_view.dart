import 'package:flutter/material.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/chart_translations.dart';
import '../entity/k_line_entity.dart';
import '../utils/date_format_util.dart';
import '../utils/number_util.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1.0;
    
    const dashWidth = 4.0;
    const dashSpace = 2.0;
    double startX = 0;
    
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PopupInfoView extends StatelessWidget {
  final KLineEntity entity;
  final double width;
  final ChartColors chartColors;
  final ChartTranslations chartTranslations;
  final bool materialInfoDialog;
  final List<String> timeFormat;
  final int fixedLength;

  const PopupInfoView({
    Key? key,
    required this.entity,
    required this.width,
    required this.chartColors,
    required this.chartTranslations,
    required this.materialInfoDialog,
    required this.timeFormat,
    required this.fixedLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    double upDown = entity.change ?? entity.close - entity.open;
    double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
    final double? entityAmount = entity.amount;
    final amplitude = ((entity.high - entity.low) / entity.open) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildItem(chartTranslations.date, getDate(entity.time)),
        _buildDivider(),
        _buildItem(chartTranslations.open, _formatPrice(entity.open)),
        _buildItem(chartTranslations.high, _formatPrice(entity.high)),
        _buildItem(chartTranslations.low, _formatPrice(entity.low)),
        _buildItem(chartTranslations.close, _formatPrice(entity.close)),
        _buildChangeItem(upDown, upDownPercent),
        _buildItem(chartTranslations.amplitude, '${amplitude.toStringAsFixed(2)}%'),
        _buildItem(chartTranslations.vol, NumberUtil.format(entity.vol)),
        if (entityAmount != null)
          _buildItem(chartTranslations.amount, _formatAmount(entityAmount)),
      ],
    );
  }
  
  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(fixedLength).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    String formatted = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted += ',';
      }
      formatted += integerPart[i];
    }
    
    return decimalPart.isNotEmpty ? '$formatted.$decimalPart' : formatted;
  }
  
  String _formatAmount(double amount) {
    if (amount >= 10000) {
      final wan = amount / 10000;
      return '${wan.toStringAsFixed(2)}万';
    }
    return amount.toStringAsFixed(2);
  }
  
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      height: 1.0,
      child: CustomPaint(
        painter: DashedLinePainter(),
      ),
    );
  }
  
  Widget _buildChangeItem(double upDown, double upDownPercent) {
    final isUp = upDown > 0;
    final changeText = '${isUp ? '+' : ''}${upDown.toStringAsFixed(fixedLength)}(${isUp ? '+' : ''}${upDownPercent.toStringAsFixed(2)}%)';
    return _buildItem(chartTranslations.changeAmount, changeText, 
        textColor: isUp ? chartColors.infoWindowUpColor : chartColors.infoWindowDnColor);
  }

  Widget _buildItem(String label, String info, {Color? textColor}) {
    final infoWidget = Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF4D4D4E),
              fontSize: 10.0,
            ),
          ),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                color: textColor ?? const Color(0xFF222223),
                fontSize: 10.0,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
    return materialInfoDialog
        ? Material(color: Colors.transparent, child: infoWidget)
        : infoWidget;
  }

  String getDate(int? date) => dateFormat(
        DateTime.fromMillisecondsSinceEpoch(
            date ?? DateTime.now().millisecondsSinceEpoch),
        timeFormat,
      );
}
