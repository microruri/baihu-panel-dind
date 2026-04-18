# Baihu Panel DinD

基于 [baihu-panel](https://github.com/engigu/baihu-panel) 的 Docker-in-Docker 版本，在保留原有功能的基础上增加完整的 Docker 支持。

## 镜像地址

```
docker pull microruri/baihu-panel-dind:latest
docker pull microruri/baihu-panel-dind:latest-debian13
docker pull microruri/baihu-panel-dind:latest-minimal
docker pull microruri/baihu-panel-dind:v1.0.xx          # 版本标签
docker pull microruri/baihu-panel-dind:v1.0.xx-debian13
docker pull microruri/baihu-panel-dind:v1.0.xx-minimal
```

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
git clone https://github.com/YOUR_USERNAME/baihu-dind.git
cd baihu-dind

docker build -t baihu-panel-dind:local .

# 基于特定版本构建
docker build --build-arg BAIHU_VERSION=latest-debian13 -t baihu-panel-dind:debian13 .
```

## 相关项目

- [baihu-panel](https://github.com/engigu/baihu-panel) - 原版 Baihu Panel
