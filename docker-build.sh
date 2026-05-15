#!/bin/bash

# Docker 日志查询服务 - 构建脚本
# 作者: docker-log-service
# 日期: 2026-05-15

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置变量
IMAGE_NAME="docker-log-frontend"
TAG="${1:-latest}"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
log_info "=========================================="
log_info "  构建 Docker 镜像"
log_info "  镜像: ${IMAGE_NAME}:${TAG}"
log_info "=========================================="
echo ""

# 检查 Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    exit 1
fi

# 构建镜像
log_info "开始构建..."
docker build -t ${IMAGE_NAME}:${TAG} .

if [ $? -eq 0 ]; then
    log_success "镜像构建成功: ${IMAGE_NAME}:${TAG}"
    
    # 显示镜像信息
    echo ""
    log_info "镜像详情:"
    docker images | grep ${IMAGE_NAME}
    echo ""
else
    log_error "镜像构建失败"
    exit 1
fi
