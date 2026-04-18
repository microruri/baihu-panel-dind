# Baihu Panel DinD

基于 [baihu-panel](https://github.com/engigu/baihu-panel) 的 Docker-in-Docker 版本，在保留原有功能的基础上增加完整的 Docker 支持。

## 镜像地址

```
docker pull microruri/baihu-panel-dind:latest
docker pull microruri/baihu-panel-dind:latest-debian13
docker pull microruri/baihu-panel-dind:latest-minimal
docker pull microruri/baihu-panel-dind:1.0.xx
docker pull microruri/baihu-panel-dind:1.0.xx-debian13
docker pull microruri/baihu-panel-dind:1.0.xx-minimal
```

> 注：镜像按 `linux/amd64,linux/arm64` 多架构清单构建，前提是上游对应标签提供该架构

## 快速使用

```bash
docker run -d \
  --name baihu-dind \
  --privileged \
  -p 8052:8052 \
  -v ./data:/app/data \
  -v ./envs:/app/envs \
  -e BAIHU_SECRET_KEY=your_secret_key \
  --restart unless-stopped \
  microruri/baihu-panel-dind:latest
```

## 本地构建

```bash
git clone https://github.com/microruri/baihu-panel-dind.git
cd baihu-panel-dind

docker build -f docker/Dockerfile -t baihu-panel-dind:local .

# 基于特定版本构建
docker build -f docker/Dockerfile --build-arg BAIHU_VERSION=latest-debian13 -t baihu-panel-dind:debian13 .
docker build -f docker/Dockerfile --build-arg BAIHU_VERSION=latest-minimal -t baihu-panel-dind:minimal .
```

## 相关项目

- [baihu-panel](https://github.com/engigu/baihu-panel) - 原版 Baihu Panel
