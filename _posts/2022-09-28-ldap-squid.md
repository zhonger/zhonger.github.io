---
layout: post
title: 'LDAP 集成之 Squid 篇'
subtitle: '利用 LDAP 为 Squid 提供用户认证服务'
date: 2022-09-28 15:00:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/slF29A.webp'
cover_author: 'Olmes Sosa'
cover_author_link: 'https://unsplash.com/@sosacl'
tags:  
- LDAP
- Squid
---

## 前言

&emsp;&emsp;Squid cache，简称 Squid，是一款高性能的代理缓存软件。Squid 本身支持包括 HTTP、HTTPS、FTP、SSH 在内的多种协议，且采用一个单独的、非模块化的、I/O 驱动的进程来处理所有的客户端请求，从而提供**主动缓存加速**的功能。除此之外，Squid 还可以提供**应用层过滤控制**的功能，也可与其他的**防病毒**软件一起使用。在一些大公司、学校、研究机构内部，一般采用 Squid 代理上网的方式，可以过滤危险内容或操作、节省网络带宽、提升访问速度。

&emsp;&emsp;但实际上 Squid 代理也可用于正向代理，即为外来用户访问内网应用提速。这也是 CDN（内容分发网络）的加速原理，利用位于全球网络边缘的节点提供服务，而实际上的应用内容则通过边缘节点间的内网来缓存提速。

&emsp;&emsp;虽然 Squid 一般部署在团队或公司网络内部，但是由于用户的权限不同可能需要应用不同的规则，所以能够与 LDAP 认证服务结合就变得非常重要了。

## 实践

### 环境要求

&emsp;&emsp;在进行正式的实践之前，务必确保已有以下环境：

- Docker
- docker-compose

### 启动实例

&emsp;&emsp;笔者已经编译并公开了在多种体系架构上可用的 Docker 镜像 [zhonger/squid](https://github.com/zhonger/docker-squid)。这里直接使用以下 docker-compose.yml 配置文件和 `docker-compose up -d` 命令启动实例。

```yaml
# docker-compose.yml
version: '3.2'

services: 
  squid:
    image: zhonger/squid
    container_name: squid
    hostname: squid
    ports:
      - "3128:3128"
    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    environment: 
      - SQUID_SSH=true
      - SQUID_RSYNC=false
      - LDAP_ENABLE=true
      - LDAP_HOST=yourldap.domain.com
      - LDAP_PORT=389
      - LDAP_BindDN="cn=admin,dc=yourdomain,dc=com"
      - LDAP_BindPass="********"
      - LDAP_DN="ou=Users,dc=yourdomain,dc=com"
      - LDAP_ATTRIBUT="uid=%s"
      - PROXY_NAME="Proxy Display Name"
    restart: always
```

&emsp;&emsp;上面有关的配置变量及其含义可以访问 [zhonger/squid](https://github.com/zhonger/docker-squid) 了解更多。

#### 测试

&emsp;&emsp;通过浏览器访问 http://ip:3128 并输入对应的用户名和密码可以看到类似下面的内容。

![nUOnpb](https://i.lisz.top/blog/nUOnpb.webp)

### 客户端连接

&emsp;&emsp;由于我们未指定实际需要访问的地址，Squid 会直接报错。一般使用时，需要使用操作系统的网络设置中的代理来配置好 Squid。如下图所示，勾选“网页代理（HTTP）”并填写相关的 IP、端口、用户名及密码。如果想要同样应用在访问 HTTPS 站点，则还需要勾选“安全网页代理（HTTPS）”及填写相关信息。然后点击保存生效。

![oXWsLE](https://i.lisz.top/blog/oXWsLE.webp)

&emsp;&emsp;这样一来就可以将访问的流量完全交给 Squid 来控制了。当然，如果不确定客户端连接是否成功，可以通过访问 [ip.sb](https://ip.sb) 来确认当前客户端流量出口 IP 是否为 Squid 服务器 IP。

## 参考资料

- [Squid cache](http://www.squid-cache.org/)
- [Squid 软件](https://zh.wikipedia.org/zh-cn/Squid_(%E8%BD%AF%E4%BB%B6))
