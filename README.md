# Docker日志查询服务前端

基于 Vue3 + TypeScript + Element Plus 构建的 Docker 容器日志查询管理系统。

## 技术栈

- **前端框架**: Vue 3.4+
- **开发语言**: TypeScript 5.3+
- **UI组件库**: Element Plus 2.5+
- **状态管理**: Pinia 2.1+
- **路由管理**: Vue Router 4.2+
- **HTTP客户端**: Axios 1.6+
- **构建工具**: Vite 5.0+

## 功能特性

- ✅ 用户登录/登出认证
- ✅ **401 未授权自动处理**（弹出确认框并跳转登录页）
- ✅ Docker容器列表展示
- ✅ 容器日志查询与查看
- ✅ 容器状态验证
- ✅ 响应式布局设计
- ✅ 完整的TypeScript类型支持

## 项目结构

```
docker-log/
├── src/
│   ├── api/              # API接口模块
│   │   ├── auth.ts       # 认证相关接口
│   │   └── docker.ts     # Docker容器相关接口
│   ├── layout/           # 布局组件
│   │   └── Index.vue     # 主布局
│   ├── router/           # 路由配置
│   │   └── index.ts
│   ├── stores/           # Pinia状态管理
│   │   └── user.ts       # 用户状态
│   ├── types/            # TypeScript类型定义
│   │   └── index.ts
│   ├── utils/            # 工具函数
│   │   └── request.ts    # Axios请求封装
│   ├── views/            # 页面组件
│   │   ├── Login.vue     # 登录页
│   │   ├── Containers.vue # 容器列表页
│   │   └── Logs.vue      # 日志查询页
│   ├── App.vue           # 根组件
│   └── main.ts           # 入口文件
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 快速开始

### 环境要求

- Node.js >= 18.0.0
- npm >= 9.0.0
- Docker >= 20.0.0 (可选，用于容器化部署)

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000

### 生产构建

```bash
npm run build
```

### 运行生产版本

```bash
# 构建并运行生产版本（需要安装 serve）
npm run prod

# 或者手动运行
npm run build
npx serve dist -l 4041
```

### Docker 部署（推荐）

**使用 deploy.sh 快速部署:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**或使用 Makefile:**
```bash
make deploy
```

**传统部署方式:**

**Linux/Mac:**
```bash
chmod +x docker-deploy.sh
./docker-deploy.sh
```

**Windows:**
```cmd
docker-deploy.bat
```

访问 http://localhost:4041

**更多部署方式请查看:** [CONFIG_AND_DEPLOY.md](./CONFIG_AND_DEPLOY.md)

### 预览构建结果

```bash
npm run preview
```

### 代码检查和格式化

```bash
# ESLint检查
npm run lint

# Prettier格式化
npm run format
```

## 配置说明

### Docker 部署文件说明

本项目包含以下 Docker 部署相关文件：

- **Dockerfile**: 多阶段构建 Docker 镜像，使用 Node.js 18 Alpine 作为构建环境，Nginx Alpine 作为运行环境
- **docker-compose.yml**: Docker Compose 配置文件，用于一键部署前端服务
- **nginx.conf**: Nginx 配置文件，包含 API 代理、gzip 压缩、静态资源缓存等优化配置
- **deploy.sh**: 自动化部署脚本，支持代码拉取、环境变量配置、服务重启等功能
- **.dockerignore**: Docker 构建时忽略的文件列表，优化构建速度

### 后端API代理

在 `vite.config.ts` 中配置了API代理：

```typescript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:9091',
      changeOrigin: true
    }
  }
}
```

确保后端服务运行在 `http://localhost:9091`

### 默认登录账号

根据后端接口文档，默认账号为：
- 用户名: admin
- 密码: 123456

## API接口

### 认证接口
- POST `/api/auth/login` - 用户登录
- POST `/api/auth/logout` - 用户登出

### Docker容器接口
- GET `/api/docker/containers` - 获取容器列表
- POST `/api/docker/logs` - 查询容器日志（返回日志行数组）
- GET `/api/docker/containers/:id/validate` - 验证容器是否存在
- GET `/api/docker/containers/:id/logs` - 获取容器日志文件列表
- GET `/api/docker/websocket/status` - 获取WebSocket连接状态

## 开发规范

本项目遵循阿里云前端开发规范：

1. **代码风格**: 使用ESLint + Prettier统一代码风格
2. **TypeScript**: 严格模式，所有变量和函数必须有类型声明
3. **组件命名**: 使用PascalCase命名组件
4. **文件组织**: 按功能模块组织文件结构
5. **注释规范**: 关键逻辑必须添加注释
6. **认证处理**: 401 未授权时自动跳转登录页（详见 [AUTH_401_HANDLING.md](./AUTH_401_HANDLING.md)）

## Docker 部署指南

### 使用 deploy.sh 脚本部署

`deploy.sh` 是一个自动化部署脚本，它会：
1. 停止当前的 Docker 服务
2. 从 Git 仓库拉取最新代码
3. 检查并配置环境变量
4. 重新构建并启动 Docker 服务

```bash
# 赋予执行权限
chmod +x deploy.sh

# 执行部署
./deploy.sh
```

### 使用 Docker Compose 部署

```bash
# 构建并启动服务
docker compose up -d --build

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

### 使用 Makefile 部署

```bash
# 快速部署
make deploy

# 仅构建镜像
make docker-build

# 清理 Docker 资源
make docker-clean
```

### 环境变量配置

项目使用 `.env.production` 文件配置生产环境变量：

```env
# 生产环境配置
VITE_APP_TITLE=Docker日志查询服务
VITE_APP_BASE_API=/api
VITE_APP_PORT=4041
VITE_APP_BACKEND_URL=https://log.animeparadise.vip

# Nginx 代理配置（用于 Docker 部署）
BACKEND_HOST=host.docker.internal
BACKEND_PORT=9091
```

在部署前，请根据实际环境修改 `.env.production` 文件中的配置。

### 域名配置

如果你需要使用域名访问，可以：

1. **使用 Docker 部署**：在服务器上配置反向代理（如 Nginx）将域名指向容器的 4041 端口
2. **直接运行**：修改 `nginx.conf` 中的 `server_name` 为你的域名

## 注意事项

1. 首次运行前请确保已安装所有依赖
2. 确保后端服务已启动并可访问
3. 如遇跨域问题，请检查后端CORS配置
4. 生产环境部署时请修改API地址配置

## License

MIT
