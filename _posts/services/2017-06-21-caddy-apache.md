---
layout: post
title: 使用 Caddy 和 Apache 搭建 PHP 环境
subtitle: 用 Caddy 来替代 Nginx 效果会怎样？
date: 2017-06-21 20:53:02 +0800
categories: [tech, PHP]
author: zhonger
cover: 'https://i.lisz.top/cover/V7dOou.webp'
cover_author: 'Charlie Green'
cover_author_link: 'https://unsplash.com/@charliegreen998'
tags: 
- caddy 
- apache
---

## caddy 篇

### 安装 caddy

```bash
curl https://getcaddy.com | bash
```

### 配置 Caddyfile

```bash
yun.lisz.me {
    gzip
    proxy / http://127.0.0.1:10080
}
```

### 安装并配置 supervisor

```bash
# 安装 superviosr
sudo pip install supervisor
```

```conf
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

### 安装 apache

```bash
sudo apt-get install -y apache2 
sudo a2enmod rewrite env headers mime dir setenvif
```

## php 篇

### 安装 php7.0

```bash
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php7.0
sudo apt-get install -y libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-json 
sudo apt-get install -y php7.0-common php7.0-gd php7.0-zip php7.0-xml php7.0-mbstring
sudo systemctl restart apache2.service
```

### 配置虚拟主机

```apacheconf
# /etc/apache2/sites-available/yun.conf
<VirtualHost *:10080>
    DocumentRoot "/var/www/yun"
    ServerName yun.lisz.me
    <Directory "/var/www/yun">
        Options Indexes FollowSymLinks Includes ExecCGI
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
```

```bash
# 使配置生效
sudo ln -s /etc/apache2/sites-available/yun.conf /etc/apache2/sites-enabled/yun.conf
sudo systemctl restart apache2.service
```

## Mysql 篇

### 安装 mysql

```bash
sudo apt install mariadb-server mariadb-client -y
```

### 配置 mysql

```bash
# 设置开机启动
sudo systemctl enable mariadb.service
# 设置一些安全问题
sudo mysql_secure_installation
# 然后按照下面的问题进行设置，目前是没有设置密码的，所以直接回车进入下一步：
Enter current password for root (enter for none):
# 回车设置新的数据库密码：
Set root password? [Y/n]
# 输入新的密码并确认：
New password:
Re-enter new password:
Password updated successfully!
# 输入回车移除匿名用户：
Remove anonymous users? [Y/n]
# 输入回车禁止远程 root 用户登陆：（此处可以选择 n 允许 root 用户远程连接）
Disallow root login remotely? [Y/n]
# 输入回车移除测试数据库：
Remove test database and access to it? [Y/n]
# 输入回车进行重载：
Reload privilege tables now? [Y/n]
```

&emsp;&emsp;以上就完成了数据库的安全设置。
