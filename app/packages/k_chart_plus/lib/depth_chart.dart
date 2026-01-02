import 'dart:math';
import 'package:flutter/material.dart';
import 'package:k_chart_plus/chart_translations.dart';
import 'package:k_chart_plus/k_chart_plus.dart';

class DepthChart extends StatefulWidget {
  final List<DepthEntity> bids, asks;
  final int baseUnit;
  final int quoteUnit;
  final Offset offset;
  final ChartColors chartColors;
  final DepthChartTranslations chartTranslations;

  DepthChart(
    this.bids,
    this.asks,
    this.chartColors, {
    this.baseUnit = 2,
    this.quoteUnit = 6,
    this.offset = const Offset(10, 10),
    this.chartTranslations = const DepthChartTranslations(),
  });

  @override
  _DepthChartState createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  Offset? pressOffset;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressMoveUpdate: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressEnd: (details) {
        pressOffset = null;
        isLongPress = false;
        setState(() {});
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: DepthChartPainter(
          widget.bids,
          widget.asks,
          pressOffset,
          isLongPress,
          widget.baseUnit,
          widget.quoteUnit,
          widget.chartColors,
          widget.offset,
          widget.chartTranslations,
        ),
      ),
    );
  }
}

class DepthChartPainter extends CustomPainter {
  final List<DepthEntity>? mBuyData;
  final List<DepthEntity>? mSellData;
  final Offset? pressOffset;
  final bool isLongPress;
  final int baseUnit;
  final int quoteUnit;
  final ChartColors chartColors;
  final Offset offset;
  final DepthChartTranslations chartTranslations;

  double mPaddingBottom = 32.0;
  double mWidth = 0.0;
  double mDrawHeight = 0.0;
  double mDrawWidth = 0.0;
  double? mBuyPointWidth;
  double? mSellPointWidth;

  /// 最大委托量
  double? mMaxVolume;
  double? mMultiple;

  /// 右侧绘制个数
  static const int mLineCount = 4;

  Path? mBuyPath;
  Path? mSellPath;

  Paint? mBuyLinePaint;
  Paint? mSellLinePaint;
  Paint? mBuyPathPaint;
  Paint? mSellPathPaint;
  Paint? selectPaint;
  Paint? selectBorderPaint;

  DepthChartPainter(
    this.mBuyData,
    this.mSellData,
    this.pressOffset,
    this.isLongPress,
    this.baseUnit,
    this.quoteUnit,
    this.chartColors,
    this.offset,
    this.chartTranslations,
  ) {
    _initPaints();
    mBuyPath ??= Path();
    mSellPath ??= Path();
    init();
  }
  
  void _initPaints() {
    mBuyLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = chartColors.depthBuyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    mSellLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = chartColors.depthSellColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    mBuyPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = chartColors.depthBuyPathColor;
    
    mSellPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = chartColors.depthSellPathColor;
  }

  void init() {
    if (mBuyData == null ||
        mBuyData!.isEmpty ||
        mSellData == null ||
        mSellData!.isEmpty) {
      return;
    }

    // 计算最大成交量（累计数量）
    // 买单：累计数量递增，最后一个最大
    // 卖单：累计数量递增，最后一个最大
    final maxBuyVol = mBuyData!.last.vol;
    final maxSellVol = mSellData!.last.vol;
    mMaxVolume = max(maxBuyVol, maxSellVol) * 1.05;
    mMultiple = mMaxVolume! / mLineCount;

    // 初始化选择画笔
    selectPaint = Paint()
      ..isAntiAlias = true
      ..color = chartColors.selectFillColor;

    selectBorderPaint = Paint()
      ..isAntiAlias = true
      ..color = chartColors.selectBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mBuyData == null ||
        mSellData == null ||
        mBuyData!.isEmpty ||
        mSellData!.isEmpty) {
      return;
    }
    
    mWidth = size.width;
    mDrawWidth = mWidth / 2;
    mDrawHeight = size.height - mPaddingBottom;
    
    canvas.save();
    drawBuy(canvas);
    drawSell(canvas);
    drawText(canvas);
    canvas.restore();
  }

  void drawBuy(Canvas canvas) {
    final dataLength = mBuyData!.length;
    mBuyPointWidth = mDrawWidth / (dataLength > 1 ? dataLength - 1 : 1);
    mBuyPath!.reset();
    
    for (int i = 0; i < dataLength; i++) {
      final x = mBuyPointWidth! * i;
      final y = getY(mBuyData![i].vol);
      
      if (i == 0) {
        mBuyPath!.moveTo(0, y);
      } else {
        // 绘制线条
        canvas.drawLine(
          Offset(mBuyPointWidth! * (i - 1), getY(mBuyData![i - 1].vol)),
          Offset(x, y),
          mBuyLinePaint!,
        );
      }
      
      // 构建路径
      if (i < dataLength - 1) {
        mBuyPath!.quadraticBezierTo(
          x,
          y,
          mBuyPointWidth! * (i + 1),
          getY(mBuyData![i + 1].vol),
        );
      } else {
        // 最后一个点，闭合路径
        if (dataLength == 1) {
          mBuyPath!.lineTo(mDrawWidth, y);
        } else {
          mBuyPath!.quadraticBezierTo(x, y, x, mDrawHeight);
        }
        mBuyPath!.lineTo(mDrawWidth, mDrawHeight);
        mBuyPath!.lineTo(0, mDrawHeight);
        mBuyPath!.close();
      }
    }
    canvas.drawPath(mBuyPath!, mBuyPathPaint!);
  }

  void drawSell(Canvas canvas) {
    final dataLength = mSellData!.length;
    mSellPointWidth = mDrawWidth / (dataLength > 1 ? dataLength - 1 : 1);
    mSellPath!.reset();

    // 从中间线开始绘制卖单（从左到右，即从中间到右侧）
    for (int i = 0; i < dataLength; i++) {
      final x = (mSellPointWidth! * i) + mDrawWidth;
      final y = getY(mSellData![i].vol);

      if (i == 0) {
        // 第一个点，从中间线底部开始
        mSellPath!.moveTo(mDrawWidth, mDrawHeight);
        mSellPath!.lineTo(mDrawWidth, y);
        mSellPath!.lineTo(x, y);
      } else {
        // 绘制线条
        canvas.drawLine(
          Offset((mSellPointWidth! * (i - 1)) + mDrawWidth, getY(mSellData![i - 1].vol)),
          Offset(x, y),
          mSellLinePaint!,
        );
      }

      // 构建路径
      if (i < dataLength - 1) {
        final nextX = (mSellPointWidth! * (i + 1)) + mDrawWidth;
        final nextY = getY(mSellData![i + 1].vol);
        mSellPath!.quadraticBezierTo(
          x,
          y,
          nextX,
          nextY,
        );
      } else {
        // 最后一个点，闭合路径到右侧底部
        if (dataLength == 1) {
          mSellPath!.lineTo(mWidth, y);
        } else {
          mSellPath!.quadraticBezierTo(x, y, mWidth, y);
        }
        mSellPath!.lineTo(mWidth, mDrawHeight);
        mSellPath!.lineTo(mDrawWidth, mDrawHeight);
        mSellPath!.close();
      }
    }
    canvas.drawPath(mSellPath!, mSellPathPaint!);
  }

  void drawText(Canvas canvas) {
    // 绘制右侧成交量标签
    for (int j = 0; j < mLineCount; j++) {
      final value = mMaxVolume! - mMultiple! * j;
      final text = value.toStringAsFixed(baseUnit);
      final tp = getTextPainter(text);
      tp.layout();
      tp.paint(
        canvas,
        Offset(mWidth - tp.width, mDrawHeight / mLineCount * j + tp.height / 2),
      );
    }

    // 绘制底部价格标签
    final centerPrice = (mBuyData!.last.price + mSellData!.first.price) / 2;
    _drawPriceText(canvas, mBuyData!.first.price, 0, quoteUnit);
    _drawPriceText(canvas, centerPrice, mDrawWidth, quoteUnit);
    _drawPriceText(canvas, mSellData!.last.price, mWidth, quoteUnit);
    _drawPriceText(
      canvas,
      (mBuyData!.first.price + centerPrice) / 2,
      mDrawWidth / 2,
      quoteUnit,
    );
    _drawPriceText(
      canvas,
      (mSellData!.last.price + centerPrice) / 2,
      (mDrawWidth + mWidth) / 2,
      quoteUnit,
    );

    // 绘制长按选择视图
    if (isLongPress && pressOffset != null) {
      final isLeft = pressOffset!.dx <= mDrawWidth;
      final data = isLeft ? mBuyData! : mSellData!;
      final getX = isLeft ? getBuyX : getSellX;
      final index = _indexOfTranslateX(pressOffset!.dx, 0, data.length - 1, getX);
      drawSelectView(canvas, index, isLeft);
    }
  }
  
  void _drawPriceText(Canvas canvas, double price, double x, int quoteUnit) {
    final text = price.toStringAsFixed(quoteUnit);
    final tp = getTextPainter(text);
    tp.layout();
    final textX = x == 0 
        ? 0.0 
        : (x == mWidth 
            ? mWidth - tp.width 
            : x - tp.width / 2);
    tp.paint(canvas, Offset(textX, getBottomTextY(tp.height)));
  }

  void drawSelectView(Canvas canvas, int index, bool isLeft) {
    final entity = isLeft ? mBuyData![index] : mSellData![index];
    final dx = isLeft ? getBuyX(index) : getSellX(index);
    final dy = getY(entity.vol);
    const radius = 8.0;
    const innerRadius = radius / 3;

    // 绘制选择点
    final paint = (dx < mDrawWidth ? mBuyLinePaint : mSellLinePaint)!;
    canvas.drawCircle(Offset(dx, dy), innerRadius, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(dx, dy), radius, paint..style = PaintingStyle.stroke);

    // 绘制弹出信息
    final popupPainter = _PopupPainter(
      chartTranslations: chartTranslations,
      chartColors: chartColors,
      price: entity.price.toStringAsFixed(quoteUnit),
      amount: entity.vol.toStringAsFixed(baseUnit),
    );
    
    final popupDx = dx < mDrawWidth
        ? dx + offset.dx
        : dx - offset.dx - popupPainter.width;
    final popupDy = dy < mDrawHeight / 2
        ? dy + offset.dy
        : dy - offset.dy - popupPainter.height;
    
    final rect = Rect.fromLTWH(
      popupDx,
      popupDy,
      popupPainter.width,
      popupPainter.height,
    );
    final boxRect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));

    canvas.drawRRect(boxRect, selectPaint!);
    canvas.drawRRect(boxRect, selectBorderPaint!);
    popupPainter.paint(canvas, rect.topLeft);
  }

  ///Binary search for current value: index
  int _indexOfTranslateX(double translateX, int start, int end, Function getX) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid, getX);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end, getX);
    } else {
      return mid;
    }
  }

  double getBuyX(int position) => position * mBuyPointWidth!;

  double getSellX(int position) => position * mSellPointWidth! + mDrawWidth;

  getTextPainter(String text) => TextPainter(
        text: TextSpan(
          text: "$text",
          style: TextStyle(color: chartColors.defaultTextColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );

  double getBottomTextY(double textHeight) =>
      (mPaddingBottom - textHeight) / 2 + mDrawHeight;

  double getY(double volume) =>
      mDrawHeight - (mDrawHeight) * volume / mMaxVolume!;

  @override
  bool shouldRepaint(DepthChartPainter oldDelegate) {
    return oldDelegate.mBuyData != mBuyData ||
        oldDelegate.mSellData != mSellData ||
        oldDelegate.isLongPress != isLongPress ||
        oldDelegate.pressOffset != pressOffset;
  }
}

class _PopupPainter {
  ///setting
  final double space = 3.5;
  final double padding = 8.0;

  late final TextPainter pricePaint;
  late final TextPainter amountPaint;
  late final ChartColors chartColors;

  ///getter
  double get width => max(pricePaint.width, amountPaint.width) + 2 * padding;
  double get height =>
      pricePaint.height + amountPaint.height + space + 2 * padding;

  _PopupPainter({
    required DepthChartTranslations chartTranslations,
    required ChartColors chartColors,
    required String price,
    required String amount,
  }) {
    this.chartColors = chartColors;
    this.pricePaint = _getTextPainter(chartTranslations.price, price);
    this.amountPaint = _getTextPainter(chartTranslations.amount, amount);
    this.pricePaint.layout();
    this.amountPaint.layout();
  }

  void paint(Canvas canvas, Offset offset) {
    pricePaint.paint(canvas, offset + Offset(padding, padding));
    amountPaint.paint(
        canvas, offset + Offset(padding, pricePaint.height + space + padding));
  }

  TextPainter _getTextPainter(String label, String content) {
    return TextPainter(
      text: TextSpan(
        text: "$label: ",
        style: TextStyle(
            color: this.chartColors.infoWindowTitleColor, fontSize: 10),
        children: [
          TextSpan(
            text: content,
            style: TextStyle(
                color: this.chartColors.infoWindowNormalColor, fontSize: 10),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}
