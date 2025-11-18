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
        Schema::create('user', static function (Blueprint $table) {
            $table->comment('账户表');
            $table->bigIncrements('id')->comment('ID');
            $table->string('username', 20)->nullable()->comment('用户名');
            $table->string('email', 50)->nullable()->comment('用户邮箱');
            $table->smallInteger('code')->nullable()->comment('手机code');
            $table->string('mobile', 11)->nullable()->comment('手机');
            $table->string('password', 100)->comment('密码');
            $table->string('user_type', 3)->default('100')->comment('用户类型:100=系统用户,200=普通用户,300=通用账户');
            $table->tinyInteger('status')->default(1)->comment('状态:1=正常,2=停用');
            $table->string('google2fa', 50)->comment('google2fa');
            $table->string('remark', 255)->default('')->comment('备注');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->unique('username');
            $table->unique('email');
            $table->unique(['mobile', 'code']);
            $table->index('user_type');
            $table->index('status');
        });
        Schema::create('user_admin_setting', static function (Blueprint $table) {
            $table->comment('管理员信息表');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户ID');
            $table->string('phone')->nullable()->comment('联系电话');
            $table->json('dept_id')->unsigned()->nullable()->comment('部门ID');
            $table->json('backend_setting')->nullable()->comment('后台设置数据');
            $table->unique('user_id');
            $table->index('dept_id', 'idx_dept_id');
        });
        Schema::create('user_admin_login_log', static function (Blueprint $table) {
            $table->comment('登录日志表');
            $table->bigIncrements('id')->comment('主键');
            $table->addColumn('string', 'username', ['length' => 20, 'comment' => '用户名']);
            $table->addColumn('ipAddress', 'ip', ['comment' => '登录IP地址'])->nullable();
            $table->addColumn('string', 'os', ['length' => 255, 'comment' => '操作系统'])->nullable();
            $table->addColumn('string', 'browser', ['length' => 255, 'comment' => '浏览器'])->nullable();
            $table->addColumn('smallInteger', 'status', ['default' => 1, 'comment' => '登录状态 (1成功 2失败)']);
            $table->addColumn('string', 'message', ['length' => 50, 'comment' => '提示消息'])->nullable();
            $table->dateTime('login_time')->comment('登录时间');
            $table->addColumn('string', 'remark', ['length' => 255, 'comment' => '备注'])->nullable();
            $table->index('username');
        });
        Schema::create('user_admin_operation_log', static function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->comment('操作日志表');
            $table->addColumn('string', 'username', ['length' => 20, 'comment' => '用户名']);
            $table->addColumn('string', 'method', ['length' => 20, 'comment' => '请求方式']);
            $table->addColumn('string', 'router', ['length' => 500, 'comment' => '请求路由']);
            $table->addColumn('string', 'service_name', ['length' => 30, 'comment' => '业务名称']);
            $table->addColumn('ipAddress', 'ip', ['comment' => '请求IP地址'])->nullable();
            $table->addColumn('timestamp', 'created_at', ['precision' => 0, 'comment' => '创建时间'])->nullable();
            $table->addColumn('timestamp', 'updated_at', ['precision' => 0, 'comment' => '更新时间'])->nullable();
            $table->addColumn('string', 'remark', ['length' => 255, 'comment' => '备注'])->nullable();
            $table->index('username');
        });
        Schema::create('user_profile', static function (Blueprint $table) {
            $table->comment('用户信息表');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户ID');
            $table->string('nickname', 30)->default('')->comment('用户昵称');
            $table->string('avatar', 255)->nullable()->comment('用户头像');
            $table->string('signed', 255)->nullable()->comment('个人签名');
            $table->string('lang', 8)->nullable()->comment('言语');
            $table->string('trans_password', 50)->comment('交易密码');
            $table->unique('user_id');
            $table->timestamps();
        });
        Schema::create('user_login_log', static function (Blueprint $table) {
            $table->comment('用户登录日志');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户id');
            $table->ipAddress('ip');
            $table->string('device')->comment('设备');
            $table->string('country_code', 64)->nullable()->comment('国家代码');
            $table->string('country', 64)->nullable()->comment('国家');
            $table->string('region', 64)->nullable()->comment('省');
            $table->string('city', 64)->nullable()->comment('市');
            $table->timestamp('created_at')->nullable();
            $table->index('user_id');
        });
        Schema::create('rules', static function (Blueprint $table) {
            $table->comment('Casbin权限规则表');
            $table->bigIncrements('id');
            $table->string('ptype')->nullable()->comment('策略类型（p=策略，g=角色继承）');
            $table->string('v0')->nullable()->comment('规则参数0');
            $table->string('v1')->nullable()->comment('规则参数1');
            $table->string('v2')->nullable()->comment('规则参数2');
            $table->string('v3')->nullable()->comment('规则参数3');
            $table->string('v4')->nullable()->comment('规则参数4');
            $table->string('v5')->nullable()->comment('规则参数5');
            $table->timestamps();
        });
        Schema::create('menu', static function (Blueprint $table) {
            $table->comment('菜单信息表');
            $table->bigIncrements('id')->comment('主键');
            $table->bigInteger('parent_id')->unsigned()->comment('父ID');
            $table->string('name', 50)->default('')->comment('菜单名称')->unique();
            $table->json('meta')->comment('附加属性')->nullable();
            $table->string('path', 60)->default('')->comment('路径');
            $table->string('component', 150)->default('')->comment('组件路径');
            $table->string('redirect', 100)->comment('重定向地址')->default('');
            $table->tinyInteger('status')->comment('状态:1=正常,2=停用')->default(1);
            $table->smallInteger('sort')->comment('排序')->default(0);
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->string('remark', 60)->comment('备注')->default('');
        });
        Schema::create('role', static function (Blueprint $table) {
            $table->comment('角色信息表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('name', 30)->comment('角色名称');
            $table->string('code', 100)->comment('角色代码')->unique();
            $table->tinyInteger('data_scope')->default(5)->comment('数据范围（1：全部数据权限 2：自定义数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：本人数据权限）');
            $table->tinyInteger('status')->comment('状态:1=正常,2=停用')->default(1);
            $table->smallInteger('sort')->comment('排序')->default(0);
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->string('remark')->comment('备注')->default('');
        });
        Schema::create('attachment', static function (Blueprint $table) {
            $table->comment('上传文件信息表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('storage_mode', 20)->comment('存储模式:local=本地,oss=阿里云,qiniu=七牛云,cos=腾讯云')->default('local');
            $table->string('origin_name', 255)->comment('原文件名')->nullable();
            $table->string('object_name', 50)->comment('新文件名')->nullable();
            $table->string('hash', 64)->comment('文件hash')->nullable();
            $table->string('mime_type', 255)->comment('资源类型')->nullable();
            $table->string('suffix', 20)->comment('文件后缀')->nullable();
            $table->bigInteger('size_byte')->comment('字节数')->nullable();
            $table->string('size_info', 50)->comment('文件大小')->nullable();
            $table->string('url', 255)->comment('url地址')->nullable();
            $table->string('target', 32)->comment('使用标记')->nullable();
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->string('remark')->comment('备注')->default('');
            $table->index('storage_path');
            $table->unique('hash');
        });
        Schema::create('user_belongs_role', static function (Blueprint $table) {
            $table->comment('用户角色关联表');
            $table->bigIncrements('id');
            $table->bigInteger('user_id')->comment('用户id');
            $table->bigInteger('role_id')->comment('角色id');
            // 索引优化：联合索引用于查询，单独索引用于反向查询
            $table->unique(['user_id', 'role_id'], 'uk_user_role');
            $table->index('user_id', 'idx_user_id');
            $table->index('role_id', 'idx_role_id');
        });
        Schema::create('role_belongs_menu', static function (Blueprint $table) {
            $table->comment('角色菜单关联表');
            $table->bigIncrements('id');
            $table->bigInteger('role_id')->comment('角色id');
            $table->bigInteger('menu_id')->comment('菜单id');
            // 索引优化：联合索引用于查询，单独索引用于反向查询
            $table->unique(['role_id', 'menu_id'], 'uk_role_menu');
            $table->index('role_id', 'idx_role_id');
            $table->index('menu_id', 'idx_menu_id');
        });
        Schema::create('department', static function (Blueprint $table) {
            $table->comment('部门表');
            $table->bigIncrements('id')->comment('主键');
            $table->string('name', 50)->comment('部门名称');
            $table->string('code', 50)->nullable()->comment('部门代码')->unique();
            $table->bigInteger('parent_id')->unsigned()->default(0)->comment('父部门ID');
            $table->smallInteger('sort')->default(0)->comment('排序');
            $table->tinyInteger('status')->default(1)->comment('状态:1=正常,2=停用');
            $table->bigInteger('created_by')->unsigned()->nullable()->comment('创建者');
            $table->bigInteger('updated_by')->unsigned()->nullable()->comment('更新者');
            $table->timestamps();
            $table->string('remark', 255)->default('')->comment('备注');
            $table->index('parent_id');
        });
        Schema::create('role_belongs_department', static function (Blueprint $table) {
            $table->comment('角色部门关联表（用于自定义数据权限）');
            $table->bigIncrements('id');
            $table->bigInteger('role_id')->comment('角色id');
            $table->bigInteger('dept_id')->comment('部门id');
            $table->timestamps();
            $table->index('role_id', 'idx_role_id');
            $table->index('dept_id', 'idx_department_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user');
        Schema::dropIfExists('user_admin_setting');
        Schema::dropIfExists('user_admin_login_log');
        Schema::dropIfExists('user_admin_operation_log');
        Schema::dropIfExists('user_profile');
        Schema::dropIfExists('user_login_log');
        Schema::dropIfExists('rules');
        Schema::dropIfExists('menu');
        Schema::dropIfExists('role');
        Schema::dropIfExists('attachment');
        Schema::dropIfExists('user_belongs_role');
        Schema::dropIfExists('role_belongs_menu');
        Schema::dropIfExists('role_belongs_department');
        Schema::dropIfExists('department');
    }
};
