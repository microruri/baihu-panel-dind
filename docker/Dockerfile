# Baihu Panel with Docker-in-Docker (DinD)
# 基于 ghcr.io/engigu/baihu 镜像，添加完整的 Docker 支持

ARG BAIHU_VERSION=latest
FROM ghcr.io/engigu/baihu:${BAIHU_VERSION}

LABEL maintainer="i@microruri.com"
LABEL description="Baihu Panel with Docker-in-Docker support"
LABEL org.opencontainers.image.source="https://github.com/microruri/baihu-panel-dind"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER_TLS_CERTDIR=""

# 安装 Docker 及相关工具（兼容不同 Debian 发行版的软件包命名）
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        docker.io \
        docker-compose \
        ca-certificates \
        curl \
        gnupg \
        lsb-release; \
    if apt-cache show docker-buildx-plugin >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends docker-buildx-plugin; \
    elif apt-cache show docker-buildx >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends docker-buildx; \
    elif apt-cache show moby-buildx >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends moby-buildx; \
    else \
        echo "No buildx package found in current apt repositories; skip install."; \
    fi; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get clean

# 创建 DinD 启动脚本
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 创建 Docker 数据目录
RUN mkdir -p /var/lib/docker /var/run/docker-runtime

# 设置权限
RUN chown -R root:root /var/lib/docker /var/run/docker-runtime

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD docker info > /dev/null 2>&1 && curl -f http://localhost:8052/health || exit 1

# 暴露端口
EXPOSE 8052

# 使用自定义 entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
