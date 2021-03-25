---
layout: post
title: Docker 入门
subtitle: Docker 的常用安装与加速
date: 2017-05-09 12:43:31 +0800
tags:
- docker 
- ubuntu
categories: [tech, docker]
cover: 'https://images.unsplash.com/photo-1543097692-fa13c6cd8595?w=1600&h=900'
---
# Docker入门

## 安装

~~安装 Docker 环境当然要使用上海大学开源镜像站提供的 docker-ce 镜像源咯。~~ 

推荐使用中科大开源镜像站提供的 docker-ce 镜像源安装 Docker 环境，下面以 Ubuntu 操作系统为例开始实验。


```bash
# 添加中科大镜像源到list列表中
sudo tee -a /etc/apt/sources.list.d/docker.list << EOF
    deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -c --short) stable
EOF

# 添加可信任的GPG公钥
sudo apt-key adv --keyserver=hkp://keyserver.ubuntu.com --recv 7EA0A9C3F273FCD8

# 更新本地软件缓存列表
sudo apt update

# 安装 docker-ce 及其依赖
sudo apt install -y docker-ce

# 将普通用户添加到 docker 组，这样普通用户也能使用 docker 命令
sudo usermod -aG docker $(whoami)
```

## 更换 docker 镜像加速器

由于 Docker Hub 的服务器只部署在美国，所以国内访问一般都比较慢，于是就要使用上大大佬们提供的镜像加速器，以下为修改加速器地址的方法（以中科大 docker 镜像仓库加速器为例）：


```bash
# 添加 中科大 Docker 镜像加速器
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://docker.mirrors.ustc.edu.cn/

# 重启 Docker 服务
sudo service docker restart
```


以下为国内主要的 docker 镜像仓库加速器：

| 服务提供者 | 加速地址 | 推荐指数 | 备注 |
| ---- | ---- | ---- | ---- |
| 中科大镜像站 | https://docker.mirrors.ustc.edu.cn | ★★★★★ | 无任何限制 |
| Docker官方 | https://registry.docker-cn.com | ★★★★ | 无任何限制，由于服务器在香港阿里云，和阿里云差不多 |
| 阿里云 | https://{your_id}.mirror.aliyuncs.com | ★★★★ | 某些时候会限速 |
| Daocloud |  http://{your_id}.m.daocloud.io | ★★★★★ | 大部分时候网速还是可以的 |
| 网易云 | https://hub-mirror.c.163.com  | ★★★★ | 没有尝试过 |

## 安装 docker-compose

docker-compose 是一个由 Docker 官方提供的应用多容器搭配管理工具，适合一个应用需要多个容器配合统一管理，进一步简化部署、升级步骤。

```bash
# 安装 python3 python3-pip
sudo apt install -y python3 python3-pip

# 安装 docker-compose
sudo pip3 install docker-compose
```