---
layout: post
title: 使用caddy和apache搭建php环境
date: 2017-06-21 20:53:02 +0800
tags: caddy apache
categories: tech
cover: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1680&q=80'
---

# caddy篇
## 安装caddy

```bash
curl https://getcaddy.com | bash
```

## 配置Caddyfile

```bash
yun.wl27.cn {
    gzip
    proxy / http://127.0.0.1:10080
}

```

## 安装并配置supervisor

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


# 安装apache

```bash
sudo apt-get install apache2 
sudo a2enmod rewrite env headers mime dir setenvif
```

# php篇
## 安装php7.0

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
