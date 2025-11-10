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
        if (!Schema::hasTable('system_config')) {
            Schema::create('system_config', static function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->string('group_code', 64)->nullable()->comment('组code')->index();
                $table->string('key', 32)->unique()->comment('配置键名');
                $table->json('value')->nullable()->comment('配置值');
                $table->json('name')->nullable()->comment('配置名称');
                $table->string('input_type', 32)->nullable()->comment('数据输入类型');
                $table->json('config_select_data')->nullable()->comment('配置选项数据');
                $table->smallInteger('sort', false, true)->default(0)->comment('排序');
                $table->string('remark', 255)->nullable()->comment('备注');
                $table->bigInteger('created_by')->nullable()->comment('创建者');
                $table->bigInteger('updated_by')->nullable()->comment('更新者');
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('system_config');
    }
};
