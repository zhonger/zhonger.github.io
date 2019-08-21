---
layout: post
title: 使用 caddy 和 apache 搭建 php 环境
date: 2017-06-21 20:53:02 +0800
tags: caddy apache
categories: tech
cover: 'https://images.unsplash.com/photo-1552162679-446212964bfc?w=1600&h=900'
---

# caddy 篇
## 安装 caddy

```bash
curl https://getcaddy.com | bash
```

## 配置 Caddyfile

```bash
yun.wl27.cn {
    gzip
    proxy / http://127.0.0.1:10080
}

```

## 安装并配置 supervisor

```bash
sudo pip install supervisor

# /etc/supervisord.conf`
[program:caddy]
command=caddy -conf /root/Caddyfile
user=root
autostart=true
autorestart=true
startsecs=3
stderr_logfile=/tmp/caddy_err.log
stdout_logfile=/tmp/caddy.log

[supervisord]
```


# 安装 apache

```bash
sudo apt-get install apache2 
sudo a2enmod rewrite env headers mime dir setenvif
```

# php 篇
## 安装 php7.0

```bash
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.0
sudo apt-get install libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-json php7.0-common php7.0-gd php7.0-zip php7.0-xml php7.0-mbstring
```

## 配置虚拟主机

```bash
# /etc/apache2/sites-available


```

# 安装mysql
