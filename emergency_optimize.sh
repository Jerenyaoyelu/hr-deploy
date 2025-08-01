#!/bin/bash

echo "=== 紧急系统优化脚本 ==="

# 1. 添加2GB Swap空间
echo "1. 添加2GB Swap空间..."
if ! swapon --show | grep -q "/swapfile"; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap空间添加完成"
else
    echo "Swap空间已存在"
fi

# 2. 清理Docker资源
echo "2. 清理Docker资源..."
docker system prune -f
docker image prune -f

# 3. 清理Docker日志文件
echo "3. 清理Docker日志文件..."
sudo find /var/lib/docker/containers/ -name "*-json.log" -exec truncate -s 0 {} \;
echo "Docker日志文件已清理"

# 4. 限制Docker日志大小（仅显示建议，不修改配置）
echo "4. Docker日志优化建议..."
echo "当前Docker日志配置："
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json
else
    echo "未找到daemon.json配置文件"
fi
echo ""
echo "建议：如需限制Docker日志大小，请手动修改 /etc/docker/daemon.json"
echo "添加以下配置："
echo '  "log-driver": "json-file",'
echo '  "log-opts": {'
echo '    "max-size": "10m",'
echo '    "max-file": "2"'
echo '  }'

# 5. 清理系统缓存
echo "5. 清理系统缓存..."
sudo sync
sudo echo 3 > /proc/sys/vm/drop_caches

# 6. 优化内存管理参数
echo "6. 优化内存管理参数..."
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF

# 内存优化
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5

# 网络优化
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF

sudo sysctl -p

# 7. 检查优化结果
echo "7. 检查优化结果..."
echo "内存使用情况:"
free -h
echo ""
echo "系统负载:"
uptime
echo ""
echo "Docker容器状态:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Docker资源使用统计:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo ""
echo "系统进程内存使用(前5名):"
ps aux --sort=-%mem | head -6
echo ""
echo "网络连接状态:"
netstat -tulpn | grep -E ':(80|3000|8000|9000|3306)' | head -5
echo ""
echo "系统负载历史:"
cat /proc/loadavg
echo ""
echo "可用内存百分比:"
echo "可用内存: $(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')"

echo "=== 紧急优化完成 ===" 