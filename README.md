# HR 系统部署配置

## 部署架构

本系统采用单机部署架构，所有服务运行在同一台云服务器上：

```
┌─────────────────┐
│   Nginx (80)    │ ← 反向代理网关
├─────────────────┤
│ Frontend (3000) │ ← Next.js 前端
├─────────────────┤
│ Backend (8000)  │ ← FastAPI 后端
├─────────────────┤
│  Pay (9000)     │ ← 支付服务
├─────────────────┤
│ MySQL (3306)    │ ← 数据库
└─────────────────┘
```

## 环境变量配置

创建 `.env` 文件并配置以下环境变量：

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=your_mysql_root_password
MYSQL_DATABASE=hr_db
DATABASE_URL=mysql+pymysql://root:your_mysql_root_password@localhost:3306/hr_db

# 镜像标签
BACKTEND_TAG=latest
FRONTEND_TAG=latest
```

## 服务说明

### 1. 前端服务 (frontend)
- **端口**: 3000 (外部可访问)
- **镜像**: `118.178.189.219:8080/hr-assist/hr-assistant-front:${FRONTEND_TAG}`
- **功能**: Next.js 前端应用
- **访问**: http://your-server-ip:3000

### 2. 后端服务 (hr-backend)
- **端口**: 8000 (外部可访问)
- **镜像**: `118.178.189.219:8080/hr-assist/hr-backend:${BACKTEND_TAG}`
- **功能**: FastAPI 后端服务
- **API 路径**: `/api/v1/*`
- **访问**: http://your-server-ip:8000

### 3. 支付服务 (hr-pay)
- **端口**: 9000 (外部可访问)
- **镜像**: `118.178.189.219:8080/hr-assist/hr-pay:latest`
- **功能**: 支付相关服务
- **API 路径**: `/api/pay/*`
- **访问**: http://your-server-ip:9000

### 4. 数据库服务 (mysql)
- **端口**: 3306 (外部可访问)
- **镜像**: `mysql:8.0`
- **功能**: MySQL 数据库
- **访问**: localhost:3306

### 5. 网关服务 (nginx)
- **端口**: 80 (外部可访问)
- **镜像**: `nginx:latest`
- **功能**: 反向代理和负载均衡
- **访问**: http://your-server-ip

## 部署步骤

1. **配置环境变量**
   ```bash
   # 创建 .env 文件
   cat > .env << EOF
   MYSQL_ROOT_PASSWORD=your_secure_password
   MYSQL_DATABASE=hr_db
   DATABASE_URL=mysql+pymysql://root:your_secure_password@localhost:3306/hr_db
   BACKTEND_TAG=latest
   FRONTEND_TAG=latest
   EOF
   ```

2. **启动服务**
   ```bash
   docker-compose up -d
   ```

3. **查看服务状态**
   ```bash
   docker-compose ps
   ```

4. **查看日志**
   ```bash
   docker-compose logs -f [service_name]
   ```

## 访问地址

### 通过 Nginx 网关访问（推荐）
- **前端应用**: http://your-server-ip
- **后端 API**: http://your-server-ip/api/v1/
- **支付 API**: http://your-server-ip/api/pay/

### 直接访问各服务
- **前端**: http://your-server-ip:3000
- **后端**: http://your-server-ip:8000
- **支付**: http://your-server-ip:9000
- **数据库**: localhost:3306

## Nginx 配置说明

### 路由规则

1. **前端静态文件**: `/` → `localhost:3000`
2. **后端 API**: `/api/v1/*` → `localhost:8000/api/v1/`
3. **支付 API**: `/api/pay/*` → `localhost:9000/`

### 特性

- **CORS 支持**: 自动处理跨域请求
- **Gzip 压缩**: 自动压缩静态资源
- **WebSocket 支持**: 前端热重载支持

## 故障排查

### 1. 服务无法启动
```bash
# 查看详细日志
docker-compose logs [service_name]

# 检查端口占用
netstat -tulpn | grep :80
netstat -tulpn | grep :3000
netstat -tulpn | grep :8000
netstat -tulpn | grep :9000
```

### 2. 数据库连接失败
```bash
# 检查数据库服务状态
docker-compose exec mysql mysql -u root -p

# 检查网络连接
docker-compose exec hr-backend ping localhost
```

### 3. 前端无法访问后端 API
```bash
# 检查 nginx 配置
docker-compose exec nginx nginx -t

# 查看 nginx 访问日志
docker-compose exec nginx tail -f /var/log/nginx/access.log

# 测试后端 API 是否可访问
curl http://localhost:8000/api/v1/
```

### 4. 端口冲突
```bash
# 检查端口占用
sudo lsof -i :80
sudo lsof -i :3000
sudo lsof -i :8000
sudo lsof -i :9000

# 停止占用端口的进程
sudo kill -9 [PID]
```

## 更新部署

1. **更新镜像标签**
   ```bash
   # 修改 .env 文件中的标签
   BACKTEND_TAG=v1.0.1-8
   FRONTEND_TAG=v1.0.1-8
   ```

2. **重新部署**
   ```bash
   docker-compose pull
   docker-compose up -d
   ```

3. **清理旧镜像**
   ```bash
   docker image prune -f
   ```

## 安全建议

1. **修改默认端口**：考虑修改默认端口避免被扫描
2. **防火墙配置**：只开放必要端口
3. **数据库安全**：使用强密码，限制访问IP
4. **HTTPS 配置**：生产环境建议配置 SSL 证书 