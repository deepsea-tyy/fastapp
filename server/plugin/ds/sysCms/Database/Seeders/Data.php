<?php
/**
 * FastApp.
 * 12/26/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

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
            ['code' => 'feed_config', 'name' => '[{"lang": "zh_CN", "text": "信息流配置"}, {"lang": "en", "text": "Information flow configuration"}]', 'icon' => 'ri:message-2-fill'],
        ];
        foreach ($group as $item) {
            $groupExists = Db::table('system_config_group')->where('code', $item['code'])->exists();
            if (!$groupExists) {
                Db::table('system_config_group')->insert($item);
            }
        }

        // 插入配置项
        $configs = [
            //信息流
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
            Db::unprepared("INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(1, '[{\"lang\": \"zh_CN\", \"text\": \"公告\"}, {\"lang\": \"en\", \"text\": \"Notice\"}]', '', 100, 0, 1, NULL, 'notice', 1, NULL, '2025-12-17 09:10:52', '2025-12-17 09:10:52');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(2, '[{\"lang\": \"zh_CN\", \"text\": \"新闻\"}, {\"lang\": \"en\", \"text\": \"News\"}]', '', 100, 0, 1, NULL, 'news', 1, NULL, '2025-12-17 09:11:15', '2025-12-17 09:11:15');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(3, '[{\"lang\": \"zh_CN\", \"text\": \"帮助手册 1\"}, {\"lang\": \"en\", \"text\": \"help2\"}]', '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:20', '2025-12-17 09:30:17');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(4, '[{\"lang\": \"zh_CN\", \"text\": \"帮助手册 2\"}, {\"lang\": \"en\", \"text\": \"help2\"}]', '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:30', '2025-12-17 09:30:07');");
        }

        echo '存储配置数据填充完成' . \PHP_EOL;
    }
}

