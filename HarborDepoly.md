# Harbor私有化部署流程
## 环境准备（初次部署）
```bash
# 安装 Docker（阿里云镜像加速）
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
sudo systemctl start docker && sudo systemctl enable docker

# 安装 Docker Compose（离线包需手动下载）
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version  # 验证安装
```

## Harbor私有化部署

- 下载离线安装包
```bash
# 从 GitHub 下载最新版离线包（约 500MB）
wget https://github.com/goharbor/harbor/releases/download/v2.8.2/harbor-offline-installer-v2.8.2.tgz
tar -zxvf harbor-offline-installer-v2.8.2.tgz
cd harbor
```

- 配置 harbor.yml

```bash
hostname: your-server-ip  # 阿里云ECS的公网IP或内网IP（如 172.16.10.100）
http:
  port: 8080  # 避免与默认80端口冲突（外网访问需开放安全组）

harbor_admin_password: YourStrongPassword  # 管理员密码
data_volume: /data/harbor  # 确保磁盘空间足够
```
> 注意：若仅内网使用，可关闭 HTTPS（注释 https 相关配置）

- 执行安装脚本
```bash
sudo ./install.sh  # 自动加载镜像并启动服务
# 验证服务状态
docker ps  # 检查所有容器是否运行正常（STATUS 为 healthy）
```
- 配置 Docker 客户端
```bash
# 在客户端机器上配置信任 Harbor（需替换 your-server-ip）
sudo tee /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["your-server-ip:8080"]
}
EOF
sudo systemctl restart docker
```
> 注意：restart docker会关闭所有在跑的容器