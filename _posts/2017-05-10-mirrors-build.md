---
layout: post
title: 镜像站构建
subtitle: 一步一步搭建开源镜像站
date: 2017-05-10 10:02:50 +0800
categories: [tech, Linux]
author: zhonger
cover: 'https://i.lisz.top/cover/0ndvwZ.webp'
cover_author: 'Christian Joudrey'
cover_author_link: 'https://unsplash.com/@cjoudrey'
tags:
- mirror
- build
- rsync
- cran
- wget
- bandsnatch
---

## 前言

&emsp;&emsp;构建镜像站主要是对于 linux 开源平台的软件源、 pypi 源、 cran 源、 mysql 等开源软件第三方源，大部分源支持使用 rsync 工具直接进行同步，少部分源比较特殊，比如 pypi 源必须采用官方提供的 bandsnatch 工具，mysql 源则只能采用 wget 的方式镜像整站。

## linux 镜像

&emsp;&emsp;采用 rsync 工具

```bash
rsync -avz --delete --safe-links rsync.apache.org::apache-dist /path/to/mirror
rsync -avz --delete --safe-links mirror.math.princeton.edu::pub/putty nfs/rsync/
rsync -avz --delete --safe-links mirror.us.leaseweb.net::opnsense /home/data/rsync/opnsense
```

## pypi 镜像

```bash
# 安装 bandersnatch
sudo pip install bandersnatch

# 尝试启动 bandersnatch
bandersnatch mirror  
# 返回没有 /etc/bandersnatch.conf 文件错误

# 创建 bandersnatch.conf 文件（文件内容如下）
[mirror]
directory = /srv/pypi
master = https://pypi.python.org

# 启动 bandersnatch
tmux
bandersnatch mirror
ctrl+b+d
# tmux 为终端会话工具，`ctrl+b+d` 让任务在后台执行

# 配置 web 服务器到同步路径
# web 服务的根目录为 `/srv/pypi/web`
# 在 linux 系统用户配置中修改 pypi 默认镜像

# 文件 ~/.pip/pip.conf
[global]
index-url = https://pypi.doubanio.com/simple/  （该地址修改为web服务器对应地址）
```

## 其他镜像

```bash
# 采用 wget 镜像 `nodejs.org` 站点
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent http://nodejs.org/dist  -e robots=off
```
