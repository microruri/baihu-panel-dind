# Baihu Panel with Docker-in-Docker (DinD)
# 基于 ghcr.io/engigu/baihu 镜像，添加完整的 Docker 支持

ARG BAIHU_VERSION=latest
FROM ghcr.io/engigu/baihu:${BAIHU_VERSION}

LABEL maintainer="your-email@example.com"
LABEL description="Baihu Panel with Docker-in-Docker support"
LABEL org.opencontainers.image.source="https://github.com/yourusername/baihu-dind"

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER_TLS_CERTDIR=""

# 安装 Docker 及相关工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    docker.io \
    docker-compose \
    docker-buildx-plugin \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 安装 Docker CLI 补充工具（可选）
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

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
