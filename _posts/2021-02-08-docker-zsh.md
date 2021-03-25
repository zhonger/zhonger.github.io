---
layout: post
title: 'Docker 镜像安装配置 zsh'
subtitle: '个性化 Docker 镜像，你值得拥有'
date: 2021-02-08 20:09:00 +0800
tags: 
- Docker
- Ubuntu
- zsh
- 免密
categories: [tech, docker]
cover: 'https://images.unsplash.com/photo-1551978429-3dbfed5cacc9?w=1600&q=900'
---

## 前言

&emsp;&emsp;Docker 具有易迁移、镜像容量小的优势，已被广泛应用于快速应用部署。对于开发者而言，Docker 的这一优势也同样适用于开发环境的快速搭建。因此，具有个性化的 Docker 镜像将会为开发者使用提供更大的便利。笔者习惯在 Mac 或者服务器上使用非 root 的 sudo 用户和 zsh，因此也希望在用于开发环境的 Docker 镜像也有这样的特点。

&emsp;&emsp;为什么要使用非 root 的 sudo 用户，而不直接使用 root 用户？Docker 镜像默认提供的一般都是 root 用户，而所有人想要把应用 Docker 化，在 Docker 镜像中用于运行程序的一般不能是 root 用户。这也是因为如果使用 root 用户的话，应用一旦被他人渗透取得程序执行权限，该 Docker 实例运行的所在宿主机也可能被入侵。因此，大部分开发者都应该养成使用非 root 的 sudo 用户的习惯，既享有 sudo 权限，也要严格控制 Docker 镜像中的权限。

&emsp;&emsp;为什么要使用 zsh 而不使用默认的 bash？一方面的原因是，bash 对于大小写的自动补全比较严格，不会像 zsh 那样可以无视大小写进行自动补全推荐。另一方面的原因是，bash 的历史功能只能在前后命令之间切换，而 zsh 可以根据历史命令进行自动补全推荐从而突破这一限制。当然，zsh 所支持的主题、插件也比较丰富，可以适应不同人的审美和使用需求。

## 安装配置

笔者想要构建的开发环境基础 Docker 镜像主要的特点是以上两点，具体来说是：

- 具有 sudo 权限的非 root 用户：ubuntu
- 执行 sudo 命令时不需要输入密码，即免密 sudo
- ubuntu 用户的默认 shell 是 zsh

因此，所对应的 Docker 镜像生成配置文件（Dockerfile）如下所示。

```dockerfile
FROM ubuntu:latest

LABEL maintainer="zhonger zhonger@live.cn"

# Create a no-passowrd sudo user
RUN apt update \
    && apt install -y sudo \
    && useradd -m ubuntu -s /bin/bash && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD : ALL" | tee /etc/sudoers.d/nopasswd4sudo

# Adjust Timezone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

USER ubuntu
WORKDIR /home/ubuntu

# Install zsh
RUN sudo apt install -y git zsh \
    && git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/bira/" ~/.zshrc \
    && sudo usermod -s /bin/zsh ubuntu


# Clean apt-cache
RUN sudo apt autoremove -y \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/zsh"]
```

使用以下命令编译生成 Docker 镜像：

```bash
docker build . -t zhonger/ubuntu:latest
```

使用以下命令运行一个 Docker 实例验证：

```bash
docker run -ti -d --name dev zhonger/ubuntu:latest
docker exec -ti dev /bin/zsh
# 登录后看见 zsh 主题即安装配置 zsh 成功

sudo apt update
# 输入执行命令后立刻执行无需输入密码，表示安装配置免密且具有 sudo 权限的 ubuntu 用户成功
```