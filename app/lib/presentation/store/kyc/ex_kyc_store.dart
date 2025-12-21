import 'package:fastapp/core/stores/error/error_store.dart';
import 'package:fastapp/domain/usecase/kyc/get_kyc_detail_usecase.dart';
import 'package:fastapp/domain/usecase/kyc/submit_kyc_usecase.dart';
import 'package:fastapp/domain/entity/kyc/ex_kyc.dart';
import 'package:fastapp/utils/data_validator.dart';
import 'package:mobx/mobx.dart';

part 'ex_kyc_store.g.dart';

class ExKycStore = _ExKycStore with _$ExKycStore;

abstract class _ExKycStore with Store {
  final GetKycDetailUseCase _getKycDetailUseCase;
  final SubmitKycUseCase _submitKycUseCase;
  final ErrorStore _errorStore;

  _ExKycStore(
    this._getKycDetailUseCase,
    this._submitKycUseCase,
    this._errorStore,
  );

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
      final data = await _getKycDetailUseCase.call(
        params: GetKycDetailParams(kycLevel: kycLevel),
      );

      // 使用 DataValidator 提取单个对象
      final kycData = DataValidator.extractObject(
        data,
        requiredFields: ['user_id', 'kyc_level', 'status'],
      );

      if (kycData != null) {
        final kyc = ExKyc.fromJson(kycData);
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
      // 不传 kycLevel 参数，一次请求获取所有数据
      final data = await _getKycDetailUseCase.call(
        params: GetKycDetailParams(),
      );

      // 使用 DataValidator 提取有效的 KYC 数据列表
      final kycList = DataValidator.extractList(
        data,
        requiredFields: ['user_id', 'kyc_level', 'status'],
      );

      // 清空旧数据
      kycMap.clear();

      // 解析并存储有效数据
      if (kycList.isNotEmpty) {
        for (var item in kycList) {
          final kyc = ExKyc.fromJson(item);
          kycMap[kyc.kycLevel] = kyc;
        }
      }
    } catch (e, stackTrace) {
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
    String? locationTime,
    required String idFrontImage,
    required String idBackImage,
    required String idSelfieImage,
    String? addressProofImage,
  }) async {
    isSubmitting = true;
    submitSuccess = false;
    _errorStore.setErrorMessage('');

    try {
      final data = await _submitKycUseCase.call(
        params: SubmitKycParams(
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
          locationTime: locationTime,
          idFrontImage: idFrontImage,
          idBackImage: idBackImage,
          idSelfieImage: idSelfieImage,
          addressProofImage: addressProofImage,
        ),
      );

      // 提交成功，解析返回的 KYC 数据（响应拦截器已处理，直接使用 data）
      final kyc = ExKyc.fromJson(data);
      kycMap[kyc.kycLevel] = kyc;
      submitSuccess = true;
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
