#!/bin/bash

# 部署脚本：停止Docker服务 -> 拉取最新代码 -> 配置环境变量 -> 重新构建并启动

set -e  # 遇到错误立即退出

echo "========================================="
echo "  开始部署 docker-log-frontend"
echo "========================================="

# 1. 停止Docker服务
echo ""
echo "[1/4] 停止 Docker 服务..."
docker compose down
echo "✓ Docker 服务已停止"

# 2. 拉取最新代码
echo ""
echo "[2/4] 拉取最新代码..."
git pull origin master
echo "✓ 代码已更新"

# 3. 配置环境变量
echo ""
echo "[3/4] 配置环境变量..."
if [ ! -f .env.production ]; then
    echo "⚠ 警告: .env.production 文件不存在，创建默认配置"
    cat > .env.production << EOF
# 生产环境配置
VITE_APP_TITLE=Docker日志查询服务
VITE_APP_BASE_API=/api
VITE_APP_PORT=4041
VITE_APP_BACKEND_URL=https://log.animeparadise.vip
EOF
    echo "✓ 已创建默认 .env.production 文件"
else
    echo "✓ 环境变量配置文件已存在"
fi
echo "当前 API 地址: $(grep VITE_APP_BACKEND_URL .env.production | cut -d'=' -f2)"

# 4. 重新构建并启动
echo ""
echo "[4/4] 重新构建并启动 Docker 服务..."
# 确保使用生产环境构建
docker compose up -d --build --force-recreate
echo "✓ Docker 服务已启动"

# 5. 查看服务状态
echo ""
echo "检查服务状态..."
docker compose ps

echo ""
echo "========================================="
echo "  ✓ 部署完成！"
echo "========================================="
echo ""
echo "访问地址: http://localhost:4041"
echo ""
echo "查看日志: docker compose logs -f"
echo ""
