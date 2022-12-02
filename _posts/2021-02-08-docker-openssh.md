---
layout: post
title: 'Docker 镜像支持 SSH 远程登录'
subtitle: '为 Docker 镜像开启远程开发模式'
date: 2021-02-08 20:11:00 +0800
categories: [tech, docker]
author: zhonger
cover: 'https://i.lisz.top/cover/6jFNXU.webp'
cover_author: 'Annie Spratt'
cover_author_link: 'https://unsplash.com/@anniespratt'
tags: 
- Docker
- SSH
---

## 前言

&emsp;&emsp;Docker 镜像是否有 SSH 远程登录的必要？这个问题其实对于开发者来说是相对而言的，在实际的生产环境中是无必要需求就不必要，而在开发环境中则显得大有裨益。当然，即使在开发环境中也仍然应该把安全性放在首位，因此采用凭一对公钥和私钥实现无密码登录是比较安全、稳妥的办法。

## 安装配置

&emsp;&emsp;公钥文件的导入是这项任务的重点。一般来说，可能会有人想要以固定文件的形式写入到 Docker 镜像中，这样一来根据这个镜像启动的所有实例都将包含所需的公钥文件。但这样明显的缺点也是无法进行修改，不便于其他人复用这个 Docker 镜像。有一个叫 ssh-import-id 的工具，可以帮助我们实现这一目标。只要你在 Github 上有账户且已导入公钥，都可以通过 ssh-import-id 工具从 Github 中导入指定用户名的公钥。

&emsp;&emsp;Dockerfile 文件如下所示：

```dockerfile
FROM zhonger/ubuntu:latest

LABEL maintainer="zhonger zhonger@live.cn"

# Install ssh-import-id tool
RUN sudo apt update \
    && sudo apt install -y ssh-import-id 
    
# Clean apt-cache
RUN sudo apt autoremove -y \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

&emsp;&emsp;文件 entrypoint.sh 内容如下：

```bash
#!/bin/bash
ssh-import-id gh:$GITHUB_NAME
sudo service ssh restart
/bin/zsh
```

### 运行

#### 方式一

```bash
docker run -ti -d -e GITHUB_NAME="zhonger" --restart=always --name dev zhonger/ubuntu:ssh
```

#### 方式二

&emsp;&emsp;docker-compose.yml 文件如下：

```yaml
version: "3.9"
services:

  conquest:
    image: zhonger/ubuntu:ssh
    container_name: dev
    environment:
     - GITHUB_NAME=zhonger
    stdin_open: true
    tty: true
    volumes:
     - ~/web/test:/home/ubuntu/test
    restart: always
```

```bash
docker-compose up -d
docker inspect dev # 查看 ip
ssh ubuntu@<instance ip> # 尝试登陆验证
```
