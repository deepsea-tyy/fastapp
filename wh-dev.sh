#!/bin/bash

# 清理运行时容器
rm -rf runtime/container

# 启动开发服务器
php -d swoole.use_shortname='Off' bin/hyperf.php start