<?php
/**
 * FastApp.
 * 12/17/25
 * @Author deepsea
 * @Contact (telegram:deepsea159)
 */

use Hyperf\Database\Seeders\Seeder;
use Hyperf\DbConnection\Db;

class Data extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Db::unprepared("INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(1, '[{\"lang\": \"zh_CN\", \"text\": \"公告\"}, {\"lang\": \"en\", \"text\": \"Notice\"}]', '', 100, 0, 1, NULL, 'notice', 1, NULL, '2025-12-17 09:10:52', '2025-12-17 09:10:52');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(2, '[{\"lang\": \"zh_CN\", \"text\": \"新闻\"}, {\"lang\": \"en\", \"text\": \"News\"}]', '', 100, 0, 1, NULL, 'news', 1, NULL, '2025-12-17 09:11:15', '2025-12-17 09:11:15');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(3, '[{\"lang\": \"zh_CN\", \"text\": \"帮助手册 1\"}, {\"lang\": \"en\", \"text\": \"help2\"}]', '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:20', '2025-12-17 09:30:17');
INSERT INTO category (id, name, icon, sort, parent_id, status, remark, code, created_by, updated_by, created_at, updated_at) VALUES(4, '[{\"lang\": \"zh_CN\", \"text\": \"帮助手册 2\"}, {\"lang\": \"en\", \"text\": \"help2\"}]', '', 100, 0, 1, NULL, 'help_manual', 1, 1, '2025-12-17 09:12:30', '2025-12-17 09:30:07');");
    }
}