#!/bin/bash

echo "=== 检查 Docker 当前配置 ==="

echo "1. 查看当前 daemon.json 文件内容："
if [ -f /etc/docker/daemon.json ]; then
    cat /etc/docker/daemon.json
else
    echo "未找到 /etc/docker/daemon.json 文件"
fi

echo ""
echo "2. 查看 Docker 服务实际使用的配置："
echo "Docker 信息："
docker info 2>/dev/null | grep -E "(Registry Mirrors|Insecure Registries|Logging Driver|Storage Driver)" || echo "无法获取 Docker 信息"

echo ""
echo "3. 检查 Docker 进程启动参数："
ps aux | grep dockerd | grep -v grep

echo ""
echo "4. 查看 Docker 服务状态："
sudo systemctl status docker --no-pager -l

echo ""
echo "5. 测试镜像源配置："
echo "尝试拉取测试镜像..."
docker pull hello-world 2>&1 | head -5

echo ""
echo "6. 检查 Harbor 连接："
echo "尝试连接到 Harbor 仓库..."
curl -k -I http://118.178.189.219:8080/v2/ 2>/dev/null | head -3 || echo "无法连接到 Harbor"

echo "=== 检查完成 ===" 