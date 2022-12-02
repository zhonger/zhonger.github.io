---
layout: post
title: Letsencrypt 泛域名 SSL 证书免费申请
subtitle: 内网站点也可以轻松 HTTPS 化了
date: 2018-03-14 20:25:44 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/3ruY1v.webp'
cover_author: 'cheng feng'
cover_author_link: 'https://unsplash.com/@chengfengrecord'
tags:
- Letsencrypt
- ssl
- 泛域名
- 免费
---
## HTTPS 和 Let's encrypt 简介

&emsp;&emsp;超文本传输安全协议（英语：Hypertext Transfer Protocol Secure，缩写：HTTPS，常称为 HTTP over TLS，HTTP over SSL 或 HTTP Secure）是一种网络安全传输协议。在计算机网络上，HTTPS 经由超文本传输协议进行通信，但利用 SSL/TLS 来加密数据包。HTTPS 开发的主要目的，是提供对网络服务器的身份认证，保护交换数据的隐私与完整性。这个协议由网景公司（Netscape）在1994年首次提出，随后扩展到互联网上。

&emsp;&emsp;HTTPS 连接经常用于万维网上的交易支付和企业信息系统中敏感信息的传输，而如今在 Goolge 、 Mozilla 等大厂的联合推广下， HTTPS 已经成为了每一个站点的安全必备要素。

&emsp;&emsp;然而 HTTPS 要求在一层加密连接（TLS 或 SSL）上来进行常规的 HTTP 协议，因此搭建 HTTPS 站点必须要先获得一个 SSL 证书。 SSL 证书是经过所谓的国际顶级 CA 机构进行颁发，大部分情况下是需要支付一定的费用的。根据支付不同价格的费用，可以分别域名型 DV 、企业型 OV 和增强型 EV ，这个可以参考 [腾讯云 SSL 产品介绍](https://cloud.tencent.com/product/ssl) 来理解一下。

&emsp;&emsp;由于有了 Google 、 Mozilla 等大厂的 HTTPS 呼吁，他们也想能够提供给站点免费的 SSL 证书借此来提升大家迁移到 HTTPS 站点的热情，于是就有了非常著名的 Let's encrypt 这样一款非常好看又好玩的产品。 Let's encrypt 在发展之初仅支持向单域名或者多域名颁发一个证书、60 天有效期，每个证书最多包含 100 个域名，而且需要通过 DNS 解析记录和 HTTP 访问来验证域名的所有权，因此对于站点是否处于公网是有要求的。有人说站点不是都在公网上，难道连内网中的站点也要 HTTPS 化吗？其实如果按照之前的情况来看，内网站点 HTTPS 化只能采用曲线的方式实现。（用一台公网服务器来申请好证书，再将域名解析到内网并且部署证书在内网，这样的坏处就是始终需要通过这样一个方式来更新证书，十分麻烦。）于是，[certbot](https://certbot.eff.org) 这款优秀的工具就诞生了。certbot 支持大部分的 web 服务器（例如 Nginx、Apache 、Haproxy 等）和大部分的操作系统（Centos 系列、Debian 系列、Archlinux 等），不得不说是所有 Let's encrypt 衍生出的 SSL 证书申请工具的佼佼者。

&emsp;&emsp;在2018年3月，Let's encrypt 在很长一段时间的努力下，终于进一步缩小了 SSL 证书颁发的限制，已经支持颁发泛域名证书([原文](https://community.letsencrypt.org/t/acme-v2-and-wildcard-certificate-support-is-live/55579))。这样一来，在内网中部署 SSL 证书将不再受限，所有的要求只剩下一点----你对申请证书的域名具有所有权。在众多的 Let's encrypt SSL 证书申请工具中，[acme.sh](https://acme.sh) 一下子就脱颖而出了。`acme.sh` 支持通过 DNS 来验证域名所有权，因此你只需在指定域名时前面加上 `*` 就可以申请一枚免费的泛域名了。

## SSL 证书申请

&emsp;&emsp;下面我们将会以申请 `*.shu.aixinwu.org` 为例来讲一下这款工具的用法，真的是很清真。

### 申请泛域名

&emsp;&emsp;申请泛域名的第一步自然是安装 SSL 证书申请工具了，当然我们选用的是 `acme.sh`。

### 下载 acme.sh 工具

&emsp;&emsp;acme.sh 官方提供一个非常简单的一键安装脚本，老少皆宜。当然，安装这个工具对于是否在公网并没有任何要求，你可以选择在将要部署 SSL 证书的内网服务器中安装即可，请用**非root用户**全程执行命令。

```bash
# 安装acme.sh
curl https://get.acme.sh | sh

# 使acme.sh在bash中生效
source .bashrc 
```

### 提交泛域名

&emsp;&emsp;安装好`acme.sh`工具，就可以开始提交泛域名申请了，按照下面命令就可以使用 DNS 验证的方式来提交申请。结果会返回一个 TXT 记录新增的要求。

```bash
acme.sh --issue --dns -d shu.aixinwu.org -d *.shu.aixinwu.org --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

### 添加 DNS 记录

&emsp;&emsp;根据上一步返回的 TXT 记录添加要求，在相应的域名 DNS 服务提供商那里添加好对应的 TXT 记录即可。如下图所示。

![TXT 记录新增 Add TXT record](https://i.lisz.top/blog/bI1lze.webp)

### 生成泛域名证书

&emsp;&emsp;在添加好 TXT 记录之后，就可以使用更新命令来请求颁发泛域名证书。执行下面这条命令之后可以发现返回了生成的文件的本地路径。

```bash
acme.sh --renew -d shu.aixinwu.org -d *.shu.aixinwu.org --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

&emsp;&emsp;到此为止，泛域名证书已经申请完成，但是用于部署还有点小毛病。因为通过 DNS 申请生成的 SSL 证书的 key 和 cer 两个文件都不是标准的 pem 文件格式，在某些浏览器或者终端中会出现缺少中间 CA 机构证书的问题（尽管在大部分浏览器中是没有任何问题的，但是为了终端中不产生问题最好还是修复该问题），所以需要在正式部署之前生成好 pem 证书。

## 部署泛域名

&emsp;&emsp;这里以 Nginx 为例来展示部署泛域名的步骤。首先是通过 key 和 cer 文件来生成对应包含完整证书链的 pem 文件。

### 生成 pem 证书

&emsp;&emsp;acme.sh 工具自身就提供一键生成 pem 证书的方式，无须像网上很多博客中讲的通过 `openssl` 原生命令来转换文件。以下操作即可生成的 key 和 cert 的 pem 文件到用户主目录的 ssl 文件中。

```bash
acme.sh --install-cert -d shu.aixinwu.org \
--key-file /home/ubuntu/ssl/shu.aixinwu.org.key.pem \
--fullchain-file /home/ubuntu/ssl/shu.aixinwu.org.cert.pem 
```

### 添加到 Nginx 中

&emsp;&emsp;以下为 Nginx 文件文件示例。

```nginx
server
    {
        listen 80;
        listen [::]:80;
        server_name shu.aixinwu.org *.shu.aixinwu.org;
        return 301 https://$host$request_uri;
    }

server
    {
        listen 443;
        listen [::]:443;
        server_name shu.aixinwu.org *.shu.aixinwu.org;
        ssl on;
        ssl_certificate /home/ubuntu/ssl/shu.aixinwu.org.cert.pem;
        ssl_certificate_key /home/ubuntu/ssl/shu.aixinwu.org.key.pem;
        index index.html index.htm index.php default.html default.htm default.php;
        root  /home/wwwroot/shu.aixinwu.org;

        location /
        {
            try_files $uri @apache;
        }

        location @apache
        {
            internal;
            proxy_pass http://127.0.0.1:89;
            include proxy.conf;
        }

        access_log  /home/wwwlogs/shu.aixinwu.org.log  access;
    }
```

## 总结

&emsp;&emsp;虽然通过这样的方式我们成功实现了免费申请内网 SSL 泛域名证书，但是经过实践发现，目前 Let's encrypt 所提供的泛域名证书只能支持到最近一级通配。比如说，现在申请的是 `*.shu.aixinwu.org` ，如果站点域名为 `www.t.shu.aixinwu.org` 即被判别为无效域名，像 `www.shu.aixinwu.org` 即可认定为合法 SSL 证书。其实因为这种泛域名证书目前并没有提出任何限制，我们可以多级通配就申请多个即可。
