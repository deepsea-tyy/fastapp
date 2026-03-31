SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 自 PHP databases/migrations/2025_12_23_000001_search.php

CREATE TABLE `{{prefix}}search_keyword` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `keyword` varchar(32) NOT NULL COMMENT '搜索关键词',
  `hit_count` int unsigned NOT NULL DEFAULT '1' COMMENT '命中次数',
  `icon` varchar(64) DEFAULT NULL COMMENT '图标名称',
  `color` varchar(20) DEFAULT NULL COMMENT '图标颜色(十六进制)',
  `source` tinyint NOT NULL DEFAULT '1' COMMENT '来源:1=用户搜索,2=热门推荐,3=系统推荐',
  `sort` int unsigned NOT NULL DEFAULT '0' COMMENT '排序(数字越大越靠前)',
  `last_searched_at` timestamp NULL DEFAULT NULL COMMENT '最后搜索时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `search_keyword_keyword_unique` (`keyword`),
  KEY `search_keyword_hit_count_index` (`hit_count`),
  KEY `search_keyword_sort_index` (`sort`),
  KEY `search_keyword_last_searched_at_index` (`last_searched_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='搜索关键词记录表';

CREATE TABLE `{{prefix}}search_index` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `target_type` varchar(50) NOT NULL COMMENT '内容类型: feed(短贴)|feed_article(标题贴)|article(普通文章)|notice(公告)|news(新闻)',
  `target_id` bigint unsigned NOT NULL COMMENT '内容ID',
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` varchar(100) DEFAULT NULL COMMENT '内容',
  `keyword` json DEFAULT NULL COMMENT '关键词数组',
  `tags` json DEFAULT NULL COMMENT '标签数组',
  `weight` int unsigned NOT NULL DEFAULT '0' COMMENT '权重',
  `click_count` int unsigned NOT NULL DEFAULT '0' COMMENT '点击量',
  `last_at` timestamp NULL DEFAULT NULL COMMENT '最新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `search_index_target_type_target_id_unique` (`target_type`,`target_id`),
  KEY `search_index_last_at_index` (`last_at`),
  KEY `search_index_click_count_index` (`click_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='搜索索引表';

SET FOREIGN_KEY_CHECKS = 1;
