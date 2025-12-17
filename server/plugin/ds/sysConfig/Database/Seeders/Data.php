<?php

declare(strict_types=1);

use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class Data extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        echo '开始填充存储配置数据' . \PHP_EOL;

        // 插入配置组
        $group = [
            ['code' => 'sys_storage', 'name' => '[{"lang": "zh_CN", "text": "存储设置"}], {"lang": "en", "text": "save setting"}]'],
            ['code' => 'feed_config', 'name' => '[{"lang": "zh_CN", "text": "信息流账户配置"}, {"lang": "en", "text": "Information flow account configuration"}]'],
        ];
        foreach ($group as $item) {
            $groupExists = Db::table('system_config_group')->where('code', $item['code'])->exists();
            if (!$groupExists) {
                Db::table('system_config_group')->insert($item);
            }
        }

        // 插入配置项
        $configs = [
            //存储配置
            ['sys_storage', 'storage_mode', '"local"', '[{"lang": "zh_CN", "text": "存储方式"}]', 'select', '[{"label": "本地", "value": "local"}, {"label": "七牛云", "value": "qiniu"}, {"label": "阿里云", "value": "oss"}, {"label": "腾讯云", "value": "cos"}]', 100],
            ['sys_storage', 'oss_access_id', null, '[{"lang": "zh_CN", "text": "阿里云_access_id"}]', 'input', '[]', 99],
            ['sys_storage', 'oss_access_secret', null, '[{"lang": "zh_CN", "text": "阿里云access_secret"}]', 'input', '[]', 98],
            ['sys_storage', 'oss_bucket', null, '[{"lang": "zh_CN", "text": "阿里云bucket"}]', 'input', '[]', 97],
            ['sys_storage', 'oss_endpoint', null, '[{"lang": "zh_CN", "text": "阿里云endpoint"}]', 'input', '[]', 96],
            ['sys_storage', 'oss_domain', null, '[{"lang": "zh_CN", "text": "阿里云domain"}]', 'input', '[]', 95],
            ['sys_storage', 'qiniu_access_key', null, '[{"lang": "zh_CN", "text": "七牛access_key"}]', 'input', '[]', 89],
            ['sys_storage', 'qiniu_secret_key', null, '[{"lang": "zh_CN", "text": "七牛secret_key"}]', 'input', '[]', 88],
            ['sys_storage', 'qiniu_bucket', null, '[{"lang": "zh_CN", "text": "七牛bucket"}]', 'input', '[]', 87],
            ['sys_storage', 'qiniu_domain', null, '[{"lang": "zh_CN", "text": "七牛domain"}]', 'input', '[]', 86],
            ['sys_storage', 'cos_app_id', null, '[{"lang": "zh_CN", "text": "腾讯云app_id"}]', 'input', '[]', 79],
            ['sys_storage', 'cos_secret_id', null, '[{"lang": "zh_CN", "text": "腾讯云secret_id"}]', 'input', '[]', 78],
            ['sys_storage', 'cos_secret_key', null, '[{"lang": "zh_CN", "text": "腾讯云secret_key"}]', 'input', '[]', 77],
            ['sys_storage', 'cos_bucket', null, '[{"lang": "zh_CN", "text": "腾讯云bucket"}]', 'input', '[]', 76],
            ['sys_storage', 'cos_domain', null, '[{"lang": "zh_CN", "text": "腾讯云domain"}]', 'input', '[]', 75],
            ['sys_storage', 'cos_region', null, '[{"lang": "zh_CN", "text": "腾讯云region"}]', 'input', '[]', 74],
            //信息流配置
            ['feed_config', 'feed_account_new', null, '[{"lang": "zh_CN", "text": "新闻发布账户ID"}, {"lang": "en", "text": "News Release Account ID"}]', 'input', '[]', 99],
            ['feed_config', 'feed_account_notice', null, '[{"lang": "zh_CN", "text": "公告发布账户"}, {"lang": "en", "text": "Announcement Release Account"}]', 'input', '[]', 89],
            ['feed_config', 'feed_account_post', null, '[{"lang": "zh_CN", "text": "帖子发布账户 ID"}, {"lang": "zh_CN", "text": "Post posting account ID"}]', 'input', '[]', 79],
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
                ]);
            }
        }

        echo '存储配置数据填充完成' . \PHP_EOL;
    }
}

