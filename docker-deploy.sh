#!/bin/bash

# Docker 日志查询服务 - 一键部署脚本
# 端口: 4041
# 作者: docker-log-service
# 日期: 2026-05-15

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
IMAGE_NAME="docker-log-frontend"
CONTAINER_NAME="docker-log-frontend"
PORT=4041
TAG="latest"

# 打印信息函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_warning "docker-compose 未安装，将使用 docker compose"
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
    
    log_success "Docker 检查通过"
}

# 构建镜像
build_image() {
    log_info "开始构建 Docker 镜像..."
    
    docker build -t ${IMAGE_NAME}:${TAG} .
    
    if [ $? -eq 0 ]; then
        log_success "镜像构建成功: ${IMAGE_NAME}:${TAG}"
    else
        log_error "镜像构建失败"
        exit 1
    fi
}

# 停止并删除旧容器
stop_old_container() {
    log_info "检查并停止旧容器..."
    
    if docker ps -a | grep -q ${CONTAINER_NAME}; then
        log_warning "发现运行中的容器，正在停止..."
        docker stop ${CONTAINER_NAME} || true
        docker rm ${CONTAINER_NAME} || true
        log_success "旧容器已清理"
    else
        log_info "未发现旧容器"
    fi
}

# 启动新容器
start_container() {
    log_info "启动新容器..."
    
    docker run -d \
        --name ${CONTAINER_NAME} \
        --restart unless-stopped \
        -p ${PORT}:4041 \
        --network docker-log-network \
        ${IMAGE_NAME}:${TAG}
    
    if [ $? -eq 0 ]; then
        log_success "容器启动成功"
    else
        log_error "容器启动失败"
        exit 1
    fi
}

# 等待服务就绪
wait_for_service() {
    log_info "等待服务启动..."
    sleep 5
    
    if docker ps | grep -q ${CONTAINER_NAME}; then
        log_success "服务运行正常"
    else
        log_error "服务启动失败，请查看日志"
        docker logs ${CONTAINER_NAME}
        exit 1
    fi
}

# 显示服务信息
show_info() {
    echo ""
    log_success "=========================================="
    log_success "  Docker 日志查询服务部署完成"
    log_success "=========================================="
    echo ""
    log_info "镜像名称: ${IMAGE_NAME}:${TAG}"
    log_info "容器名称: ${CONTAINER_NAME}"
    log_info "访问地址: http://localhost:${PORT}"
    log_info "后端地址: http://backend:9091"
    echo ""
    log_info "常用命令:"
    log_info "  查看日志: docker logs -f ${CONTAINER_NAME}"
    log_info "  停止服务: docker stop ${CONTAINER_NAME}"
    log_info "  重启服务: docker restart ${CONTAINER_NAME}"
    log_info "  删除服务: docker rm -f ${CONTAINER_NAME}"
    echo ""
}

# 主函数
main() {
    echo ""
    log_info "=========================================="
    log_info "  Docker 日志查询服务 - 一键部署"
    log_info "  端口: ${PORT}"
    log_info "=========================================="
    echo ""
    
    # 检查 Docker
    check_docker
    
    # 确保网络存在
    log_info "检查 Docker 网络..."
    docker network create docker-log-network 2>/dev/null || true
    log_success "网络检查完成"
    
    # 构建镜像
    build_image
    
    # 停止旧容器
    stop_old_container
    
    # 启动新容器
    start_container
    
    # 等待服务
    wait_for_service
    
    # 显示信息
    show_info
}

# 执行主函数
main "$@"
