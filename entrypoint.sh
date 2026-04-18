#!/bin/bash
# Baihu Panel DinD Entrypoint
# 启动 Docker Daemon 并运行 Baihu 主进程

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否启用了 DinD（通过环境变量控制）
ENABLE_DIND="${ENABLE_DIND:-true}"

if [ "$ENABLE_DIND" = "true" ]; then
    log_info "Starting Docker-in-Docker mode..."
    
    # 设置 Docker 数据目录（避免与外层 Docker 冲突）
    export DOCKER_DATA_ROOT="${DOCKER_DATA_ROOT:-/var/lib/docker}"
    
    # 启动 Docker Daemon
    log_info "Starting Docker Daemon..."
    dockerd \
        --data-root="$DOCKER_DATA_ROOT" \
        --host=unix:///var/run/docker.sock \
        --host=tcp://127.0.0.1:2375 \
        --tls=false \
        --storage-driver=overlay2 \
        --userns-remap="" \
        > /var/log/dockerd.log 2>&1 &
    
    DOCKER_PID=$!
    log_info "Docker Daemon started with PID: $DOCKER_PID"
    
    # 等待 Docker Daemon 就绪
    log_info "Waiting for Docker Daemon to be ready..."
    MAX_RETRIES=30
    RETRY_COUNT=0
    
    while ! docker info > /dev/null 2>&1; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            log_error "Docker Daemon failed to start within 30 seconds"
            log_error "Docker Daemon logs:"
            tail -50 /var/log/dockerd.log
            exit 1
        fi
        log_info "Waiting for Docker... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 1
    done
    
    log_info "Docker Daemon is ready!"
    docker version
    log_info "Docker info:"
    docker info | head -20
else
    log_info "DinD mode disabled, skipping Docker Daemon startup"
fi

# 如果挂载了 docker.sock（DooD 模式），检查是否可用
if [ -S /var/run/docker.sock ]; then
    if docker ps > /dev/null 2>&1; then
        log_info "External Docker socket detected and working (DooD mode)"
    fi
fi

# 运行初始化脚本（如果存在）
if [ -f /app/init.sh ]; then
    log_info "Running initialization script..."
    /app/init.sh
fi

# 启动 Baihu 主进程
log_info "Starting Baihu Panel..."
log_info "Baihu version: $(cat /app/VERSION 2>/dev/null || echo 'unknown')"

# 使用 exec 替换当前进程，确保信号正确传递
if [ -f /app/baihu ]; then
    exec /app/baihu
elif command -v baihu &> /dev/null; then
    exec baihu
else
    log_error "Baihu binary not found!"
    exit 1
fi
