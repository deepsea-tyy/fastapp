/// 国家/地区数据
/// 包含国家代码、国旗、名称等信息
class CountryData {
  /// 国旗 emoji
  final String flag;

  /// 电话区号（带 + 号）
  final String phoneCode;

  /// ISO 3166-1 alpha-2 国家代码（两位字母）
  final String code;

  /// 国家/地区中文名称
  final String nameCn;

  /// 国家/地区英文名称
  final String nameEn;

  const CountryData({
    required this.flag,
    required this.phoneCode,
    required this.code,
    required this.nameCn,
    required this.nameEn,
  });

  /// 显示名称（默认使用中文）
  String get displayName => nameCn;

  /// 用于电话号码选择的显示文本
  String get phoneDisplayText => '$flag $phoneCode';

  /// 用于国家选择的显示文本
  String get countryDisplayText => '$flag $nameCn';
}

/// 国家/地区数据列表
class Countries {
  Countries._();

  /// 所有支持的国家/地区列表
  static const List<CountryData> all = [
    // 亚洲
    CountryData(flag: '🇨🇳', phoneCode: '+86', code: 'CN', nameCn: '中国', nameEn: 'China'),
    CountryData(flag: '🇭🇰', phoneCode: '+852', code: 'HK', nameCn: '中国香港', nameEn: 'Hong Kong'),
    CountryData(flag: '🇲🇴', phoneCode: '+853', code: 'MO', nameCn: '中国澳门', nameEn: 'Macau'),
    CountryData(flag: '🇹🇼', phoneCode: '+886', code: 'TW', nameCn: '中国台湾', nameEn: 'Taiwan'),
    CountryData(flag: '🇯🇵', phoneCode: '+81', code: 'JP', nameCn: '日本', nameEn: 'Japan'),
    CountryData(flag: '🇰🇷', phoneCode: '+82', code: 'KR', nameCn: '韩国', nameEn: 'South Korea'),
    CountryData(flag: '🇸🇬', phoneCode: '+65', code: 'SG', nameCn: '新加坡', nameEn: 'Singapore'),
    CountryData(flag: '🇲🇾', phoneCode: '+60', code: 'MY', nameCn: '马来西亚', nameEn: 'Malaysia'),
    CountryData(flag: '🇹🇭', phoneCode: '+66', code: 'TH', nameCn: '泰国', nameEn: 'Thailand'),
    CountryData(flag: '🇻🇳', phoneCode: '+84', code: 'VN', nameCn: '越南', nameEn: 'Vietnam'),
    CountryData(flag: '🇵🇭', phoneCode: '+63', code: 'PH', nameCn: '菲律宾', nameEn: 'Philippines'),
    CountryData(flag: '🇮🇩', phoneCode: '+62', code: 'ID', nameCn: '印度尼西亚', nameEn: 'Indonesia'),
    CountryData(flag: '🇮🇳', phoneCode: '+91', code: 'IN', nameCn: '印度', nameEn: 'India'),
    CountryData(flag: '🇵🇰', phoneCode: '+92', code: 'PK', nameCn: '巴基斯坦', nameEn: 'Pakistan'),
    CountryData(flag: '🇧🇩', phoneCode: '+880', code: 'BD', nameCn: '孟加拉国', nameEn: 'Bangladesh'),
    CountryData(flag: '🇱🇰', phoneCode: '+94', code: 'LK', nameCn: '斯里兰卡', nameEn: 'Sri Lanka'),
    CountryData(flag: '🇲🇲', phoneCode: '+95', code: 'MM', nameCn: '缅甸', nameEn: 'Myanmar'),
    CountryData(flag: '🇰🇭', phoneCode: '+855', code: 'KH', nameCn: '柬埔寨', nameEn: 'Cambodia'),
    CountryData(flag: '🇱🇦', phoneCode: '+856', code: 'LA', nameCn: '老挝', nameEn: 'Laos'),
    CountryData(flag: '🇧🇳', phoneCode: '+673', code: 'BN', nameCn: '文莱', nameEn: 'Brunei'),
    CountryData(flag: '🇦🇪', phoneCode: '+971', code: 'AE', nameCn: '阿联酋', nameEn: 'United Arab Emirates'),
    CountryData(flag: '🇸🇦', phoneCode: '+966', code: 'SA', nameCn: '沙特阿拉伯', nameEn: 'Saudi Arabia'),
    CountryData(flag: '🇮🇱', phoneCode: '+972', code: 'IL', nameCn: '以色列', nameEn: 'Israel'),
    CountryData(flag: '🇹🇷', phoneCode: '+90', code: 'TR', nameCn: '土耳其', nameEn: 'Turkey'),
    CountryData(flag: '🇮🇷', phoneCode: '+98', code: 'IR', nameCn: '伊朗', nameEn: 'Iran'),
    CountryData(flag: '🇮🇶', phoneCode: '+964', code: 'IQ', nameCn: '伊拉克', nameEn: 'Iraq'),

    // 欧洲
    CountryData(flag: '🇬🇧', phoneCode: '+44', code: 'GB', nameCn: '英国', nameEn: 'United Kingdom'),
    CountryData(flag: '🇫🇷', phoneCode: '+33', code: 'FR', nameCn: '法国', nameEn: 'France'),
    CountryData(flag: '🇩🇪', phoneCode: '+49', code: 'DE', nameCn: '德国', nameEn: 'Germany'),
    CountryData(flag: '🇮🇹', phoneCode: '+39', code: 'IT', nameCn: '意大利', nameEn: 'Italy'),
    CountryData(flag: '🇪🇸', phoneCode: '+34', code: 'ES', nameCn: '西班牙', nameEn: 'Spain'),
    CountryData(flag: '🇵🇹', phoneCode: '+351', code: 'PT', nameCn: '葡萄牙', nameEn: 'Portugal'),
    CountryData(flag: '🇳🇱', phoneCode: '+31', code: 'NL', nameCn: '荷兰', nameEn: 'Netherlands'),
    CountryData(flag: '🇧🇪', phoneCode: '+32', code: 'BE', nameCn: '比利时', nameEn: 'Belgium'),
    CountryData(flag: '🇨🇭', phoneCode: '+41', code: 'CH', nameCn: '瑞士', nameEn: 'Switzerland'),
    CountryData(flag: '🇦🇹', phoneCode: '+43', code: 'AT', nameCn: '奥地利', nameEn: 'Austria'),
    CountryData(flag: '🇸🇪', phoneCode: '+46', code: 'SE', nameCn: '瑞典', nameEn: 'Sweden'),
    CountryData(flag: '🇳🇴', phoneCode: '+47', code: 'NO', nameCn: '挪威', nameEn: 'Norway'),
    CountryData(flag: '🇩🇰', phoneCode: '+45', code: 'DK', nameCn: '丹麦', nameEn: 'Denmark'),
    CountryData(flag: '🇫🇮', phoneCode: '+358', code: 'FI', nameCn: '芬兰', nameEn: 'Finland'),
    CountryData(flag: '🇮🇪', phoneCode: '+353', code: 'IE', nameCn: '爱尔兰', nameEn: 'Ireland'),
    CountryData(flag: '🇵🇱', phoneCode: '+48', code: 'PL', nameCn: '波兰', nameEn: 'Poland'),
    CountryData(flag: '🇨🇿', phoneCode: '+420', code: 'CZ', nameCn: '捷克', nameEn: 'Czech Republic'),
    CountryData(flag: '🇭🇺', phoneCode: '+36', code: 'HU', nameCn: '匈牙利', nameEn: 'Hungary'),
    CountryData(flag: '🇷🇺', phoneCode: '+7', code: 'RU', nameCn: '俄罗斯', nameEn: 'Russia'),
    CountryData(flag: '🇺🇦', phoneCode: '+380', code: 'UA', nameCn: '乌克兰', nameEn: 'Ukraine'),
    CountryData(flag: '🇬🇷', phoneCode: '+30', code: 'GR', nameCn: '希腊', nameEn: 'Greece'),
    CountryData(flag: '🇷🇴', phoneCode: '+40', code: 'RO', nameCn: '罗马尼亚', nameEn: 'Romania'),

    // 北美洲
    CountryData(flag: '🇺🇸', phoneCode: '+1', code: 'US', nameCn: '美国', nameEn: 'United States'),
    CountryData(flag: '🇨🇦', phoneCode: '+1', code: 'CA', nameCn: '加拿大', nameEn: 'Canada'),
    CountryData(flag: '🇲🇽', phoneCode: '+52', code: 'MX', nameCn: '墨西哥', nameEn: 'Mexico'),

    // 南美洲
    CountryData(flag: '🇧🇷', phoneCode: '+55', code: 'BR', nameCn: '巴西', nameEn: 'Brazil'),
    CountryData(flag: '🇦🇷', phoneCode: '+54', code: 'AR', nameCn: '阿根廷', nameEn: 'Argentina'),
    CountryData(flag: '🇨🇱', phoneCode: '+56', code: 'CL', nameCn: '智利', nameEn: 'Chile'),
    CountryData(flag: '🇨🇴', phoneCode: '+57', code: 'CO', nameCn: '哥伦比亚', nameEn: 'Colombia'),
    CountryData(flag: '🇵🇪', phoneCode: '+51', code: 'PE', nameCn: '秘鲁', nameEn: 'Peru'),
    CountryData(flag: '🇻🇪', phoneCode: '+58', code: 'VE', nameCn: '委内瑞拉', nameEn: 'Venezuela'),

    // 大洋洲
    CountryData(flag: '🇦🇺', phoneCode: '+61', code: 'AU', nameCn: '澳大利亚', nameEn: 'Australia'),
    CountryData(flag: '🇳🇿', phoneCode: '+64', code: 'NZ', nameCn: '新西兰', nameEn: 'New Zealand'),

    // 非洲
    CountryData(flag: '🇿🇦', phoneCode: '+27', code: 'ZA', nameCn: '南非', nameEn: 'South Africa'),
    CountryData(flag: '🇪🇬', phoneCode: '+20', code: 'EG', nameCn: '埃及', nameEn: 'Egypt'),
    CountryData(flag: '🇳🇬', phoneCode: '+234', code: 'NG', nameCn: '尼日利亚', nameEn: 'Nigeria'),
    CountryData(flag: '🇰🇪', phoneCode: '+254', code: 'KE', nameCn: '肯尼亚', nameEn: 'Kenya'),
    CountryData(flag: '🇪🇹', phoneCode: '+251', code: 'ET', nameCn: '埃塞俄比亚', nameEn: 'Ethiopia'),
    CountryData(flag: '🇲🇦', phoneCode: '+212', code: 'MA', nameCn: '摩洛哥', nameEn: 'Morocco'),
  ];

  /// 常用国家/地区（排在前面）
  static const List<CountryData> popular = [
    CountryData(flag: '🇨🇳', phoneCode: '+86', code: 'CN', nameCn: '中国', nameEn: 'China'),
    CountryData(flag: '🇭🇰', phoneCode: '+852', code: 'HK', nameCn: '中国香港', nameEn: 'Hong Kong'),
    CountryData(flag: '🇹🇼', phoneCode: '+886', code: 'TW', nameCn: '中国台湾', nameEn: 'Taiwan'),
    CountryData(flag: '🇺🇸', phoneCode: '+1', code: 'US', nameCn: '美国', nameEn: 'United States'),
    CountryData(flag: '🇬🇧', phoneCode: '+44', code: 'GB', nameCn: '英国', nameEn: 'United Kingdom'),
    CountryData(flag: '🇯🇵', phoneCode: '+81', code: 'JP', nameCn: '日本', nameEn: 'Japan'),
    CountryData(flag: '🇰🇷', phoneCode: '+82', code: 'KR', nameCn: '韩国', nameEn: 'South Korea'),
    CountryData(flag: '🇸🇬', phoneCode: '+65', code: 'SG', nameCn: '新加坡', nameEn: 'Singapore'),
  ];

  /// 根据国家代码查找国家数据
  static CountryData? findByCode(String code) {
    try {
      return all.firstWhere(
        (country) => country.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 根据电话区号查找国家数据
  static CountryData? findByPhoneCode(String phoneCode) {
    try {
      return all.firstWhere(
        (country) => country.phoneCode == phoneCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// 默认国家（中国）
  static const CountryData defaultCountry = CountryData(
    flag: '🇨🇳',
    phoneCode: '+86',
    code: 'CN',
    nameCn: '中国',
    nameEn: 'China',
  );
}
