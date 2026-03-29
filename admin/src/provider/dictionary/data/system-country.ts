/**
 * 国家/地区数据字典
 * 包含国家代码、国旗、名称等信息
 * 与 Flutter 应用数据保持一致
 */

import type { Dictionary } from '#/global'

export interface CountryDictionary extends Dictionary {
  /** 国旗 emoji */
  flag: string
  /** 电话区号（带 + 号） */
  phoneCode: string
  /** ISO 3166-1 alpha-2 国家代码（两位字母） */
  code: string
  /** 国家/地区中文名称 */
  nameCn: string
  /** 国家/地区英文名称 */
  nameEn: string
}

export default [
  // 亚洲
  { label: '中国', value: 'CN', flag: '🇨🇳', phoneCode: '+86', code: 'CN', nameCn: '中国', nameEn: 'China', i18n: 'dictionary.system.country.CN' },
  { label: '中国香港', value: 'HK', flag: '🇭🇰', phoneCode: '+852', code: 'HK', nameCn: '中国香港', nameEn: 'Hong Kong', i18n: 'dictionary.system.country.HK' },
  { label: '中国澳门', value: 'MO', flag: '🇲🇴', phoneCode: '+853', code: 'MO', nameCn: '中国澳门', nameEn: 'Macau', i18n: 'dictionary.system.country.MO' },
  { label: '中国台湾', value: 'TW', flag: '🇹🇼', phoneCode: '+886', code: 'TW', nameCn: '中国台湾', nameEn: 'Taiwan', i18n: 'dictionary.system.country.TW' },
  { label: '日本', value: 'JP', flag: '🇯🇵', phoneCode: '+81', code: 'JP', nameCn: '日本', nameEn: 'Japan', i18n: 'dictionary.system.country.JP' },
  { label: '韩国', value: 'KR', flag: '🇰🇷', phoneCode: '+82', code: 'KR', nameCn: '韩国', nameEn: 'South Korea', i18n: 'dictionary.system.country.KR' },
  { label: '新加坡', value: 'SG', flag: '🇸🇬', phoneCode: '+65', code: 'SG', nameCn: '新加坡', nameEn: 'Singapore', i18n: 'dictionary.system.country.SG' },
  { label: '马来西亚', value: 'MY', flag: '🇲🇾', phoneCode: '+60', code: 'MY', nameCn: '马来西亚', nameEn: 'Malaysia', i18n: 'dictionary.system.country.MY' },
  { label: '泰国', value: 'TH', flag: '🇹🇭', phoneCode: '+66', code: 'TH', nameCn: '泰国', nameEn: 'Thailand', i18n: 'dictionary.system.country.TH' },
  { label: '越南', value: 'VN', flag: '🇻🇳', phoneCode: '+84', code: 'VN', nameCn: '越南', nameEn: 'Vietnam', i18n: 'dictionary.system.country.VN' },
  { label: '菲律宾', value: 'PH', flag: '🇵🇭', phoneCode: '+63', code: 'PH', nameCn: '菲律宾', nameEn: 'Philippines', i18n: 'dictionary.system.country.PH' },
  { label: '印度尼西亚', value: 'ID', flag: '🇮🇩', phoneCode: '+62', code: 'ID', nameCn: '印度尼西亚', nameEn: 'Indonesia', i18n: 'dictionary.system.country.ID' },
  { label: '印度', value: 'IN', flag: '🇮🇳', phoneCode: '+91', code: 'IN', nameCn: '印度', nameEn: 'India', i18n: 'dictionary.system.country.IN' },
  { label: '巴基斯坦', value: 'PK', flag: '🇵🇰', phoneCode: '+92', code: 'PK', nameCn: '巴基斯坦', nameEn: 'Pakistan', i18n: 'dictionary.system.country.PK' },
  { label: '孟加拉国', value: 'BD', flag: '🇧🇩', phoneCode: '+880', code: 'BD', nameCn: '孟加拉国', nameEn: 'Bangladesh', i18n: 'dictionary.system.country.BD' },
  { label: '斯里兰卡', value: 'LK', flag: '🇱🇰', phoneCode: '+94', code: 'LK', nameCn: '斯里兰卡', nameEn: 'Sri Lanka', i18n: 'dictionary.system.country.LK' },
  { label: '缅甸', value: 'MM', flag: '🇲🇲', phoneCode: '+95', code: 'MM', nameCn: '缅甸', nameEn: 'Myanmar', i18n: 'dictionary.system.country.MM' },
  { label: '柬埔寨', value: 'KH', flag: '🇰🇭', phoneCode: '+855', code: 'KH', nameCn: '柬埔寨', nameEn: 'Cambodia', i18n: 'dictionary.system.country.KH' },
  { label: '老挝', value: 'LA', flag: '🇱🇦', phoneCode: '+856', code: 'LA', nameCn: '老挝', nameEn: 'Laos', i18n: 'dictionary.system.country.LA' },
  { label: '文莱', value: 'BN', flag: '🇧🇳', phoneCode: '+673', code: 'BN', nameCn: '文莱', nameEn: 'Brunei', i18n: 'dictionary.system.country.BN' },
  { label: '阿联酋', value: 'AE', flag: '🇦🇪', phoneCode: '+971', code: 'AE', nameCn: '阿联酋', nameEn: 'United Arab Emirates', i18n: 'dictionary.system.country.AE' },
  { label: '沙特阿拉伯', value: 'SA', flag: '🇸🇦', phoneCode: '+966', code: 'SA', nameCn: '沙特阿拉伯', nameEn: 'Saudi Arabia', i18n: 'dictionary.system.country.SA' },
  { label: '以色列', value: 'IL', flag: '🇮🇱', phoneCode: '+972', code: 'IL', nameCn: '以色列', nameEn: 'Israel', i18n: 'dictionary.system.country.IL' },
  { label: '土耳其', value: 'TR', flag: '🇹🇷', phoneCode: '+90', code: 'TR', nameCn: '土耳其', nameEn: 'Turkey', i18n: 'dictionary.system.country.TR' },
  { label: '伊朗', value: 'IR', flag: '🇮🇷', phoneCode: '+98', code: 'IR', nameCn: '伊朗', nameEn: 'Iran', i18n: 'dictionary.system.country.IR' },
  { label: '伊拉克', value: 'IQ', flag: '🇮🇶', phoneCode: '+964', code: 'IQ', nameCn: '伊拉克', nameEn: 'Iraq', i18n: 'dictionary.system.country.IQ' },

  // 欧洲
  { label: '英国', value: 'GB', flag: '🇬🇧', phoneCode: '+44', code: 'GB', nameCn: '英国', nameEn: 'United Kingdom', i18n: 'dictionary.system.country.GB' },
  { label: '法国', value: 'FR', flag: '🇫🇷', phoneCode: '+33', code: 'FR', nameCn: '法国', nameEn: 'France', i18n: 'dictionary.system.country.FR' },
  { label: '德国', value: 'DE', flag: '🇩🇪', phoneCode: '+49', code: 'DE', nameCn: '德国', nameEn: 'Germany', i18n: 'dictionary.system.country.DE' },
  { label: '意大利', value: 'IT', flag: '🇮🇹', phoneCode: '+39', code: 'IT', nameCn: '意大利', nameEn: 'Italy', i18n: 'dictionary.system.country.IT' },
  { label: '西班牙', value: 'ES', flag: '🇪🇸', phoneCode: '+34', code: 'ES', nameCn: '西班牙', nameEn: 'Spain', i18n: 'dictionary.system.country.ES' },
  { label: '葡萄牙', value: 'PT', flag: '🇵🇹', phoneCode: '+351', code: 'PT', nameCn: '葡萄牙', nameEn: 'Portugal', i18n: 'dictionary.system.country.PT' },
  { label: '荷兰', value: 'NL', flag: '🇳🇱', phoneCode: '+31', code: 'NL', nameCn: '荷兰', nameEn: 'Netherlands', i18n: 'dictionary.system.country.NL' },
  { label: '比利时', value: 'BE', flag: '🇧🇪', phoneCode: '+32', code: 'BE', nameCn: '比利时', nameEn: 'Belgium', i18n: 'dictionary.system.country.BE' },
  { label: '瑞士', value: 'CH', flag: '🇨🇭', phoneCode: '+41', code: 'CH', nameCn: '瑞士', nameEn: 'Switzerland', i18n: 'dictionary.system.country.CH' },
  { label: '奥地利', value: 'AT', flag: '🇦🇹', phoneCode: '+43', code: 'AT', nameCn: '奥地利', nameEn: 'Austria', i18n: 'dictionary.system.country.AT' },
  { label: '瑞典', value: 'SE', flag: '🇸🇪', phoneCode: '+46', code: 'SE', nameCn: '瑞典', nameEn: 'Sweden', i18n: 'dictionary.system.country.SE' },
  { label: '挪威', value: 'NO', flag: '🇳🇴', phoneCode: '+47', code: 'NO', nameCn: '挪威', nameEn: 'Norway', i18n: 'dictionary.system.country.NO' },
  { label: '丹麦', value: 'DK', flag: '🇩🇰', phoneCode: '+45', code: 'DK', nameCn: '丹麦', nameEn: 'Denmark', i18n: 'dictionary.system.country.DK' },
  { label: '芬兰', value: 'FI', flag: '🇫🇮', phoneCode: '+358', code: 'FI', nameCn: '芬兰', nameEn: 'Finland', i18n: 'dictionary.system.country.FI' },
  { label: '爱尔兰', value: 'IE', flag: '🇮🇪', phoneCode: '+353', code: 'IE', nameCn: '爱尔兰', nameEn: 'Ireland', i18n: 'dictionary.system.country.IE' },
  { label: '波兰', value: 'PL', flag: '🇵🇱', phoneCode: '+48', code: 'PL', nameCn: '波兰', nameEn: 'Poland', i18n: 'dictionary.system.country.PL' },
  { label: '捷克', value: 'CZ', flag: '🇨🇿', phoneCode: '+420', code: 'CZ', nameCn: '捷克', nameEn: 'Czech Republic', i18n: 'dictionary.system.country.CZ' },
  { label: '匈牙利', value: 'HU', flag: '🇭🇺', phoneCode: '+36', code: 'HU', nameCn: '匈牙利', nameEn: 'Hungary', i18n: 'dictionary.system.country.HU' },
  { label: '俄罗斯', value: 'RU', flag: '🇷🇺', phoneCode: '+7', code: 'RU', nameCn: '俄罗斯', nameEn: 'Russia', i18n: 'dictionary.system.country.RU' },
  { label: '乌克兰', value: 'UA', flag: '🇺🇦', phoneCode: '+380', code: 'UA', nameCn: '乌克兰', nameEn: 'Ukraine', i18n: 'dictionary.system.country.UA' },
  { label: '希腊', value: 'GR', flag: '🇬🇷', phoneCode: '+30', code: 'GR', nameCn: '希腊', nameEn: 'Greece', i18n: 'dictionary.system.country.GR' },
  { label: '罗马尼亚', value: 'RO', flag: '🇷🇴', phoneCode: '+40', code: 'RO', nameCn: '罗马尼亚', nameEn: 'Romania', i18n: 'dictionary.system.country.RO' },

  // 北美洲
  { label: '美国', value: 'US', flag: '🇺🇸', phoneCode: '+1', code: 'US', nameCn: '美国', nameEn: 'United States', i18n: 'dictionary.system.country.US' },
  { label: '加拿大', value: 'CA', flag: '🇨🇦', phoneCode: '+1', code: 'CA', nameCn: '加拿大', nameEn: 'Canada', i18n: 'dictionary.system.country.CA' },
  { label: '墨西哥', value: 'MX', flag: '🇲🇽', phoneCode: '+52', code: 'MX', nameCn: '墨西哥', nameEn: 'Mexico', i18n: 'dictionary.system.country.MX' },

  // 南美洲
  { label: '巴西', value: 'BR', flag: '🇧🇷', phoneCode: '+55', code: 'BR', nameCn: '巴西', nameEn: 'Brazil', i18n: 'dictionary.system.country.BR' },
  { label: '阿根廷', value: 'AR', flag: '🇦🇷', phoneCode: '+54', code: 'AR', nameCn: '阿根廷', nameEn: 'Argentina', i18n: 'dictionary.system.country.AR' },
  { label: '智利', value: 'CL', flag: '🇨🇱', phoneCode: '+56', code: 'CL', nameCn: '智利', nameEn: 'Chile', i18n: 'dictionary.system.country.CL' },
  { label: '哥伦比亚', value: 'CO', flag: '🇨🇴', phoneCode: '+57', code: 'CO', nameCn: '哥伦比亚', nameEn: 'Colombia', i18n: 'dictionary.system.country.CO' },
  { label: '秘鲁', value: 'PE', flag: '🇵🇪', phoneCode: '+51', code: 'PE', nameCn: '秘鲁', nameEn: 'Peru', i18n: 'dictionary.system.country.PE' },
  { label: '委内瑞拉', value: 'VE', flag: '🇻🇪', phoneCode: '+58', code: 'VE', nameCn: '委内瑞拉', nameEn: 'Venezuela', i18n: 'dictionary.system.country.VE' },

  // 大洋洲
  { label: '澳大利亚', value: 'AU', flag: '🇦🇺', phoneCode: '+61', code: 'AU', nameCn: '澳大利亚', nameEn: 'Australia', i18n: 'dictionary.system.country.AU' },
  { label: '新西兰', value: 'NZ', flag: '🇳🇿', phoneCode: '+64', code: 'NZ', nameCn: '新西兰', nameEn: 'New Zealand', i18n: 'dictionary.system.country.NZ' },

  // 非洲
  { label: '南非', value: 'ZA', flag: '🇿🇦', phoneCode: '+27', code: 'ZA', nameCn: '南非', nameEn: 'South Africa', i18n: 'dictionary.system.country.ZA' },
  { label: '埃及', value: 'EG', flag: '🇪🇬', phoneCode: '+20', code: 'EG', nameCn: '埃及', nameEn: 'Egypt', i18n: 'dictionary.system.country.EG' },
  { label: '尼日利亚', value: 'NG', flag: '🇳🇬', phoneCode: '+234', code: 'NG', nameCn: '尼日利亚', nameEn: 'Nigeria', i18n: 'dictionary.system.country.NG' },
  { label: '肯尼亚', value: 'KE', flag: '🇰🇪', phoneCode: '+254', code: 'KE', nameCn: '肯尼亚', nameEn: 'Kenya', i18n: 'dictionary.system.country.KE' },
  { label: '埃塞俄比亚', value: 'ET', flag: '🇪🇹', phoneCode: '+251', code: 'ET', nameCn: '埃塞俄比亚', nameEn: 'Ethiopia', i18n: 'dictionary.system.country.ET' },
  { label: '摩洛哥', value: 'MA', flag: '🇲🇦', phoneCode: '+212', code: 'MA', nameCn: '摩洛哥', nameEn: 'Morocco', i18n: 'dictionary.system.country.MA' },
] as CountryDictionary[]
