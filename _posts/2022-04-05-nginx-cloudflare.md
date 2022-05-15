---
layout: post
title: '给 Nginx 站点套上一层 Cloudflare '
subtitle: '如何通过 Cloudflare 来提升 Nginx 站点访问速度'
date: 2022-04-05 15:44:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://images.unsplash.com/photo-1649017049683-94ddea424f46?w=1600&q=900'
tags:  
- Nginx
- Cloudflare
- 加速
---

## 前言

&emsp;&emsp;站点访问速度及安全一直以来都是站长们建站所关注的重要内容。为了满足站点能够被全球用户的访问需求，通常我们会采用云服务商提供的 CDN 来加速访问速度。比如国外比较知名的 AWS 提供的 [Cloudfront](https://aws.amazon.com/cn/cloudfront/)、GCP 提供的 [Cloud CDN](https://cloud.google.com/cdn) 以及 Cloudflare 公司提供的 [Cloudflare](https://www.cloudflare.com/) 等，国内比较知名的腾讯云提供的 [CDN](https://cloud.tencent.com/product/cdn)、阿里云提供的 [CDN](https://cn.aliyun.com/product/cdn)、又拍云提供的 [CDN](https://www.upyun.com/products/cdn) 以及七牛云提供的 [CDN](https://www.qiniu.com/products/qcdn) 等。(PS：其实国内的其他云服务商比如华为云、百度云、滴滴云、京东云等等都提供了 CDN 解决方案。)

&emsp;&emsp;CDN 除了常规的多地、多节点缓存加速之外，还可以清洗流量，从而预防和对抗 DDoS 攻击。如果我们购买的服务器不是固定带宽、流量无限，而是大带宽、流量按量付费的话，遇到 DDoS 就会受到很大损失。DDoS 攻击不仅会让服务器上的服务无法正常响应请求，从而造成 Nginx 或 Apache 服务过饱和，甚至服务器宕机，还会产生很大的无效入站流量消耗。一般来说，流量按量计费是对入站流量进行计费。这样一来，光流量这一项的经济损失就可能会是非常庞大的数字。

&emsp;&emsp;当我们给 Nginx 站点套上一层 Cloudflare 或者其他 CDN 服务之后，用户访问服务时会先经过 Cloudflare。Cloudflare 免费版就具有清洗流量的功能：当 Cloudflare 发现流量来自僵尸网络或者异常流量请求时，就会拒绝响应或者只响应某些请求，而这些请求也会转给真实的服务器进行响应。从这里也可以看出来，用上 Cloudflare 之后，用户根本不知道真实服务器的 IP 地址或其他信息，能进一步保障服务器的安全。

&emsp;&emsp;这里，为了在实际的应用场景中来实践，特地选取了适合个人搭建的个人短地址服务 [Yourls](https://yourls.org)。

## 实践

### Yourls

#### 简介

&emsp;&emsp;Yourls （**Y**our **O**wn **URL** **S**hortener） 是一款基于 PHP 的允许你运行自己的短地址服务的免费和开源的软件。你可以完全控制你的数据、详细的统计和分析、插件以及更多。以下是源代码和官方推荐插件的仓库：

- [YOURLS/YOURLS](https://github.com/YOURLS/YOURLS)
- [YOURLS/awesome-yourls](https://github.com/YOURLS/awesome-yourls)

#### 部署

&emsp;&emsp;为了更加快速地部署 Yourls 服务，这里选用 docker-compose 的方式进行部署。以下是配置文件内容：

```yaml
# docker-compose.yml
version: '3.1'

services:

  yourls:
    image: yourls
    restart: always
    ports:
      - 8080:80
    environment:
      YOURLS_DB_PASS: abcdefgh
      YOURLS_SITE: https://url.com
      YOURLS_USER: admin
      YOURLS_PASS: admin@2022

  mysql:
    image: mysql:5.7
    restart: always
    volumes:
      - ./db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: abcdefgh
      MYSQL_DATABASE: yourls
```

&emsp;&emsp;Yourls 的官方 Docker 镜像提供了多种服务方式和体系架构，如下图所示。如果使用的服务器体系架构不同，对应的 mysql 镜像也应做出更改。比如，如果服务器是 IBM 的 s390x 架构，就可以选 [ibmcom/mysql-s390x:5.7.34](https://hub.docker.com/ibmcom/mysql-s390x)。

![Yourls Dockerhub](https://i.lisz.top/blog/q0AAZg.webp)

&emsp;&emsp;编辑完配置文件后执行以下命令启动 Yourls 服务：

```bash
docker-compose up -d
```

### Cloudflare 配置

- 访问 [Cloudflare 控制台](https://dashcloudflare.com)，选择进入已添加的域名操作面板。

#### 添加域名记录

- 进入 **DNS** 面板，点击**添加记录**按钮。
- 采用 A 记录或 CNAME 记录类型，这里的代理状态一定要像现在这样打开，否则 Cloudflare 将不会被启用。

![添加域名 Add DNS record](https://i.lisz.top/blog/tQK16A.webp)

#### 生成证书

- 进入 **SSL/TLS** 的 **源服务器** 面板，点击**创建证书**按钮。

![创建证书 Create certs](https://i.lisz.top/blog/gIMUvW.webp)

- 使用默认配置点击**创建**按钮即可。

![添加主机名 Add hosts](https://i.lisz.top/blog/pituGT.webp)

- 然后新的证书和私钥就生成了。需要注意的是，以下的私钥只能在生成时看到，证书可以之后也能看到，所以这里一定要复制好如下框内的源证书和私钥的内容。可以分别保存为 url.com.pem 和 url.com.key 文件。

![保存证书 Save certs](https://i.lisz.top/blog/2CAEBX.webp)

- 保存完成后，点击**确定**按钮结束操作。

#### 部署证书

&emsp;&emsp;可以使用以下命令远程拷贝源证书和私钥到目标服务器，或者刚才直接保存在目标服务器上。

```bash
scp url.com.* nginx:/home/ubuntu/ssl/
```

### Nginx 配置

#### 添加配置

&emsp;&emsp;在 Nginx 配置目录 /etc/nginx/sites-available 下新增 yourls 配置文件（需使用 sudo 权限方可新增），配置文件内容如下所示：

```nginx
# /etc/nginx/sites-available/yourls

server {

  listen   443 ssl http2;

  ssl_certificate    /home/linux1/ssl/url.com.pem;
  ssl_certificate_key    /home/linux1/ssl/url.com.key;

  server_name url.com;
  index index.php index.html index.htm;

  access_log /var/log/nginx/yourls.access.log;
  error_log /var/log/nginx/yourls.error.log;

  location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host $proxy_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

#### （可选）只允许 Cloudflare 访问

&emsp;&emsp;为了进一步确保真实服务器只响应来自 Cloudflare 转发的请求，我们可以在 Nginx 的配置文件中增加对于允许访问 IP 地址的限制。如下配置文件中的 IPv4/IPv6 的 IP 地址段均来自 Cloudflare 官方声明。此 cf.conf 文件放置在 /etc/nginx 目录下。

```nginx
# cf.conf
# https://www.cloudflare.com/ips
# IPv4
allow 103.21.244.0/22;
allow 103.22.200.0/22;
allow 103.31.4.0/22;
allow 104.16.0.0/12;
allow 108.162.192.0/18;
allow 131.0.72.0/22;
allow 141.101.64.0/18;
allow 162.158.0.0/15;
allow 172.64.0.0/13;
allow 173.245.48.0/20;
allow 188.114.96.0/20;
allow 190.93.240.0/20;
allow 197.234.240.0/22;
allow 198.41.128.0/17;

# IPv6
allow 2400:cb00::/32;
allow 2606:4700::/32;
allow 2803:f800::/32;
allow 2405:b500::/32;
allow 2405:8100::/32;
allow 2a06:98c0::/29;
allow 2c0f:f248::/32;
```

&emsp;&emsp;另外，如要启用该配置文件，需在刚才写好的站点配置文件 yourls 中再增加两行来使其生效，内容如下所示:

```nginx
server {
    ...
    
    include cf.conf;
  deny all;
}
```

#### 生效配置

```bash
sudo ln -s /etc/nginx/sites-available/yourls /etc/nginx/sites-enabled/yourls
sudo nginx -s reload
```

## 验证

&emsp;&emsp;访问 [https://url.com/install.php](https://url.com/install.php) 确认是否正常访问 Yourls 的安装初始化界面，如下所示。点击 **Install YOURLS** 按钮即可完成安装。

![Yourls](https://i.lisz.top/blog/bQwdsu.webp)

## 参考资料

- [如何在 Ubuntu 20.04 上使用 Cloudflare 和 Nginx 托管网站](https://www.gingerdoc.com/tutorials/how-to-host-a-website-using-cloudflare-and-nginx-on-ubuntu-20-04)
- [让 Nginx 只允许 Cloudflare 反向代理流量以隐藏源站](https://nova.moe/nginx-block-non-cloudflare-ips/)
