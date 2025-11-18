#!/bin/bash

REPO_PATH=""
echo $REPO_PATH
cd $REPO_PATH || exit
ps -ef | grep -v grep | grep php | awk '{print $2}'|xargs -r kill -9
sleep 1
rm -rf runtime/container
nohup ./swoole-cli -d swoole.use_shortname='Off' bin/hyperf.php start >/dev/null 2>&1 &
echo "===服务已启动==="