#!/bin/bash

# 清理运行时容器
rm -rf runtime/container
# shellcheck disable=SC2046
kill -9 $(lsof -t -i:9501) 2>/dev/null
# shellcheck disable=SC2046
kill -9 $(lsof -t -i:9502) 2>/dev/null
# 启动开发服务器
php -d swoole.use_shortname='Off' bin/hyperf.php start