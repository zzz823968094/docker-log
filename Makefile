.PHONY: help install dev build preview lint format docker-build docker-deploy docker-stop docker-update docker-compose-clean deploy prod

# 默认目标
help:
	@echo "Docker日志查询服务 - 可用命令:"
	@echo ""
	@echo "开发相关:"
	@echo "  make install      - 安装依赖"
	@echo "  make dev          - 启动开发服务器"
	@echo "  make dev-test     - 启动测试环境开发服务器"
	@echo "  make build        - 构建生产版本"
	@echo "  make build-test   - 构建测试版本"
	@echo "  make preview      - 预览构建结果"
	@echo ""
	@echo "生产运行:"
	@echo "  make prod         - 构建并运行生产版本"
	@echo ""
	@echo "代码质量:"
	@echo "  make lint         - ESLint检查"
	@echo "  make format       - Prettier格式化"
	@echo ""
	@echo "Docker部署:"
	@echo "  make docker-build    - 构建Docker镜像"
	@echo "  make docker-deploy   - 一键部署"
	@echo "  make docker-stop     - 停止服务"
	@echo "  make docker-update   - 更新服务"
	@echo "  make docker-compose  - Docker Compose部署"
	@echo "  make docker-clean    - 清理Docker资源"
	@echo ""
	@echo "快速部署:"
	@echo "  make deploy          - 使用deploy.sh快速部署"
	@echo ""

# 安装依赖
install:
	@npm install

# 开发模式
dev:
	@npm run dev

# 测试环境开发模式
dev-test:
	@npm run dev:test

# 构建生产版本
build:
	@npm run build

# 构建测试版本
build-test:
	@npm run build:test

# 预览构建结果
preview:
	@npm run preview

# ESLint检查
lint:
	@npm run lint

# Prettier格式化
format:
	@npm run format

# Docker构建
docker-build:
	@chmod +x docker-build.sh
	@./docker-build.sh

# Docker一键部署
docker-deploy:
	@chmod +x docker-deploy.sh
	@./docker-deploy.sh

# Docker停止
docker-stop:
	@chmod +x docker-stop.sh
	@./docker-stop.sh

# Docker更新
docker-update:
	@chmod +x docker-update.sh
	@./docker-update.sh

# Docker Compose部署
docker-compose:
	@docker-compose up -d

# Docker Compose生产部署
docker-compose-prod:
	@docker-compose -f docker-compose.prod.yml up -d

# 清理Docker资源
docker-clean:
	@echo "清理未使用的Docker资源..."
	@docker system prune -f
	@echo "清理完成"

# 快速部署
deploy:
	@chmod +x deploy.sh
	@./deploy.sh

# 构建并运行生产版本
prod:
	@npm run prod
