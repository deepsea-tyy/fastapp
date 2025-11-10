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
        if (! Schema::hasTable('system_config_group')) {
            Schema::create('system_config_group', static function (Blueprint $table) {
                $table->bigIncrements('id')->comment('主键');
                $table->json('name')->comment('配置组名称');
                $table->string('code', 64)->comment('配置组标识');
                $table->string('icon', 128)->nullable()->comment('配置组图标');
                $table->bigInteger('created_by')->nullable()->comment('创建者');
                $table->bigInteger('updated_by')->nullable()->comment('更新者');
                $table->string('remark', 255)->nullable()->comment('备注');
                $table->timestamps();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('system_config_group');
    }
};
