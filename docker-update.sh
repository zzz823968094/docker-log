#!/bin/bash

# Docker 日志查询服务 - 更新脚本
# 作者: docker-log-service
# 日期: 2026-05-15

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

IMAGE_NAME="docker-log-frontend"
CONTAINER_NAME="docker-log-frontend"
PORT=4041
TAG="${1:-latest}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo ""
log_info "=========================================="
log_info "  更新 Docker 服务"
log_info "  镜像: ${IMAGE_NAME}:${TAG}"
log_info "=========================================="
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    exit 1
fi

# 停止旧容器
log_info "停止旧容器..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true
log_success "旧容器已清理"

# 构建新镜像
log_info "构建新镜像..."
docker build -t ${IMAGE_NAME}:${TAG} .

if [ $? -ne 0 ]; then
    log_error "镜像构建失败"
    exit 1
fi

log_success "新镜像构建成功"

# 启动新容器
log_info "启动新容器..."
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${PORT}:4041 \
    --network docker-log-network \
    ${IMAGE_NAME}:${TAG}

if [ $? -eq 0 ]; then
    log_success "新容器启动成功"
else
    log_error "新容器启动失败"
    exit 1
fi

# 等待服务
log_info "等待服务启动..."
sleep 5

if docker ps | grep -q ${CONTAINER_NAME}; then
    log_success "服务更新完成"
    echo ""
    log_info "访问地址: http://localhost:${PORT}"
else
    log_error "服务启动失败，请查看日志"
    docker logs ${CONTAINER_NAME}
    exit 1
fi

echo ""
