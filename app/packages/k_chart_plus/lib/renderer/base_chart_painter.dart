import 'dart:math';
import 'package:flutter/material.dart'
    show Color, TextStyle, Rect, Canvas, Size, CustomPainter;
import 'package:k_chart_plus/utils/date_format_util.dart';
import '../chart_style.dart' show ChartStyle;
import '../entity/k_line_entity.dart';
import '../k_chart_widget.dart';
import 'base_dimension.dart';
export 'package:flutter/material.dart'
    show Color, required, TextStyle, Rect, Canvas, Size, CustomPainter;

abstract class BaseChartPainter extends CustomPainter {
  static double maxScrollX = 0.0;
  List<KLineEntity>? datas;
  Set<MainState> mainStateLi;
  List<SecondaryState> secondaryStateLi;
  bool volHidden;
  int? volInsertPosition;
  bool isTapShowInfoDialog;
  double scaleX = 1.0, scrollX = 0.0, selectX;
  bool isLongPress = false;
  bool isOnTap;
  bool isLine;
  late Rect mMainLabelRect;
  late Rect mMainRect;
  Rect? mVolRect;
  List<RenderRect> mSecondaryRectList = [];
  List<SecondaryState> _unifiedSecondaryList = [];
  
  void _ensureUnifiedSecondaryList() {
    if (_unifiedSecondaryList.isEmpty && mSecondaryRectList.isNotEmpty) {
      _unifiedSecondaryList = _createUnifiedSecondaryList();
    }
  }
  
  late double mDisplayHeight, mWidth;
  double mTopPadding = 20.0, mBottomPadding = 20.0, mChildPadding = 12.0;
  int mGridRows = 4, mGridColumns = 4;
  int mStartIndex = 0, mStopIndex = 0;
  double mMainMaxValue = double.minPositive, mMainMinValue = double.maxFinite;
  double mVolMaxValue = double.minPositive, mVolMinValue = double.maxFinite;
  double mTranslateX = double.minPositive;
  int mMainMaxIndex = 0, mMainMinIndex = 0;
  double mMainHighMaxValue = double.minPositive, mMainLowMinValue = double.maxFinite;
  int mItemCount = 0;
  double mDataLen = 0.0;
  final ChartStyle chartStyle;
  late double mPointWidth;
  List<String> mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
  double xFrontPadding;
  final BaseDimension baseDimension;

  BaseChartPainter(
    this.chartStyle, {
    this.datas,
    required this.scaleX,
    required this.scrollX,
    required this.isLongPress,
    required this.selectX,
    required this.xFrontPadding,
    required this.baseDimension,
    this.isOnTap = false,
    this.mainStateLi = const <MainState>{},
    this.volHidden = false,
    this.isTapShowInfoDialog = false,
    this.secondaryStateLi = const <SecondaryState>[],
    this.volInsertPosition,
    this.isLine = false,
  }) {
    mItemCount = datas?.length ?? 0;
    mPointWidth = this.chartStyle.pointWidth;
    mTopPadding = this.chartStyle.topPadding + baseDimension.totalLabelHeight;
    mBottomPadding = this.chartStyle.bottomPadding;
    mChildPadding = this.chartStyle.childPadding;
    mGridRows = this.chartStyle.gridRows;
    mGridColumns = this.chartStyle.gridColumns;
    mDataLen = mItemCount * mPointWidth;
    initFormats();
  }

  void initFormats() {
    if (this.chartStyle.dateTimeFormat != null) {
      mFormats = this.chartStyle.dateTimeFormat!;
      return;
    }

    if (mItemCount < 2) {
      mFormats = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
      return;
    }

    int firstTime = datas!.first.time ?? 0;
    int secondTime = datas![1].time ?? 0;
    int time = secondTime - firstTime;
    time ~/= 1000;
    if (time >= 24 * 60 * 60 * 28) {
      mFormats = [yy, '-', mm];
    } else if (time >= 24 * 60 * 60) {
      mFormats = [yy, '-', mm, '-', dd];
    } else {
      mFormats = [mm, '-', dd, ' ', HH, ':', nn];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height + mBottomPadding));
    mDisplayHeight = size.height - mTopPadding;
    mWidth = size.width;
    initRect(size);
    calculateValue();
    initChartRenderer();

    canvas.save();
    canvas.scale(1, 1);
    drawBg(canvas, size);
    drawGrid(canvas);
    if (datas != null && datas!.isNotEmpty) {
      drawChart(canvas, size);
      drawVerticalText(canvas);
      drawDate(canvas, size);

      drawText(canvas, datas!.last, 5);
      drawMaxAndMin(canvas);
      drawNowPrice(canvas);

      if (isLongPress == true || (isTapShowInfoDialog && isOnTap)) {
        drawCrossLineText(canvas, size);
      }
    }
    canvas.restore();
  }

  void initChartRenderer();
  void drawBg(Canvas canvas, Size size);
  void drawGrid(canvas);
  void drawChart(Canvas canvas, Size size);
  void drawVerticalText(canvas);
  void drawDate(Canvas canvas, Size size);
  void drawText(Canvas canvas, KLineEntity data, double x);
  void drawMaxAndMin(Canvas canvas);
  void drawNowPrice(Canvas canvas);
  void drawCrossLine(Canvas canvas, Size size);
  void drawCrossLineText(Canvas canvas, Size size);

  void initRect(Size size) {
    final unifiedSecondaryList = _createUnifiedSecondaryList();
    
    if (unifiedSecondaryList.isEmpty) {
      final maxBottom = size.height - mBottomPadding;
      mMainRect = Rect.fromLTRB(0, mTopPadding, mWidth, maxBottom);
      return;
    }
    
    final mainHeight = baseDimension.mBaseHeight;
    mMainRect = Rect.fromLTRB(0, mTopPadding, mWidth, mTopPadding + mainHeight);
    _unifiedSecondaryList = unifiedSecondaryList;
    
    // 计算横坐标文字高度（用于避免副图与横坐标文字重叠）
    // 文字大小是 10.0，实际高度约为 12-14 像素（包含行高）
    final dateLabelHeight = 14.0;
    
    // 计算可用高度时，需要减去横坐标文字占用的高度
    // 横坐标文字绘制在底部 mBottomPadding 区域内，但会占用部分空间
    final availableHeight = size.height - mTopPadding - mBottomPadding - mMainRect.height - dateLabelHeight;
    final secondaryCount = unifiedSecondaryList.length;
    
    double actualChartHeight;
    if (secondaryCount > 0) {
      final totalPadding = mChildPadding * (secondaryCount - 1);
      actualChartHeight = (availableHeight - totalPadding) / secondaryCount;
      actualChartHeight = actualChartHeight.clamp(20.0, double.infinity);
    } else {
      actualChartHeight = baseDimension.mSecondaryHeight > 0 
          ? baseDimension.mSecondaryHeight 
          : baseDimension.mVolumeHeight;
    }
    
    _layoutCharts(actualChartHeight, unifiedSecondaryList, size.height);
  }
  
  List<SecondaryState> get unifiedSecondaryList => _unifiedSecondaryList;
  
  List<SecondaryState> _createUnifiedSecondaryList() {
    if (volHidden) {
      return List.from(secondaryStateLi);
    }
    
    final unifiedList = <SecondaryState>[];
    final volPosition = volInsertPosition;
    
    if (volPosition != null && volPosition >= 0 && volPosition < secondaryStateLi.length) {
      unifiedList.addAll(secondaryStateLi.take(volPosition));
      unifiedList.add(SecondaryState.VOL);
      unifiedList.addAll(secondaryStateLi.skip(volPosition));
    } else {
      unifiedList.addAll(secondaryStateLi);
      unifiedList.add(SecondaryState.VOL);
    }
    
    return unifiedList;
  }

  void _layoutCharts(double chartHeight, List<SecondaryState> unifiedSecondaryList, double maxContainerHeight) {
    mSecondaryRectList.clear();
    mVolRect = null;
    // 计算横坐标文字高度（用于避免副图与横坐标文字重叠）
    final dateLabelHeight = 14.0;
    // 最后一个副图的底部应该留出横坐标文字的空间
    final maxChartBottom = maxContainerHeight - mBottomPadding - dateLabelHeight;
    double currentTop = mMainRect.bottom;
    
    for (int i = 0; i < unifiedSecondaryList.length; i++) {
      if (i > 0) currentTop += mChildPadding;
      
      final wouldBottom = currentTop + chartHeight;
      if (wouldBottom > maxChartBottom) {
        final availableHeight = maxChartBottom - currentTop;
        if (availableHeight > 0) {
          final rect = Rect.fromLTRB(0, currentTop, mWidth, currentTop + availableHeight);
          final state = unifiedSecondaryList[i];
          
          if (state == SecondaryState.VOL) {
            mVolRect = rect;
          }
          
          mSecondaryRectList.add(RenderRect(rect));
        }
        break;
      }
      
      final rect = Rect.fromLTRB(0, currentTop, mWidth, currentTop + chartHeight);
      final state = unifiedSecondaryList[i];
      
      if (state == SecondaryState.VOL) {
        mVolRect = rect;
      }
      
      mSecondaryRectList.add(RenderRect(rect));
      currentTop += chartHeight;
    }
  }
  
  double getLastChartBottom() {
    if (mSecondaryRectList.isNotEmpty) {
      return mSecondaryRectList.last.mRect.bottom;
    }
    return mMainRect.bottom;
  }

  void calculateValue() {
    if (datas == null || datas!.isEmpty) return;
    
    maxScrollX = getMinTranslateX().abs();
    setTranslateXFromScrollX(scrollX);
    mStartIndex = indexOfTranslateX(xToTranslateX(0));
    mStopIndex = indexOfTranslateX(xToTranslateX(mWidth));
    
    for (int i = mStartIndex; i <= mStopIndex; i++) {
      final item = datas![i];
      getMainMaxMinValue(item, i);
      getVolMaxMinValue(item);
      
      for (int idx = 0; idx < mSecondaryRectList.length; idx++) {
        getSecondaryMaxMinValue(idx, item);
      }
    }
  }

  void getMainMaxMinValue(KLineEntity item, int i) {
    double maxPrice = item.high;
    double minPrice = item.low;
    
    for (final mainState in mainStateLi) {
      switch (mainState) {
        case MainState.MA:
          maxPrice = max(maxPrice, _findMaxMA(item.maValueList ?? []));
          minPrice = min(minPrice, _findMinMA(item.maValueList ?? []));
          break;
        case MainState.BOLL:
          maxPrice = max(maxPrice, item.up ?? 0);
          minPrice = min(minPrice, item.dn ?? 0);
          break;
        case MainState.SAR:
          maxPrice = max(maxPrice, item.sar ?? 0);
          minPrice = min(minPrice, item.sar ?? 0);
          break;
      }
    }

    mMainMaxValue = max(mMainMaxValue, maxPrice);
    mMainMinValue = min(mMainMinValue, minPrice);

    if (mMainHighMaxValue < item.high) {
      mMainHighMaxValue = item.high;
      mMainMaxIndex = i;
    }
    if (mMainLowMinValue > item.low) {
      mMainLowMinValue = item.low;
      mMainMinIndex = i;
    }

    if (isLine) {
      mMainMaxValue = max(mMainMaxValue, item.close);
      mMainMinValue = min(mMainMinValue, item.close);
    }
  }

  double _findMaxMA(List<double> values) {
    if (values.isEmpty) return 0;
    return values.where((v) => v > 0).fold(0.0, (max, value) => max > value ? max : value);
  }

  /// 查找MA最小值
  double _findMinMA(List<double> values) {
    if (values.isEmpty) return 0;
    final validValues = values.where((v) => v > 0).toList();
    if (validValues.isEmpty) return 0;
    return validValues.reduce((min, value) => value < min ? value : min);
  }

  void getVolMaxMinValue(KLineEntity item) {
    final volValues = [
      item.vol,
      item.MA5Volume ?? 0,
      item.MA10Volume ?? 0,
    ];
    mVolMaxValue = max(mVolMaxValue, volValues.reduce(max));
    mVolMinValue = min(mVolMinValue, volValues.reduce(min));
  }

  /// 计算副图指标的最大最小值
  void getSecondaryMaxMinValue(int index, KLineEntity item) {
    if (index >= mSecondaryRectList.length) return;
    
    final rect = mSecondaryRectList[index];
    _ensureUnifiedSecondaryList();
    
    // 使用统一的副图列表获取状态
    final state = index < _unifiedSecondaryList.length 
        ? _unifiedSecondaryList[index] 
        : SecondaryState.MACD;
    
    switch (state) {
      case SecondaryState.MACD:
        if (item.macd != null) {
          rect.mMaxValue = max(rect.mMaxValue, max(item.macd!, max(item.dif!, item.dea!)));
          rect.mMinValue = min(rect.mMinValue, min(item.macd!, min(item.dif!, item.dea!)));
        }
        break;
      case SecondaryState.KDJ:
        if (item.d != null) {
          rect.mMaxValue = max(rect.mMaxValue, max(item.k!, max(item.d!, item.j!)));
          rect.mMinValue = min(rect.mMinValue, min(item.k!, min(item.d!, item.j!)));
        }
        break;
      case SecondaryState.RSI:
        if (item.rsi != null) {
          rect.mMaxValue = max(rect.mMaxValue, item.rsi!);
          rect.mMinValue = min(rect.mMinValue, item.rsi!);
        }
        break;
      case SecondaryState.WR:
        rect.mMaxValue = 0;
        rect.mMinValue = -100;
        break;
      case SecondaryState.CCI:
        if (item.cci != null) {
          rect.mMaxValue = max(rect.mMaxValue, item.cci!);
          rect.mMinValue = min(rect.mMinValue, item.cci!);
        }
        break;
      case SecondaryState.VOL:
        break;
    }
  }

  double xToTranslateX(double x) => -mTranslateX + x / scaleX;

  int indexOfTranslateX(double translateX) =>
      _indexOfTranslateX(translateX, 0, mItemCount - 1);

  int _indexOfTranslateX(double translateX, int start, int end) {
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
      return _indexOfTranslateX(translateX, start, mid);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end);
    } else {
      return mid;
    }
  }

  double getX(int position) => position * mPointWidth + mPointWidth / 2;

  KLineEntity getItem(int position) => datas![position];

  void setTranslateXFromScrollX(double scrollX) =>
      mTranslateX = scrollX + getMinTranslateX();

  double getMinTranslateX() {
    final x = -mDataLen + mWidth / scaleX - mPointWidth / 2 - xFrontPadding;
    return x >= 0 ? 0.0 : x;
  }

  int calculateSelectedX(double selectX) {
    var index = indexOfTranslateX(xToTranslateX(selectX));
    return index.clamp(mStartIndex, mStopIndex);
  }

  /// translateX is converted to X in view
  double translateXtoX(double translateX) =>
      (translateX + mTranslateX) * scaleX;

  /// define text style
  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }

  @override
  bool shouldRepaint(BaseChartPainter oldDelegate) {
    return true;
  }
}

class RenderRect {
  Rect mRect;
  double mMaxValue = double.minPositive, mMinValue = double.maxFinite;

  RenderRect(this.mRect);
}
