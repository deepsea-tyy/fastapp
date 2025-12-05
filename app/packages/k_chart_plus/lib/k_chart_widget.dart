import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k_chart_plus/chart_translations.dart';
import 'package:k_chart_plus/components/popup_info_view.dart';
import 'package:k_chart_plus/k_chart_plus.dart';
import 'renderer/base_dimension.dart';

enum MainState { MA, BOLL, SAR }

enum SecondaryState { MACD, KDJ, RSI, WR, CCI, VOL }

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final Set<MainState> mainStateLi;
  final bool volHidden;
  final List<SecondaryState> secondaryStateLi;
  final int? volInsertPosition; // VOL在副图列表中的插入位置（用于按顺序显示）
  // final Function()? onSecondaryTap;
  final bool isLine;
  final bool
      isTapShowInfoDialog; //Whether to enable click to display detailed data
  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final bool materialInfoDialog; // Material Style Information Popup
  final ChartTranslations chartTranslations;
  final List<String> timeFormat;
  final double mBaseHeight;

  // It will be called when the screen scrolls to the end.
  // If true, it will be scrolled to the end of the right side of the screen.
  // If it is false, it will be scrolled to the end of the left side of the screen.
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final VerticalTextAlignment verticalTextAlignment;
  final bool isTrendLine;
  final double xFrontPadding;

  KChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    required this.isTrendLine,
    this.xFrontPadding = 100,
    this.mainStateLi = const <MainState>{},
    this.secondaryStateLi = const <SecondaryState>[],
    // this.onSecondaryTap,
    this.volHidden = false,
    this.volInsertPosition,
    this.isLine = false,
    this.isTapShowInfoDialog = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.materialInfoDialog = true,
    this.chartTranslations = const ChartTranslations(),
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.verticalTextAlignment = VerticalTextAlignment.left,
    this.mBaseHeight = 360,
  });

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  final StreamController<InfoWindowEntity?> mInfoWindowStream =
      StreamController<InfoWindowEntity?>();
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  double mHeight = 0, mWidth = 0;
  AnimationController? _controller;
  Animation<double>? aniX;

  // For TrendLine
  final List<TrendLine> lines = [];
  double? changeinXposition;
  double? changeinYposition;
  double mSelectY = 0.0;
  bool waitingForOtherPairofCords = false;
  bool enableCordRecord = false;

  double _lastScale = 1.0;
  bool isScale = false;
  bool isDrag = false;
  bool isLongPress = false;
  bool isOnTap = false;


  @override
  void dispose() {
    mInfoWindowStream.sink.close();
    mInfoWindowStream.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 重置状态（如果数据为空）
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    
    final baseDimension = BaseDimension(
      mBaseHeight: widget.mBaseHeight,
      volHidden: widget.volHidden,
      secondaryStateLi: widget.secondaryStateLi,
      mainStateLi: widget.mainStateLi,
    );
    
    final painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      baseDimension: baseDimension,
      lines: lines,
      sink: mInfoWindowStream.sink,
      xFrontPadding: widget.xFrontPadding,
      isTrendLine: widget.isTrendLine,
      selectY: mSelectY,
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPass: isLongPress,
      isOnTap: isOnTap,
      isTapShowInfoDialog: widget.isTapShowInfoDialog,
      mainStateLi: widget.mainStateLi,
      volHidden: widget.volHidden,
      secondaryStateLi: widget.secondaryStateLi,
      volInsertPosition: widget.volInsertPosition,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      fixedLength: widget.fixedLength,
      maDayList: widget.maDayList,
      verticalTextAlignment: widget.verticalTextAlignment,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;
        return GestureDetector(
          onTapUp: (details) {
            if (!widget.isTrendLine && painter.isInMainRect(details.localPosition)) {
              isOnTap = true;
              if (mSelectX != details.localPosition.dx && widget.isTapShowInfoDialog) {
                mSelectX = details.localPosition.dx;
                notifyChanged();
              }
            }
            
            if (widget.isTrendLine && !isLongPress && enableCordRecord) {
              enableCordRecord = false;
              final p1 = Offset(getTrendLineX(), mSelectY);
              if (waitingForOtherPairofCords) {
                final lastLine = lines.removeLast();
                lines.add(TrendLine(lastLine.p1, p1, trendLineMax!, trendLineScale!));
                waitingForOtherPairofCords = false;
              } else {
                lines.add(TrendLine(p1, Offset(-1, -1), trendLineMax!, trendLineScale!));
                waitingForOtherPairofCords = true;
              }
              notifyChanged();
            }
          },
          onHorizontalDragDown: (details) {
            isOnTap = false;
            _stopAnimation();
            _onDragChanged(true);
          },
          onHorizontalDragUpdate: (details) {
            if (isScale || isLongPress) return;
            final delta = details.primaryDelta ?? 0;
            mScrollX = ((delta / mScaleX) + mScrollX)
                .clamp(0.0, ChartPainter.maxScrollX)
                .toDouble();
            notifyChanged();
          },
          onHorizontalDragEnd: (details) {
            _onFling(details.velocity.pixelsPerSecond.dx);
          },
          onHorizontalDragCancel: () => _onDragChanged(false),
          onScaleStart: (_) {
            isScale = true;
          },
          onScaleUpdate: (details) {
            if (isDrag || isLongPress) return;
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
            notifyChanged();
          },
          onScaleEnd: (_) {
            isScale = false;
            _lastScale = mScaleX;
          },
          onLongPressStart: (details) {
            isOnTap = false;
            isLongPress = true;
            final localPos = details.localPosition;
            final globalPos = details.globalPosition;
            
            if (!widget.isTrendLine) {
              if (mSelectX != localPos.dx || mSelectY != globalPos.dy) {
                mSelectX = localPos.dx;
                notifyChanged();
              }
            } else {
              // For TrendLine
              changeinXposition = localPos.dx;
              changeinYposition = globalPos.dy;
              mSelectX = localPos.dx;
              mSelectY = globalPos.dy;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if ((mSelectX != details.localPosition.dx ||
                    mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              mSelectY = details.localPosition.dy;
              notifyChanged();
            }
            if (widget.isTrendLine) {
              final localPos = details.localPosition;
              final globalPos = details.globalPosition;
              mSelectX += localPos.dx - changeinXposition!;
              mSelectY += globalPos.dy - changeinYposition!;
              changeinXposition = localPos.dx;
              changeinYposition = globalPos.dy;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            enableCordRecord = true;
            mInfoWindowStream.sink.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                // 优先使用约束高度（如果有限且有效），否则使用计算的高度
                // 注意：BaseChartPainter 会从 size.height 中减去 padding，所以这里需要加上 padding
                size: Size(
                  double.infinity,
                  constraints.maxHeight.isFinite && constraints.maxHeight > 0
                      ? constraints.maxHeight
                      : baseDimension.mDisplayHeight + widget.chartStyle.topPadding + widget.chartStyle.bottomPadding,
                ),
                painter: painter,
              ),
              if (widget.showInfoDialog) _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double velocity) {
    _controller?.dispose();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );
    
    final endValue = velocity * widget.flingRatio + mScrollX;
    aniX = Tween<double>(begin: mScrollX, end: endValue)
        .animate(CurvedAnimation(
          parent: _controller!.view,
          curve: widget.flingCurve,
        ));
    
    aniX!.addListener(() {
      mScrollX = aniX!.value.clamp(0.0, ChartPainter.maxScrollX).toDouble();
      
      if (mScrollX <= 0) {
        widget.onLoadMore?.call(true);
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        widget.onLoadMore?.call(false);
        _stopAnimation();
      }
      notifyChanged();
    });
    
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    
    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
      stream: mInfoWindowStream.stream,
      builder: (context, snapshot) {
        if ((!isLongPress && !isOnTap) ||
            widget.isLine ||
            !snapshot.hasData ||
            snapshot.data?.kLineEntity == null) {
          return const SizedBox.shrink();
        }
        
        final entity = snapshot.data!.kLineEntity;
        final dialogWidth = mWidth / 3;
        final popupInfo = PopupInfoView(
          entity: entity,
          width: dialogWidth,
          chartColors: widget.chartColors,
          chartTranslations: widget.chartTranslations,
          materialInfoDialog: widget.materialInfoDialog,
          timeFormat: widget.timeFormat,
          fixedLength: widget.fixedLength,
        );
        
        return snapshot.data!.isLeft
            ? Positioned(top: 25, left: 10.0, child: popupInfo)
            : Positioned(top: 25, right: 10.0, child: popupInfo);
      },
    );
  }
}
