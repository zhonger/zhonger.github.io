---
layout: post
title: 'LDAP 集成之 Apache 篇'
subtitle: '利用 LDAP 为 Apache 提供用户认证服务'
date: 2022-06-21 13:24:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.luish.cc/cover/c7e20u.webp'
cover_author: 'Mel Poole'
cover_author_link: 'https://unsplash.com/@melpoole'
tags:  
- LDAP
- Apache
---

## 前言

### Apache

&emsp;&emsp;Apache HTTP 服务器作为当今流行的几大 HTTP 服务器之一，几乎占据了半壁江山。与知名的Nginx（现已被 F1 收购）、微软的 IIS 相比，Apache 具有更好的模块化支持，无论是从服务端的编程语言还是到身份认证方案。Apache 支持 Perl、Python、PHP 等常用服务端语言，同时也支持 Basic 认证、LDAP 认证、OAuth 2.0 等。尤其是 LAMP（Linux+Apache+MySQL+PHP）集成环境已经成为了虚拟主机的首选。当然，也有提供 ASP 虚拟主机环境的。

### Apache 与博客发展

&emsp;&emsp;实际上，在博客兴起的初期，大部分博客是最简单的静态页面。而随着服务器端语言的发展，开始有了基于 ASP.net 或 PHP 的博客开源程序，例如最为流行的 WordPress 就是基于 PHP 编写的。在笔者学习博客的初期，也是使用了 WordPress 和 PHP 虚拟主机来搭建自己的博客。可以说，PHP 或 ASP 集成环境在相当一段时间内可能都是最好的博客或者网站解决方案。但随着云服务、无服务计算、Git 等的兴起，以 Git 为中心的持续集成、持续部署的方式越来越成为了搭建个人静态博客的首选。这也反映了博客发展的动态变化过程：**静态博客→动态博客→静态博客**。

&emsp;&emsp;以 Github Page、Gitlab Page、Netlify、Vercel、Cloudflare Page 等为代表的静态站点部署方式越来越受到大家的喜爱，现在大部分大公司的文档都已经转变为这种方式，比如 Azure 的官方文档、Cloudflare 的官方文档、腾讯云的官方文档等。这样一种方式不仅有利于开发的快速迭代，还有利于吸引大众参与到文档的贡献与纠错中来，可以使文档越来越好。当然，这其实就是“开源”的思想。那这是不是就意味着 Apache 对静态网站变得不那么有用了呢？当然不是。Apache 所支持的认证模块、日志模块、重写模块、代理模块等对静态网站也非常重要。

### Apache 对文档的妙用

&emsp;&emsp;现在的开发文档大部分都已经采用 Git+Markdown+SSG（Static Site Generator，静态站点生成器）的方式进行开发部署。对于团队内部的文档可能常常会有权限限制和访问记录的需求，甚至说如果有共享文件，也希望能够知道是谁下载了、在什么时候下载了。如果以后端编程的角度来想，可能需要开发一套系统专门实现验权、访问记录、下载记录、数据统计等功能。即使如此，当有多个文档需要集成到一起时，这种解决方案仍然有点困难了。所以付出了相当的代价，而所获取的收益却不是很明显。针对这一需求，基于 Apache 可以有更加简便的方案，如下图所示：

![基于 Apache 的文档方案 Solutions based on Apache](https://i.luish.cc/blog/4hsLnz.webp)

&emsp;&emsp;如上图所示，基于 Apache 的解决方案主要包含以下三点：

1. 利用 Apache 与 LDAP 或其他用户系统集成来验证权限；
2. 利用 Apache 的日志功能来记录所有验权动作以及用户行为；
3. 利用 Apache 的重写模块和代理模块将所有文档集中在一个域名的不同子目录下。

## 实践

&emsp;&emsp;为了尽可能简单地实现一下上面所提到的基于 Apache 的文档解决方案，这里采用了 Docker 镜像的方式。

### 环境准备

- Docker 环境（推荐 Linux 或 Mac）
- 已安装 docker-compose 工具

### 配置文件准备

&emsp;&emsp;如需自行构建 Docker 镜像，请将以下三个配置文件放置在 conf 子目录中。如直接使用下面笔者构建的 [zhonger/ldap-apache](https://hub.docker.com/r/zhonger/ldap-apache) 镜像，可以忽略。

#### LDAP 验证定义

```apacheconf
# ldap-demo.conf

<AuthnProviderAlias ldap demo>
  AuthLDAPBindDN ${LDAP_BindDN}
  AuthLDAPBindPassword ${LDAP_BindPass}
  AuthLDAPURL ${LDAP_URL}
  Require ldap-group ${LDAP_BindGroup}
</AuthnProviderAlias>
```

#### 激活 LDAP 验证

```apacheconf
# .htaccess

AuthBasicProvider demo
AuthType Basic
AuthName "Protected Area"
Require valid-user
```

#### 重写 Apache 配置文件

```apacheconf
# apache2.conf

DefaultRuntimeDir ${APACHE_RUN_DIR}

PidFile ${APACHE_PID_FILE}

Timeout 300

KeepAlive On

MaxKeepAliveRequests 100

KeepAliveTimeout 5

User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

HostnameLookups Off

ErrorLog ${APACHE_LOG_DIR}/error.log

LogLevel warn

# Include module configuration:
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

# Include list of ports to listen on
Include ports.conf

<Directory />
    Options FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>

<Directory /usr/share>
    AllowOverride None
    Require all granted
</Directory>

<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

AccessFileName .htaccess

<FilesMatch "^\.ht">
    Require all denied
</FilesMatch>

LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

IncludeOptional conf-enabled/*.conf
IncludeOptional sites-enabled/*.conf
```

### Apache 子目录设置

&emsp;&emsp;之前提到如果有多个文档分别以多个 Git 项目存在，那么最终编译成的静态文件也是分别存放或者分别部署。这里介绍两种子目录的形式：**目录假名（Alias）**和**代理（Proxy）**。

#### 目录假名

&emsp;&emsp;目录假名比较简单，我们可以直接使用以下配置实现方案图中的各个文档目录：

```apacheconf
...
Alias "/dvm/" "/var/www/dvm/"
Alias "/ds3/" "/var/www/ds3/"
Alias "/dgit/" "/var/www/dgit/"
Alias "/dml/" "/var/www/dml/"
Alias "/dnc/" "/var/www/dnc/"
...
<Directory /var/www/>
...
```

&emsp;&emsp;由于下面构建的镜像仍采用了上面的 Apache 配置文件，所以不包含以上目录假名设置。如有需要，可以按照上面给出的顺序将目录假名设置加入到新的 apache2.conf 文件中，并且在 docker-compose.yml 文件中如下所示挂载新的 apache2.conf 文件即可生效。

```yaml
...
      volumes:
        - ./data:/var/www/
        - ./logs:/var/log/apache2/
        - /etc/localtime:/etc/localtime
        - ./apache2.conf:/etc/apache2/apache2.conf
...
```

#### 代理

&emsp;&emsp;下面的构建镜像 Dockerfile 中将会预先启用代理模块，由于可能会代理 HTTPS 端口，所以 HTTP 模块和 SSL 模块也预先启用了。除此之外，如果需要代理 HTTPS 站点，就要像下面一样开启 SSLProxyEngine 配置，否则只能完成 HTTP 代理。代理配置的第二行是“ProxyPass+子目录+代理 URL”。

> info "小提示"
> 需要注意的是应该把**代理配置**放在**目录配置**之前。

```apacheconf
...
SSLProxyEngine On
ProxyPass /foo https://foo.example.com
...
<Directory /var/www/>
...
```

### 构建镜像

&emsp;&emsp;Docker 镜像的构建实际上就是要做这么几件事：

- 复制三个配置文件到容器镜像中
- 启用 LDAP 认证模块
- 准备好日志目录和默认日志文件

```docker
FROM php:7-apache

LABEL maintainer="zhonger zhonger@live.cn"

# Enable ldap for apache2
COPY conf/ldap-demo.conf /etc/apache2/conf-available/ldap-demo.conf

RUN a2enmod authnz_ldap proxy proxy_http ssl && \
    ln -s /etc/apache2/conf-available/ldap-demo.conf /etc/apache2/conf-enabled/ldap-demo.conf

COPY conf/.htaccess /var/www/html/
COPY conf/apache2.conf /etc/apache2/apache2.conf

# Save logs for apache
RUN rm /var/log/apache2/* && \
    cd /var/log/apache2/ && \
    touch access.log error.log

# Remove cache
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 80
```

&emsp;&emsp;当准备好配置文件和上面的 Dockerfile 文件时，执行 `docker build . -t zhonger/ldap-apache` 命令构建 Docker 镜像。

### 运行验证

&emsp;&emsp;构建 Docker 镜像成功后，新建 docker-compose.yml 文件并使用 `docker-compose up -d` 命令来运行一个实例。

```yaml
# docker-compose.yml

version: '2'

services:
    apache:
      image: zhonger/ldap-apache:latest
      volumes:
        - ./data:/var/www/
        - ./logs:/var/log/apache2/
        - /etc/localtime:/etc/localtime
      environment:
        LDAP_URL: "ldap://ldap.example.com/ou=users,dc=example,dc=com?uid"
        LDAP_BindDN: "cn=admin,dc=example,dc=com"
        LDAP_BindPass: "xxxxxxxxxx"
        LDAP_BindGroup: "ou=people,dc=example,dc=com"
        APACHE_LOG_DIR: "/var/log/apache2"
      ports:
        - 80:80
      restart: always
```

#### 验证网页

&emsp;&emsp;为了验证 LDAP 认证是否有效，这里写了一个简单的 PHP 文件 /var/www/html/p.php。当没有放置 .htaccess 文件时，无须任何认证即可访问。当在 /var/www/html 目录放置 .htaccess 文件时，浏览器再次访问会弹出如下登录弹窗。正确输入 LDAP 允许的用户名和密码后，浏览器会再次正常显示刚才看到的内容。

```php
<!-- p.php -->
<? php
    echo phpinfo();
```

![正常内容 Normal Page Content](https://i.luish.cc/blog/iw6WKt.webp)
![要求验证 Auth Required](https://i.luish.cc/blog/Px1PiS.webp)

#### 验证日志

&emsp;&emsp;当查看 Apache 的访问日志 access.log 文件时，可以看到如下内容。第一行是未设置 LDAP 验证时的正常访问记录，第二行是设置 LDAP 验证后提醒登录的记录，第三行是登录成功后带有登录用户名的记录（由于隐私关系，下图遮住了登录用户名）。

![日志文件 Log file](https://i.luish.cc/blog/CdxxGU.webp)

#### 验证目录假名

&emsp;&emsp;这里为了验证目录假名，新建了目录 /var/www/dvm，并在目录中新建了内容为 dvm 的 index.html 文件。在配置上面提到的目录假名之后访问浏览器可以看到如下所示效果，正常生效。

![目录假名 Alias](https://i.luish.cc/blog/NDnuLk.webp)

#### 验证代理

&emsp;&emsp;这里为了验证代理效果，直接代理了百度首页（虽然这样不大好）。如下所示可以正常看到百度首页内容。

![代理 Proxy](https://i.luish.cc/blog/kdbabl.webp)

## 参考资料

- [Apache HTTP 服务器](https://zh.wikipedia.org/zh-cn/Apache_HTTP_Server)
- [Apache Module mod_alias](https://httpd.apache.org/docs/current/ja/mod/mod_alias.html)
- [How To Use Apache HTTP Server As Reverse-Proxy Using mod_proxy Extension](https://www.digitalocean.com/community/tutorials/how-to-use-apache-http-server-as-reverse-proxy-using-mod_proxy-extension)
