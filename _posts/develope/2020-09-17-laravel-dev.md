---
layout: post
title: 'Laravel 开发和部署环境搭建'
subtitle: '利用 Valet 或传统的 Nginx+php-fpm 的方式'
date: 2020-08-12 13:51:45 +0800
categories: [tech, PHP]
author: zhonger
cover: 'https://i.lisz.top/cover/b4cfw5.webp'
cover_author: 'Danist Soh'
cover_author_link: 'https://unsplash.com/@danist07'
tags: 
- Laravel
- Valet
- Linux Mint
- Nginx
- php-fpm
---

## 前言

&emsp;&emsp;近来趁着 Ubuntu 20.04 发行版的发布，在台式机上安装了桌面版体验了一下。不知道是因为笔者的台式机（2016年组装的，CPU 还在 Intel 第4代）有点过于陈旧了，还是最新发行版的安装要求变高了，安装完成后总觉得使用起来不是很顺手。用着用着就死机了，键盘和鼠标完全失效。而且原来在 Ubuntu 上的美化操作也不是很好使了，因此就尝试了 Linux Mint 20 发行版（基于 Ubuntu 20.04）。自从安装完成后，体验下来还是比较顺畅，能够成功安装搜狗中文输入法、字体、主题、其他常用软件。于是就萌生了在 Linux Mint 上搭建 Laravel 开发环境的想法。

## Laravel

&emsp;&emsp;Laravel 是 PHP 领域内一大流行的 Web 应用框架，因开发成本低、依赖管理方便等优势深受国内外开发者的喜爱，有很多的应用案例。Laravel 官方提供了 Valet 工具专门用于 PHP 项目的开发环境管理，相当简单、强大。Valet 不但可以支持 Laravel，还可以支持 Zend、CakePHP 等多种 PHP 常用框架和 Wordpress 等多种 PHP 常用应用。以下会简要介绍该工具的配置使用。

&emsp;&emsp;在前几年撰写的 [《laravel 5.2 在 lnmpa 一键安装包环境下的部署》](/tech/laravel-lnmpa.html) 一文中，使用了 [lnmp.org](https://lnmp.org) 提供的一键 PHP 项目生产环境来开发和部署 Laravel。虽然说这种方式也是比较简单粗暴，可以利用脚本进行管理，后期的管理、配置成本都比较低，但是随着不断对各个基础环境的了解，可以自行对每个基础环境的进行单独配置和组合配置，这样的一键方式反而显得有不少冗余和复杂化。因此，此处想要介绍自行搭建 L(inux)+N(ginx)+M(ysql)+P(HP) 开发和部署环境。

## 基础环境配置

### 安装软件依赖

```bash
sudo apt update
sudo apt install -y libnss3-tools jq xsel wget curl
sudo apt install -y php7.4-cli php7.4-common php7.4-curl php7.4-json php7.4-mbstring php7.4-opcache
sudo apt install -y php7.4-readline php7.4-xml php7.4-zip php7.4-sqlite3 php7.4-mysql php7.4-pgsql
sudo apt install -y network-manager php7.4 php7.4-fpm nginx
```

### 配置 PHP

```bash
sudo vim /etc/php/7.4/fpm/php.ini

upload_max_filesize = 1024M
max_file_uploads = 20
# 取消下面一句的注释，并修改如下
cgi.fix_pathinfo=0
```

#### 安装 Composer

```bash
wget -c https://mirrors.aliyun.com/composer/composer.phar
chmod +x composer.phar
sudo mv composer.phar /usr/local/bin/composer
```

#### 验证 Composer 安装

```bash
composer diagnose

Checking platform settings: OK
Checking git settings: OK
Checking http connectivity to packagist: OK
Checking https connectivity to packagist: OK
Checking github.com rate limit: OK
Checking disk free space: OK
Checking pubkeys: 
Tags Public Key Fingerprint: 57815BA2 7E54DC31 7ECC7CC5 573090D0  87719BA6 8F3BB723 4E5D42D0 84A14642
Dev Public Key Fingerprint: 4AC45767 E5EC2265 2F0C1167 CBBB8A2B  0C708369 153E328C AD90147D AFE50952
OK
Checking composer version: OK
Composer version: 1.10.13
PHP version: 7.4.3
PHP binary path: /usr/bin/php7.4
OpenSSL version: OpenSSL 1.1.1f  31 Mar 2020
```

#### 配置 Composer 镜像

```bash
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
```

### 安装 MariaDB

```bash
sudo apt install -y mariadb-client mariadb-server
```

#### 启动 MariaDB

```bash
sudo systemctl enable mariadb
sudo systemctl start mariadb
```

#### 配置 MariaDB 的 root 用户密码

```bash
sudo mysql -u root
MariaDB [mysql]> UPDATE mysql.user SET password=password('newpassword') WHERE user='root';
MariaDB [mysql]> flush privileges;  
MariaDB [mysql]> exit;
```

#### 创建新数据库

```bash
mysql -p -u root

MariaDB [(none)]> CREATE DATABASE `blog` CHARACTER SET utf8 COLLATE utf8_general_ci;
MariaDB [(none)]> CREATE USER 'bloguser'@'%' IDENTIFIED BY 'password';
MariaDB [(none)]> use blog;
MariaDB [blog]> GRANT ALL ON `blog.*` TO 'bloguser'@'%';
MariaDB [blog]> FLUSH PRIVILEGES;
MariaDB [blog]> EXIT;
```

## 安装 Laravel

### 新建项目

```bash
mkdir -p ~/web && cd ~/web
composer global require laravel/installer
composer create-project --prefer-dist laravel/laravel blog "6.*"
```

### 配置文件夹权限

```bash
chmod -R 755 ~/web/blog
```

### 配置数据库

```bash
vim ~/web/blog/.env

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=blog
DB_USERNAME=bloguser
DB_PASSWORD=password
```

### 测试应用

```bash
cd ~/web/blog
php artisan serve --port=8000
```

&emsp;&emsp;浏览器访问 `http://localhost:8000`，`Ctrl+C` 停止测试。

## 安装和配置 Valet（二选一）

```bash
composer global require cpriego/valet-linux
tee -a ~/.zshrc << EOF
PATH=$PATH:/home/$(whoami)/.config/composer/vendor/bin
EOF
source ~/.zshrc
valet install
cd ~/web/blog && valet link blog
```

&emsp;&emsp;浏览器访问 `http://blog.test`。

```bash
valet secure blog
```

&emsp;&emsp;浏览器访问 `https://blog.test`。由于最近浏览器对于 SSL 证书提升了验证的要求，对于本地签发的证书会报不信任，可以手动选择信任后访问。

## 配置 Nginx+php-fpm （二选一）

### 配置文件夹链接

```bash
sudo ln -s ~/web/blog /var/www/blog
```

### 配置 Nginx

&emsp;&emsp;以下为 /etc/nginx/sites-avaiable/blog 的内容，其中 SSL 证书为 acme.sh 工具申请的 Let's Encrypt 提供的三个月免费通配符域名证书，`*.lisz.ml` 解析 IP 为 `127.0.0.1`。

```nginx
server {
    listen 80;
    root /var/www/blog/public;
    index  index.php index.html index.htm;
    server_name  blog.lisz.ml;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name blog.lisz.ml;
    ssl_certificate /home/zhonger/ssl/lisz.ml.cert.pem;
    ssl_certificate_key /home/zhonger/ssl/lisz.ml.key.pem;
    index index.php index.html index.htm;
    root /var/www/blog/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;        
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

  
    location ~ \.php$ {
       include fastcgi_params;
       fastcgi_index index.php;
       fastcgi_pass     unix:/var/run/php/php-fpm.sock;
       fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

}
```

&emsp;&emsp;未开启 HTTPS 的配置文件如下：

```nginx
server {
    listen 80;
    root /var/www/blog/public;
    index  index.php index.html index.htm;
    server_name  blog.lisz.ml;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;        
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

  
    location ~ \.php$ {
       include fastcgi_params;
       fastcgi_index index.php;
       fastcgi_pass     unix:/var/run/php/php-fpm.sock;
       fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

}
```

### Nginx 配置文件生效

```bash
sudo ln -s /etc/nginx/sites-avaiable/blog /etc/nginx/sites-enabled/
sudo nginx -t
sudo nginx -s reload
```

### 开启 php-fpm

```bash
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
```

### 验证

&emsp;&emsp;浏览器访问 `https://blog.lisz.ml`。

## 参考资料

- [How to Install Laravel 7 on Ubuntu 20.04 with Nginx and MariaDB](https://www.vultr.com/docs/how-to-install-laravel-7-on-ubuntu-20-04-with-nginx-and-mariadb)
- [Laravel PHP7 LEMP AWS.md](https://gist.github.com/santoshachari/87bf77baeb45a65eb83b553aceb135a3)
- [Laravel Installation](https://laravel.com/docs/6.x/installation)
- [Laravel Valet](https://laravel.com/docs/6.x/valet)
- [阿里云 Composer 全量镜像](https://developer.aliyun.com/composer?spm=a2c6h.13651102.0.0.3e221b11rDtKLh)
- [Ruby 中国镜像](https://gems.ruby-china.com/)
