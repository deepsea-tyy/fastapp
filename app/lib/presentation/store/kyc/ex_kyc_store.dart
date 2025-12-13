import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/data/network/apis/kyc/ex_kyc_api.dart';
import 'package:fastapp/domain/entity/kyc/ex_kyc.dart';
import 'package:mobx/mobx.dart';

part 'ex_kyc_store.g.dart';

class ExKycStore = _ExKycStore with _$ExKycStore;

abstract class _ExKycStore with Store {
  final ExKycApi _kycApi;
  final ErrorStore _errorStore;

  _ExKycStore(this._kycApi, this._errorStore);

  // ==================== 私有状态 ====================

  /// 防止并发请求的锁
  bool _isFetching = false;

  // ==================== 可观察状态 ====================

  /// KYC认证记录（按等级存储）
  @observable
  ObservableMap<int, ExKyc> kycMap = ObservableMap<int, ExKyc>();

  /// 加载状态
  @observable
  bool isLoading = false;

  /// 提交状态
  @observable
  bool isSubmitting = false;

  /// 提交成功状态
  @observable
  bool submitSuccess = false;

  // ==================== 计算属性 ====================

  /// 获取标准认证（Level 1）记录
  @computed
  ExKyc? get level1Kyc => kycMap[1];

  /// 获取进阶认证（Level 2）记录
  @computed
  ExKyc? get level2Kyc => kycMap[2];

  /// 是否已完成标准认证
  @computed
  bool get isLevel1Approved => level1Kyc?.isApproved ?? false;

  /// 是否已完成进阶认证
  @computed
  bool get isLevel2Approved => level2Kyc?.isApproved ?? false;

  /// 获取最高已通过的认证等级
  @computed
  int get maxApprovedLevel {
    if (isLevel2Approved) return 2;
    if (isLevel1Approved) return 1;
    return 0;
  }

  /// 获取当前显示的 KYC（优先显示高等级）
  @computed
  ExKyc? get currentKyc {
    if (level2Kyc != null) return level2Kyc;
    if (level1Kyc != null) return level1Kyc;
    return null;
  }

  // ==================== Actions ====================

  /// 获取KYC详情
  @action
  Future<void> fetchKycDetail({int? kycLevel}) async {
    isLoading = true;
    _errorStore.setErrorMessage('');

    try {
      final response = await _kycApi.getKycDetail(kycLevel: kycLevel);

      if (response['code'] == 1 && response['data'] != null) {
        final kyc = ExKyc.fromJson(response['data']);
        kycMap[kyc.kycLevel] = kyc;
      } else {
        // 没有KYC记录，清空对应等级
        if (kycLevel != null) {
          kycMap.remove(kycLevel);
        }
      }
    } catch (e) {
      _errorStore.setErrorMessage(e.toString());
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// 获取所有等级的KYC记录
  @action
  Future<void> fetchAllKycDetails() async {
    // 防止并发请求
    if (_isFetching) {
      return;
    }

    _isFetching = true;
    isLoading = true;
    _errorStore.setErrorMessage('');

    try {
      // 并行获取Level 1和Level 2
      final results = await Future.wait([
        _kycApi.getKycDetail(kycLevel: 1).catchError((_) => null),
        _kycApi.getKycDetail(kycLevel: 2).catchError((_) => null),
      ]);

      // 处理Level 1结果
      final level1Response = results[0];
      if (level1Response != null &&
          level1Response['code'] == 1 &&
          level1Response['data'] != null) {
        final kyc = ExKyc.fromJson(level1Response['data']);
        kycMap[1] = kyc;
      } else {
        kycMap.remove(1);
      }

      // 处理Level 2结果
      final level2Response = results[1];
      if (level2Response != null &&
          level2Response['code'] == 1 &&
          level2Response['data'] != null) {
        final kyc = ExKyc.fromJson(level2Response['data']);
        kycMap[2] = kyc;
      } else {
        kycMap.remove(2);
      }
    } catch (e) {
      _errorStore.setErrorMessage(e.toString());
      // 不抛出错误，让界面可以继续使用
    } finally {
      isLoading = false;
      _isFetching = false;
    }
  }

  /// 提交KYC认证申请
  @action
  Future<void> submitKyc({
    required int kycLevel,
    required String countryCode,
    required String surname,
    String? middleName,
    required String name,
    required int gender,
    required String birthday,
    required String idType,
    required String idNumber,
    required String idIssueDate,
    String? idExpiryDate,
    required String address,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    String? locationAddress,
    required String idFrontImage,
    required String idBackImage,
    required String idSelfieImage,
    String? addressProofImage,
  }) async {
    isSubmitting = true;
    submitSuccess = false;
    _errorStore.setErrorMessage('');

    try {
      final response = await _kycApi.submitKyc(
        kycLevel: kycLevel,
        countryCode: countryCode,
        surname: surname,
        middleName: middleName,
        name: name,
        gender: gender,
        birthday: birthday,
        idType: idType,
        idNumber: idNumber,
        idIssueDate: idIssueDate,
        idExpiryDate: idExpiryDate,
        address: address,
        latitude: latitude,
        longitude: longitude,
        locationAccuracy: locationAccuracy,
        locationAddress: locationAddress,
        idFrontImage: idFrontImage,
        idBackImage: idBackImage,
        idSelfieImage: idSelfieImage,
        addressProofImage: addressProofImage,
      );

      if (response['code'] == 1 && response['data'] != null) {
        final kyc = ExKyc.fromJson(response['data']);
        kycMap[kyc.kycLevel] = kyc;
        submitSuccess = true;
      } else {
        throw Exception(response['msg'] ?? '提交失败');
      }
    } catch (e) {
      _errorStore.setErrorMessage(e.toString());
      rethrow;
    } finally {
      isSubmitting = false;
    }
  }

  /// 清空状态
  @action
  void clear() {
    kycMap.clear();
    isLoading = false;
    isSubmitting = false;
    submitSuccess = false;
  }

  /// 重置提交成功状态
  @action
  void resetSubmitSuccess() {
    submitSuccess = false;
  }
}
