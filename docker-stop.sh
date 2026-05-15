#!/bin/bash

# Docker 日志查询服务 - 停止脚本
# 作者: docker-log-service
# 日期: 2026-05-15

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER_NAME="docker-log-frontend"

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
log_info "  停止 Docker 容器"
log_info "  容器: ${CONTAINER_NAME}"
log_info "=========================================="
echo ""

# 检查容器是否存在
if ! docker ps -a | grep -q ${CONTAINER_NAME}; then
    log_warning "容器不存在: ${CONTAINER_NAME}"
    exit 0
fi

# 停止容器
log_info "正在停止容器..."
docker stop ${CONTAINER_NAME}

if [ $? -eq 0 ]; then
    log_success "容器已停止"
else
    log_warning "停止容器失败"
fi

# 询问是否删除
read -p "是否删除容器? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "正在删除容器..."
    docker rm ${CONTAINER_NAME}
    log_success "容器已删除"
fi

echo ""
