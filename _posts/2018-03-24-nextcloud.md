---
layout: post
title: Nextcloud 搭建自己的云盘
subtitle: Docker 搭建 or LNMPA 搭建 随你选
date: 2018-03-24 16:49:44 +0800
categories: [tech, docker]
author: zhonger
cover: 'https://i.luish.cc/cover/gLQGHs.webp'
cover_author: 'Andre Furtado'
cover_author_link: 'https://unsplash.com/@andre_furtado'
tags:
- Nextcloud
- docker
- lnmpa
- 云盘
---

## Nextcloud 简介

&emsp;&emsp;今年来，国内众多免费网盘相继倒下，于是大家都转投了百度网盘门下，然而这只独角兽限速倒逼开通会员下载速度依旧很难改善，还能维持多久也一直都是一个未知数。也有部分人开始涌向国外的有免费额度的网盘，比如以前以数据安全保障出名的 [Mega](https://mgea.nz) （由于核心人员出走最近好像也不行了）、微软的 [OneDrive](https://onedrive.live.com)、老牌网盘 [Dropbox](https://www.dropbox.com)、[Box](https://box.com)、谷家的 [Google drive](https://drive.google.com)（除了微软的网盘其他几个网速都不怎么好）。在这么多产品中，一个计算机技术人员却难以选择一款合适的网盘，于是用 VPS 和对象存储搭建自托管的方案开始成为一种可行的方案。Nextcloud 就是这样一款网盘，来源于 Owncloud 却较之更加强大、安全（集成 Office 文档、图片相册、日历、RSS 阅读，几乎等同于一个私有的 Dropbox），搭建也是非常简单，适合大部分技术栈的技术人员。当然，此处先谈如何搭建 Nextcloud，至于结合对象存储下回再说。

&emsp;&emsp;Docker 部署软件的好处我就不多提了：简单、高效，极其适合运维人员的应用管理工具。下面就先谈使用 Docker 一键搭建 Nextcloud。

### 安装 Docker 环境

&emsp;&emsp;请移步 [《Docker 入门》](/tech/docker-init.html)

### 安装 docker-compose 工具

&emsp;&emsp;docker-compose 是一个由 Docker 官方提供的应用多容器搭配管理工具，适合一个应用需要多个容器配合统一管理，进一步简化部署、升级步骤。

```bash
# 安装 python3 python3-pip
sudo apt install -y python3 python3-pip

# 安装 docker-compose
sudo pip3 install docker-compose
```

### 编写 docker-compose.yml

&emsp;&emsp;docker-compose 的管理主要依赖于一个名为 `docker-compose.yml` 的 yaml 文件来进行管理，当然这个文件也可以以任何别的名称并以 `-f 文件名` 的方式来启用，但必须是符合 yaml 格式和 Docker 官方定义的字段和方式。以下为本实验所需的内容，其中用到了 mariadb 官方提供的数据库容器 和 Nextcloud 官方提供的应用容器。

```yaml
version: '2'

services:
  db:
    image: mariadb
    restart: always
    volumes:
      - /home/data/nextcloud/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASSWORD=nextcloud
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:  
    image: nextcloud
    restart: always
    ports:
      - 7009:80
    links:
      - db
    volumes:
      - /home/data/nextcloud/www:/var/www/html
```

### 启动容器

&emsp;&emsp;以下命令即可开始拉取所需容器的镜像文件并根据 docker-compose.yml 文件配置好本地文件夹挂载和端口映射。

```bash
# 启动容器
sudo docker-compose up -d

# 更新nextcloud
sudo docker pull nextcloud
sudo docker-compose down && sudo docker-compose up -d
```

&emsp;&emsp;然后 Nextcloud 就在 7009 端口（可自行修改 docker-compose.yml 文件来改变）开启好了，使用浏览器访问 `http://IP:7009` 。

### 应用初始化配置

&emsp;&emsp;自行设置管理员用户名和密码，数据目录默认即可，数据库信息填写如 docker-composer.yml 中所示，数据库主机名填 db （配置文件中的数据库应用名）。

![初始化示意图 Initialize](https://i.luish.cc/blog/aG3Ax6.webp)

&emsp;&emsp;所有初始化配置填写完毕之后，等待大约半分钟左右安装完成就可以看见 nextcloud 的主目录页面。到此处，Docker 搭建 Nextcloud 应用就大功告成了（也可在 80 端口安装 Nginx 服务代理到 7009 端口，此处不加赘述）。

## LNMPA 搭建 Nextcloud

&emsp;&emsp;本实验采用 Ubuntu 操作系统为例，其他 Linux 操作系统可以根据系统不同类比操作，操作步骤基本一致。

### 安装 LNMPA 环境

#### 为什么选用 LNMPA 而非 LNMP 或者 LMPA架构

&emsp;&emsp;LNMPA 的含义：

- `L`： Linux操作系统
- `N`： Nginx web服务器软件
- `M`： MySQL、Mariadb等类MySQL数据库软件
- `P`： PHP编译环境
- `A`： Apache服务

&emsp;&emsp;LNMPA 相比其他两种架构的优势在于充分发挥了 Nginx 和 Apache 的功能优势，即 Nginx 擅长提供静态文件服务、代理 HTTP 请求服务、Apache 擅长对于动态编程语言的结合接管编译工作。

#### 安装

&emsp;&emsp;[LNMP.org](https://lnmp.org) 提供一键式的环境安装脚本，所有软件均从各种软件官方下载源码编译安装，软件升级也相当方便。如果你的CPU 核数不够的话，那么第一次安装的时候编译可能需要花很长一段时间。

```bash
# 建议使用 tmux 来管理后台任务
sudo apt install -y tmux

# 新建一个后台session
tmux new -s lnmpa
# ctrl+b+d 将任务放到后台
# tmux attach -t lnmpa 进入后台session

# 下载一键安装包
wget -c http://soft1.vpser.net/lnmp/lnmp1.4-full.tar.gz

# 解压压缩包
tar zxf lnmp1.4-full.tar.gz 

# 执行安装程序
cd lnmp1.4-full
sudo ./install.sh lnmpa

# 安装完成后可以通过 http://IP 直接访问
```

### 准备工作

#### 新建数据库

&emsp;&emsp;使用 LNMPA 带的 phpMyadmin 可以直接新增数据库，比如数据库名为 nextcloud，分配用户名和密码均为 nextcloud。

#### 安装 PHP 扩展

```bash
# 进入 lnmpa 一键安装包文件夹的 php 的 fileinfo 扩展源码目录
cd ～/lnmp1.4-full/src/php-7.1.4/ext/fileinfo

# 从源码编译 fileinfo 扩展到 php 配置中
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && sudo make install

# 查看 fileinfo 是否启动
 php -i | grep fileinfo
```

#### 修改 Nginx 和 PHP 配置

```bash
# /usr/local/nginx/conf/nginx.conf
# 修改下面一行参数为10240m(10G)，增加上传最大文件大小
client_max_body_size 10240m;

# /usr/local/php/etc/php.ini
# 添加下面一行，以生效fileinfo扩展
extension = fileinfo.so

# 重启服务使配置生效
sudo lnmp restart
```

### 安装 Nextcloud

#### 下载 Nextcloud 代码

```bash
# 下载 Nextcloud 源码
wget -c https://download.nextcloud.com/server/releases/nextcloud-13.0.1.zip

# 解压源码
unzip nextcloud-13.0.1.zip

# 将源码拷贝至 wwwroot 目录
sudo cp -r nextcloud /home/wwwroot/nextcloud
sudo chown -R www:www /home/wwwroot/nextcloud
```

#### 添加虚拟主机

&emsp;&emsp;一种方式是使用 `lnmp vhost add` 的方式来添加（要求要域名，一步一步设置即可），另一种是直接添加文件，下面给出后一种方法无需域名的配置文件。

```nginx
# /usr/local/nginx/conf/vhost/default

server
    {
        listen 80;
        listen [::]:80;
        server_name default;
        index index.html index.htm index.php default.html default.htm default.php;
        root  /home/wwwroot/nextcloud;

        #error_page   404   /404.html;
        include proxy-pass-php.conf;

        location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
        {
            expires      30d;
        }

        location ~ .*\.(js|css)?$
        {
            expires      12h;
        }

        location ~ /\.
        {
            deny all;
        }

        access_log  /home/wwwlogs/nextcloud.log;
    }
```

```apacheconf
# /usr/local/apache/conf/vhost/default

<VirtualHost *:88>
ServerAdmin webmaster@example.com
php_admin_value open_basedir "/home/wwwroot/nextcloud:/tmp/:/var/tmp/:/proc/:Data将要放置目录的绝对路径:/dev/urandom"
DocumentRoot "/home/wwwroot/nextcloud"
ServerName default
ErrorLog "/home/wwwlogs/nextcloud-error_log"
CustomLog "/home/wwwlogs/nextcloud-access_log" combined
<Directory "/home/wwwroot/nextcloud">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
```

&emsp;&emsp;使用 `sudo lnmp restart` 重启服务生效，接着即可通过浏览器访问 `http://IP` 或者 `http://域名` 来访问。

### 配置 Nextcloud

&emsp;&emsp;自行设置管理员用户名和密码，数据目录可任意选择一处有权限的目录即可（默认的应为 /home/wwwroot/nextcloud/data，建议填一个非源代码的目录便于版本更新，比如 /home/data/nextcloud，要求所属用户和用户组为 www-data），数据库信息均填写 nextcloud，数据库主机名默认填 localhost。

![初始化示意图](https://i.luish.cc/blog/aG3Ax6.webp)

&emsp;&emsp;所有初始化配置填写完毕之后，等待大约半分钟左右安装完成就可以看见nextcloud的主目录页面。到此处， `LNMPA` 搭建 `Nextcloud` 应用就完成了，不过更新应用版本的话就更麻烦一点了。

### 更新 Nextcloud

&emsp;&emsp;这种方式安装的 Nextcloud 也需要通过源代码更新的方式来更新，以下为主要步骤。

```bash
# 备份原来的源代码
sudo mv /home/wwwroot/nextcloud /home/wwwroot/netxcloud-old/

# 下载最新的源代码
wget -c https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
cd nextcloud
sudo cp -r nextcloud /home/wwwroot/nextcloud
sudo chown -R www:www /home/wwwroot/nextcloud

# 应用更新
cd /home/wwwroot/
sudo cp nextcloud-old/config/config.php nextcloud/confi/config.php

cd /home/wwwroot/nextcloud
sudo -u www /usr/local/php/bin/php occ maintenance:mode --on
sudo -u www /usr/local/php/bin/php occ upgrade
sudo -u www /usr/local/php/bin/php occ maintenance:mode --off
```
