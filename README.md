# hr-deploy

本仓库用于集中管理和记录后端各微服务（如hr_backend、hr-pay等）的部署相关文件，包括：
- docker-compose.yml
- nginx 配置
- 各环境变量文件（.env）
- 自动化脚本（如一键部署、备份等）

请勿将业务代码放入本仓库，仅用于部署和运维相关内容。

---

## 常用运维命令

### 1. 启动/更新所有服务
```bash
cd /opt/hr-deploy  # 进入部署目录
git pull           # 拉取最新部署配置
docker-compose pull         # 拉取所有服务最新镜像
docker-compose up -d       # 启动或更新所有服务
```

### 2. 只更新/重启某个服务（如 hr-pay）
```bash
docker-compose pull hr-pay      # 只拉取 hr-pay 服务镜像
docker-compose up -d hr-pay    # 只启动/重启 hr-pay 服务
```

### 3. 其他常用命令
- 查看服务日志：
  ```bash
  docker-compose logs -f hr-pay
  ```
- 停止服务：
  ```bash
  docker-compose stop hr-pay
  ```
- 启动服务：
  ```bash
  docker-compose start hr-pay
  ```
- 重启服务：
  ```bash
  docker-compose restart hr-pay
  ```

---

如需添加新服务、调整配置，修改本仓库后在服务器同步即可。 