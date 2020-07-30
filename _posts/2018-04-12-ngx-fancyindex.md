---
layout: post
title: Nginx 目录列表美化
subtitle: 使用 Ngx-fancyindex 插件一键美化Nginx目录列表
date: 2018-04-12 15:26:35 +0800
tags: 
- nginx
- 目录列表
categories: tech
cover: https://images.unsplash.com/photo-1560613717-c793db79055e?w=1600&h=900
---

## 安装 Nginx

### CentOS系统

```bash
sudo yum install -y nginx
```

### Ubuntu系统

```bash
sudo tee -a /etc/apt/sources.list.d/nginx.list << EOF
deb http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -c --short) main 
deb-src http://ppa.launchpad.net/nginx/stable/ubuntu $(lsb_release -c --short) main 
EOF
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C
sudo apt install -y nginx
```

## 安装 Ngx-fancyindex 插件

下面的所有操作均以 Ubuntu 操作系统为例。

### 安装编译工具及依赖

```bash
sudo apt install build-esstenial libpcre3 libpcre3-dev libxslt1-dev libgd-dev libgeoip-dev
```

### 下载 Nginx 源码

```bash
# 查看 Nginx 版本及编译选项
nginx -V
# 返回为 1.12.2 版本

# 下载源码并解压
cd ~/downloads
wget -c https://nginx.org/download/nginx-1.12.2.tar.gz
tar zxf nginx-1.12.2.tar.gz
# 得到文件夹 nginx-1.12.2
```

### 下载插件源码

```bash
cd ~/downloads
wget -c https://github.com/aperezdc/ngx-fancyindex/archive/v0.4.2.tar.gz
tar zxf v0.4.2.tar.gz
# 得到文件夹  ngx-fancyindex-0.4.2
```

### 编译生成新的 Nginx

```bash
cd nginx-1.12.2
./configure --with-cc-opt='-g -O2 -fPIE -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-mail=dynamic --with-mail_ssl_module --add-module=../ngx-fancyindex-0.4.2

# 动态模块编译选项可以忽略

# 使用 -j12 参数来多核并行编译
make -j12

# 查看新生成的 nginx 二进制文件
ls objs

# 将原来的二进制文件备份，并使用新生成的文件替换
sudo mv /usr/sbin/nginx /usr/sbin/nginx.bak
sudo cp objs/nginx /usr/sbin/nginx
```

### 安装主题

```bash
# 下载主题
cd ~/downloads
git clone https://github.com/lanffy/Nginx-Fancyindex-Theme.git

# 将主题目录与目录列表所在根目录软连接一下
sudo ln -s ~/downloads/Nginx-Fancyindex-Theme /var/www/html/Nginx-Fancyindex-Theme

# 修改 Nginx 虚拟主机配置文件
server {
    listen 80;
    #listen [::]:80;
	server_name ftp.example.org;
	return 301 https://$host$request_uri;
}
server {
	listen 443;
	listen [::]:443;
	server_name ftp.example.org;
	ssl on;
	ssl_certificate /home/ubuntu/ssl/ftp.example.org.cert.pem;
	ssl_certificate_key /home/ubuntu/ssl/ftp.example.org.key.pem;
    root /var/www/html;
	index index.html;
    
    location / {
    	include /var/www/html/Nginx-Fancyindex-Theme/fancyindex.conf;
		autoindex_format html;
		charset utf-8,gbk;
	    disable_symlinks off;
    }
}
```