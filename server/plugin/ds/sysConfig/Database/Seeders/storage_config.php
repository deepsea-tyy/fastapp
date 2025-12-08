<?php

declare(strict_types=1);

use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class StorageConfig extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        echo '开始填充存储配置数据' . \PHP_EOL;

        // 插入配置组
        $groupExists = Db::table('system_config_group')->where('code', 'sys_storage')->exists();
        if (!$groupExists) {
            Db::table('system_config_group')->insert([
                'name' => '[{"lang": "zh_CN", "text": "存储设置"}]',
                'code' => 'sys_storage',
                'icon' => 'ri:folder-history-fill',
                'created_by' => 1,
                'updated_by' => null,
                'remark' => null,
                'created_at' => '2025-11-25 05:46:49',
                'updated_at' => '2025-11-25 05:46:49',
            ]);
        }

        // 插入配置项
        $configs = [
            ['sys_storage', 'storage_mode', '"local"', '[{"lang": "zh_CN", "text": "存储方式"}]', 'select', '[{"label": "本地", "value": "local"}, {"label": "七牛云", "value": "qiniu"}, {"label": "阿里云", "value": "oss"}, {"label": "腾讯云", "value": "cos"}]', 100, '2025-11-25 05:48:18', '2025-11-25 05:50:18'],
            ['sys_storage', 'oss_access_id', null, '[{"lang": "zh_CN", "text": "阿里云_access_id"}]', 'input', '[]', 99, '2025-11-25 06:40:43', '2025-11-25 06:40:43'],
            ['sys_storage', 'oss_access_secret', null, '[{"lang": "zh_CN", "text": "阿里云access_secret"}]', 'input', '[]', 98, '2025-11-25 06:41:37', '2025-11-25 06:41:37'],
            ['sys_storage', 'oss_bucket', null, '[{"lang": "zh_CN", "text": "阿里云bucket"}]', 'input', '[]', 97, '2025-11-25 06:41:55', '2025-11-25 06:41:55'],
            ['sys_storage', 'oss_endpoint', null, '[{"lang": "zh_CN", "text": "阿里云endpoint"}]', 'input', '[]', 96, '2025-11-25 06:42:11', '2025-11-25 06:42:11'],
            ['sys_storage', 'oss_domain', null, '[{"lang": "zh_CN", "text": "阿里云domain"}]', 'input', '[]', 95, '2025-11-25 06:42:27', '2025-11-25 06:42:27'],
            ['sys_storage', 'qiniu_access_key', null, '[{"lang": "zh_CN", "text": "七牛access_key"}]', 'input', '[]', 89, '2025-11-25 06:52:42', '2025-11-25 06:52:42'],
            ['sys_storage', 'qiniu_secret_key', null, '[{"lang": "zh_CN", "text": "七牛secret_key"}]', 'input', '[]', 88, '2025-11-25 06:53:33', '2025-11-25 06:53:33'],
            ['sys_storage', 'qiniu_bucket', null, '[{"lang": "zh_CN", "text": "七牛bucket"}]', 'input', '[]', 87, '2025-11-25 06:53:45', '2025-11-25 06:53:45'],
            ['sys_storage', 'qiniu_domain', null, '[{"lang": "zh_CN", "text": "七牛domain"}]', 'input', '[]', 86, '2025-11-25 06:53:58', '2025-11-25 06:53:58'],
            ['sys_storage', 'cos_app_id', null, '[{"lang": "zh_CN", "text": "腾讯云app_id"}]', 'input', '[]', 79, '2025-11-25 06:54:54', '2025-11-25 06:54:54'],
            ['sys_storage', 'cos_secret_id', null, '[{"lang": "zh_CN", "text": "腾讯云secret_id"}]', 'input', '[]', 78, '2025-11-25 06:55:07', '2025-11-25 06:55:07'],
            ['sys_storage', 'cos_secret_key', null, '[{"lang": "zh_CN", "text": "腾讯云secret_key"}]', 'input', '[]', 77, '2025-11-25 06:55:23', '2025-11-25 06:55:23'],
            ['sys_storage', 'cos_bucket', null, '[{"lang": "zh_CN", "text": "腾讯云bucket"}]', 'input', '[]', 76, '2025-11-25 06:55:36', '2025-11-25 06:55:36'],
            ['sys_storage', 'cos_domain', null, '[{"lang": "zh_CN", "text": "腾讯云domain"}]', 'input', '[]', 75, '2025-11-25 06:55:47', '2025-11-25 06:55:47'],
            ['sys_storage', 'cos_region', null, '[{"lang": "zh_CN", "text": "腾讯云region"}]', 'input', '[]', 74, '2025-11-25 06:56:05', '2025-11-25 06:56:05'],
        ];

        foreach ($configs as $config) {
            $exists = Db::table('system_config')
                ->where('group_code', $config[0])
                ->where('key', $config[1])
                ->exists();

            if (!$exists) {
                Db::table('system_config')->insert([
                    'group_code' => $config[0],
                    'key' => $config[1],
                    'value' => $config[2],
                    'name' => $config[3],
                    'input_type' => $config[4],
                    'config_select_data' => $config[5],
                    'sort' => $config[6],
                    'remark' => null,
                    'created_by' => 1,
                    'updated_by' => null,
                    'created_at' => $config[7],
                    'updated_at' => $config[8],
                ]);
            }
        }

        echo '存储配置数据填充完成' . \PHP_EOL;
    }
}

