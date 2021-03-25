---
layout: post
title: Onlyoffice 搭建
subtitle: 使用 Docker 搭建 Onlyoffice 如此轻松愉快
date: 2018-04-01 18:10:35 +0800
tags: 
- onlyoffice
- docker
categories: [tech, docker]
cover: https://images.unsplash.com/photo-1561572639-773635958b8f?w=1600&h=900
---

## Onlyoffice 搭建

### 安装 Docker

&emsp;&emsp;请移步 [Docker入门](/tech/docker-init.html)

### 安装 Onlyoffice

```bash
docker run -i -t -d --restart=always -p 7010:80 onlyoffice/documentserver
```

### 配置 Nginx 代理

&emsp;&emsp;主要是 onlyoffice 目前有部分内容是通过 websocket 进行通信的，并非完全是 http 代理。
```bash
#/usr/local/nginx/conf/vhost/onlyoffice or /etc/nginx/site-available/onlyoffice

map $http_host $this_host {
    "" $host;
    default $http_host;
}

map $http_x_forwarded_proto $the_scheme {
     default $http_x_forwarded_proto;
     "" $scheme;
}

map $http_x_forwarded_host $the_host {
    default $http_x_forwarded_host;
    "" $this_host;
}

map $http_upgrade $proxy_connection {
  default upgrade;
  "" close;
}


server{
    listen 80;
    #listen [::]:80;
    server_name onlyoffice;
    index index.html index.htm index.php default.html default.htm default.php;
    root  /home/wwwroot/onlyoffice;

    location /
    {
        try_files $uri @apache;
    }

    location @apache
    {
        internal;
        proxy_pass http://127.0.0.1:7010;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $proxy_connection;
        proxy_set_header X-Forwarded-Host $the_host;
        proxy_set_header X-Forwarded-Proto $the_scheme;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
    }

    access_log  /home/wwwlogs/onlyoffice.log  access;
}
```