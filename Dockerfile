# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 安装依赖
RUN npm ci --registry=https://registry.npmmirror.com

# 复制源代码（包括 .env.production）
COPY . .

# 构建生产版本（使用 production 模式，自动读取 .env.production）
RUN npm run build

# 生产阶段
FROM nginx:alpine

# 安装 bash 和 envsubst（用于环境变量替换）
RUN apk add --no-cache bash && \
    apk add --no-cache gettext

# 复制自定义nginx配置模板
COPY nginx.conf /etc/nginx/conf.d/default.conf.template

# 创建启动脚本，用于在启动时替换环境变量
RUN echo '#!/bin/bash' > /docker-entrypoint.sh && \
    echo 'envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.sh && \
    echo 'exec "$@"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# 复制构建产物到nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 4041

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:4041/health || exit 1

# 使用启动脚本
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
