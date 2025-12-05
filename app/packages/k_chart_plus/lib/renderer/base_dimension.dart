import '../k_chart_widget.dart';

class BaseDimension {
  double _mBaseHeight = 380;
  double _mVolumeHeight = 0;
  double _mSecondaryHeight = 0;
  double _totalSecondaryHeight = 0;
  double _mLabelHeight = 12;
  double _totalLabelHeight = 12;
  double _mDisplayHeight = 0;

  double get mVolumeHeight => _mVolumeHeight;
  double get mSecondaryHeight => _mSecondaryHeight;
  double get totalSecondaryHeight => _totalSecondaryHeight;
  double get mLabelHeight => _mLabelHeight;
  double get totalLabelHeight => _totalLabelHeight;
  double get mDisplayHeight => _mDisplayHeight;
  double get mBaseHeight => _mBaseHeight;

  BaseDimension({
    required double mBaseHeight,
    required bool volHidden,
    required List<SecondaryState> secondaryStateLi,
    required Set<MainState> mainStateLi,
  }) {
    _mBaseHeight = mBaseHeight;
    
    final secondaryCount = secondaryStateLi.length;
    final hasVolume = !volHidden;
    final volInList = secondaryStateLi.contains(SecondaryState.VOL);
    final actualSecondaryCount = volInList ? secondaryCount : (secondaryCount + (hasVolume ? 1 : 0));
    
    if (actualSecondaryCount > 0) {
      const secondaryRatio = 0.25;
      final unifiedHeight = _mBaseHeight * secondaryRatio;
      _mSecondaryHeight = unifiedHeight;
      _totalSecondaryHeight = _mSecondaryHeight * actualSecondaryCount;
      _mVolumeHeight = (hasVolume && !volInList) ? unifiedHeight : 0;
    }
    
    _totalLabelHeight = _mLabelHeight * mainStateLi.length;
    _mDisplayHeight = _mBaseHeight + _mVolumeHeight + _totalSecondaryHeight + _totalLabelHeight;
  }

}
