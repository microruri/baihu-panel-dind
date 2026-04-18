# Baihu Panel with Docker-in-Docker (DinD)
# 单文件构建，按 BAIHU_VERSION 选择 Docker APT suite

ARG BAIHU_VERSION=latest
FROM ghcr.io/engigu/baihu:${BAIHU_VERSION}
ARG BAIHU_VERSION

LABEL maintainer="i@microruri.com"
LABEL description="Baihu Panel with Docker-in-Docker support"
LABEL org.opencontainers.image.source="https://github.com/microruri/baihu-panel-dind"

ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER_TLS_CERTDIR=""

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
   && install -m 0755 -d /etc/apt/keyrings \
   && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
   && chmod a+r /etc/apt/keyrings/docker.asc \
   && case "${BAIHU_VERSION}" in \
        *minimal*) DOCKER_SUITE="bookworm" ;; \
        *debian13*) DOCKER_SUITE="trixie" ;; \
        *) DOCKER_SUITE="trixie" ;; \
      esac \
   && printf "Types: deb\nURIs: https://download.docker.com/linux/debian\nSuites: %s\nComponents: stable\nArchitectures: %s\nSigned-By: /etc/apt/keyrings/docker.asc\n" "${DOCKER_SUITE}" "$(dpkg --print-architecture)" > /etc/apt/sources.list.d/docker.sources \
   && apt-get update \
   && apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
   && rm -rf /var/lib/apt/lists/*

VOLUME ["/var/lib/docker"]

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8052

ENTRYPOINT ["entrypoint.sh"]
