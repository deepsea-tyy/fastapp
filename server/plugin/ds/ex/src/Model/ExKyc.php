<?php

declare(strict_types=1);

namespace Plugin\Ds\Ex\Model;

use Hyperf\DbConnection\Model\Model;

/**
 * KYC认证申请表模型
 *
 * @property int $user_id 用户ID
 * @property int $kyc_level 认证等级：1=标准认证,2=进阶认证(KYC)
 * @property string $country_code 国家/地区代码（ISO 3166-1 alpha-2）
 * @property string $surname 姓
 * @property string $middle_name 中间名
 * @property string $name 名字
 * @property int $gender 性别：1=男,2=女,3=其他
 * @property \Carbon\Carbon $birthday 出生日期
 * @property string $id_type 证件类型：ID_CARD=身份证,PASSPORT=护照,DRIVING_LICENSE=驾驶证,OTHER=其他
 * @property string $id_number 身份证件号码（加密存储）
 * @property string $id_number_hash 身份证件号码哈希（用于去重）
 * @property \Carbon\Carbon $id_issue_date 证件签发日期
 * @property \Carbon\Carbon $id_expiry_date 证件有效期
 * @property string $address 地址信息
 * @property float $latitude GPS纬度
 * @property float $longitude GPS经度
 * @property float $location_accuracy 定位精度（米）
 * @property \Carbon\Carbon $location_time 定位时间
 * @property string $location_address GPS反地理编码地址（根据经纬度获取的地址）
 * @property string $id_front_image 证件正面照片URL
 * @property string $id_back_image 证件背面照片URL
 * @property string $id_selfie_image 手持证件自拍照片URL
 * @property string $address_proof_image 地址证明照片URL
 * @property int $status 审核状态：0=待审核,1=已通过,2=已拒绝,3=已取消
 * @property array $ocr_result OCR识别结果：{&quot;id_number&quot;:&quot;&quot;,&quot;name&quot;:&quot;&quot;,&quot;birthday&quot;:&quot;&quot;,&quot;address&quot;:&quot;&quot;,...}
 * @property float $ocr_confidence OCR识别置信度（0-100）
 * @property string $remark 备注,拒绝原因
 * @property \Carbon\Carbon $created_at 创建时间
 * @property \Carbon\Carbon $updated_at 更新时间
 */
class ExKyc extends Model
{
    protected ?string $table = 'ex_kyc';

    protected array $fillable = [
        'user_id',
        'kyc_level',
        'country_code',
        'surname',
        'middle_name',
        'name',
        'gender',
        'birthday',
        'id_type',
        'id_number',
        'id_number_hash',
        'id_issue_date',
        'id_expiry_date',
        'address',
        'latitude',
        'longitude',
        'location_accuracy',
        'location_time',
        'location_address',
        'id_front_image',
        'id_back_image',
        'id_selfie_image',
        'address_proof_image',
        'status',
        'ocr_result',
        'ocr_confidence',
        'remark',
        'created_at',
        'updated_at',
    ];

    protected array $casts = [
        'user_id' => 'integer',
        'kyc_level' => 'integer',
        'country_code' => 'string',
        'surname' => 'string',
        'middle_name' => 'string',
        'name' => 'string',
        'gender' => 'integer',
        'birthday' => 'date',
        'id_type' => 'string',
        'id_number' => 'string',
        'id_number_hash' => 'string',
        'id_issue_date' => 'date',
        'id_expiry_date' => 'date',
        'address' => 'string',
        'latitude' => 'decimal:2',
        'longitude' => 'decimal:2',
        'location_accuracy' => 'decimal:2',
        'location_time' => 'datetime',
        'location_address' => 'string',
        'id_front_image' => 'string',
        'id_back_image' => 'string',
        'id_selfie_image' => 'string',
        'address_proof_image' => 'string',
        'status' => 'integer',
        'ocr_result' => 'array',
        'ocr_confidence' => 'decimal:2',
        'remark' => 'string',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
    protected array $hidden = [];


    public function isKyc(): int
    {
        //1标准认证审核中 2标准认证完成 3标准认证未通过 4进阶认证审核中 5进阶认证完成 6进阶认证未通过
        if ($this->kyc_level == 2) return $this->status == 2 ? 6 : ($this->status ? 5 : 4);
        return $this->status == 2 ? 3 : ($this->status ? 2 : 1);
    }
}
