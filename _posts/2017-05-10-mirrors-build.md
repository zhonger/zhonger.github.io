---
layout: post
title: 镜像站构建
date: 2017-05-10 10:02:50 +0800
tags:
- mirror
- build
- rsync
- cran
- wget
- bandsnatch
categories: tech
cover: 'https://images.unsplash.com/photo-1464817739973-0128fe77aaa1?w=1600&h=900'
---
# 引言
构建镜像站主要是对于 linux开源平台的软件源、 pypi源、 cran源、 mysql等开源软件第三方源，大部分源支持使用 rsync 工具直接进行同步，少部分源比较特殊，比如 pypi 源必须采用官方提供的 bandsnatch 工具，mysql 源则只能采用 wget 的方式镜像整站。

# linux 镜像

采用`rsync`工具


# pypi 镜像

```bash
#安装bandersnatch
sudo pip install bandersnatch

#尝试启动bandersnatch
bandersnatch mirror  
#返回没有/etc/bandersnatch.conf文件错误

#创建bandersnatch.conf文件（文件内容如下）
[mirror]
directory = /srv/pypi
master = https://pypi.python.org

#启动bandersnatch
tmux
bandersnatch mirror
ctrl+b+d
#tmux为终端会话工具，`ctrl+b+d`让任务在后台执行

#配置web 服务器到同步路径
#web服务的根目录为`/srv/pypi/web`
#在linux系统用户配置中修改pypi默认镜像

#文件 ~/.pip/pip.conf
[global]
index-url = https://pypi.doubanio.com/simple/  （该地址修改为web服务器对应地址）
```

# 其他镜像

```bash
#采用wget镜像`nodejs.org`站点
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent http://nodejs.org/dist  -e robots=off
```
