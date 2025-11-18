#!/bin/bash

# 停止 Hyperf 服务

PID_FILE="runtime/hyperf.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "正在停止 Hyperf 服务 (PID: $PID)..."
        kill -15 "$PID"
        sleep 2
        
        # 检查是否还在运行
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "强制停止服务..."
            kill -9 "$PID"
        fi
        
        rm -f "$PID_FILE"
        echo "服务已停止"
    else
        echo "进程不存在，清理 PID 文件"
        rm -f "$PID_FILE"
    fi
else
    echo "PID 文件不存在，尝试查找并停止相关进程..."
    pkill -f "bin/hyperf.php start" || echo "未找到运行中的服务"
fi

