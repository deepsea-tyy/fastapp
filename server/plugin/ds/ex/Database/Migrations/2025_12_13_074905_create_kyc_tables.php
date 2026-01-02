<?php

declare(strict_types=1);

use Hyperf\Database\Migrations\Migration;
use Hyperf\Database\Schema\Blueprint;
use Hyperf\Database\Schema\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ex_kyc', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('KYC认证申请表');

            // 主键和基础信息
            $table->bigIncrements('id')->comment('主键ID');
            $table->unsignedBigInteger('user_id')->comment('用户ID');

            // 认证等级
            $table->unsignedTinyInteger('kyc_level')->default(1)->comment('认证等级：1=标准认证,2=进阶认证(KYC)');

            // 个人信息
            $table->string('country_code', 10)->nullable()->comment('国家/地区代码（ISO 3166-1 alpha-2）');
            $table->string('surname', 50)->nullable()->comment('姓');
            $table->string('middle_name', 50)->nullable()->comment('中间名');
            $table->string('name', 50)->nullable()->comment('名字');
            $table->unsignedTinyInteger('gender')->nullable()->comment('性别：1=男,2=女,3=其他');
            $table->date('birthday')->nullable()->comment('出生日期');
            $table->string('id_type', 20)->nullable()->comment('证件类型：ID_CARD=身份证,PASSPORT=护照,DRIVING_LICENSE=驾驶证,OTHER=其他');
            $table->string('id_number', 50)->nullable()->comment('身份证件号码（加密存储）');
            $table->string('id_number_hash', 64)->nullable()->comment('身份证件号码哈希（用于去重）');
            $table->date('id_issue_date')->nullable()->comment('证件签发日期');
            $table->date('id_expiry_date')->nullable()->comment('证件有效期');

            $table->string('address', 500)->nullable()->comment('地址信息');
            $table->decimal('latitude', 10, 7)->nullable()->comment('GPS纬度');
            $table->decimal('longitude', 10, 7)->nullable()->comment('GPS经度');
            $table->decimal('location_accuracy')->nullable()->comment('定位精度（米）');
            $table->timestamp('location_time')->nullable()->comment('定位时间');
            $table->string('location_address', 500)->nullable()->comment('GPS反地理编码地址（根据经纬度获取的地址）');

            // 证件照片
            $table->string('id_front_image', 500)->nullable()->comment('证件正面照片URL');
            $table->string('id_back_image', 500)->nullable()->comment('证件背面照片URL');
            $table->string('id_selfie_image', 500)->nullable()->comment('手持证件自拍照片URL');
            $table->string('address_proof_image', 500)->nullable()->comment('地址证明照片URL');

            // 审核信息
            $table->unsignedTinyInteger('status')->default(0)->comment('审核状态：0=待审核,1=已通过,2=已拒绝,3=已取消');

            // OCR识别结果
            $table->json('ocr_result')->nullable()->comment('OCR识别结果：{"id_number":"","name":"","birthday":"","address":"",...}');
            $table->decimal('ocr_confidence')->nullable()->comment('OCR识别置信度（0-100）');
            $table->string('remark')->nullable()->comment('备注,拒绝原因');

            $table->timestamps();

            // 索引
            $table->unique(['user_id', 'kyc_level']);
            $table->index('user_id');
            $table->index('status');
            $table->index('id_number_hash');
        });

        Schema::create('ex_kyc_review_log', static function (Blueprint $table) {
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
            $table->comment('KYC审核日志表');

            // 主键和基础信息
            $table->bigIncrements('id')->comment('主键ID');
            $table->unsignedBigInteger('kyc_id')->comment('申请ID');
            $table->unsignedBigInteger('user_id')->comment('用户ID');
            $table->string('action', 50)->comment('操作类型：AUTO_REVIEW=自动审核,MANUAL_REVIEW=人工审核,APPROVE=通过,REJECT=拒绝,CANCEL=取消');
            $table->unsignedBigInteger('operator_id')->nullable()->comment('操作人ID');
            $table->string('operator_type', 20)->nullable()->comment('操作人类型：SYSTEM=系统,ADMIN=管理员');
            $table->unsignedTinyInteger('before_status')->nullable()->comment('操作前状态');
            $table->unsignedTinyInteger('after_status')->nullable()->comment('操作后状态（即当前状态）');
            $table->text('remark')->nullable()->comment('操作备注');
            $table->string('ip_address', 45)->nullable()->comment('操作IP地址');
            $table->string('user_agent', 500)->nullable()->comment('用户代理');
            $table->timestamp('created_at')->nullable();

            // 索引
            $table->index('kyc_id');
            $table->index('user_id');
            $table->index('action');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ex_kyc_review_log');
        Schema::dropIfExists('ex_kyc');
    }
};

