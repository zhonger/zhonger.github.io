---
layout: post
title: '内网私有域名解析'
subtitle: '如何为团队内部提供免费、可靠的私有域名解析解决方案'
date: 2022-08-04 11:30:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/w9mf2P.webp'
cover_author: 'Bruce Warrington'
cover_author_link: 'https://unsplash.com/@brucebmax'
tags:  
- 域名解析
- DNS
- 私有域名
- 内网
---

## 前言

### 域名和域名解析

&emsp;&emsp;大家可能知道，在网络被发明出来之后一段时间，大家采用 `IP + Port` 的方式一起共享资源。后来随着资源越来越多，这样一种方式显得非常不友好。比如说，现在有 254 个 IP，每个 IP 上有 20 个 Web 应用，那么我们就必须记住 5080 个 `IP + Port` 的组合，简直太折磨人了。于是在 1983 年，保罗・莫卡派乔斯发明了域名解析服务和域名服务（DNS，Domain Name System）。从此以后，大家开始用域名来访问各种各样的应用服务。显然，相比原来 `IP + Port` 的方式，域名的含义更加具象、更容易被人记住。

&emsp;&emsp;域名解析实际上就是把 IP 和一串有意义的字符对应，这是一对多的关系，即一个 IP 可能对应多个域名。域名的管理单位我们称之为域名注册管理机构，他们掌握着顶级域名的管理权利。比如说，.net、.com、.org 就是顶级域名，域名注册管理机构对顶级域名具有完整的权利。就像上次讲到的 SSL 根证书一样，光有域名注册管理机构还是不够的，他们没有办法直接把域名卖给全世界所有的公司或者个人，而是需要域名注册商承担这部分工作。像我们比较熟知的国内的万网（现在阿里云域名）、DNSPod（现在腾讯云域名）等，国外的 Gandi、Godaddy 等，都是域名注册商。顶级域名根据用途不同可以分为，国别域名后缀和通用域名后缀。国别域名后缀就是指定给各个国家或地区使用的，通用域名后缀就是其余的。我们可以在某域名注册商处购买某个域名后缀（也称顶级域名）的子域名（也称二级域名），比如说我们可以购买域名后缀为 .com 的域名 baidu.com（当然 baidu.com 早就被注册了，我们只能购买还未被注册的域名）。由于一些品牌效应，大部分域名后缀都会保留一些子域名，我们一般称之为**溢价域名**。一般来说，溢价域名也会比普通域名价格更贵。当我们购买了域名之后，域名注册商会免费提供域名解析服务。当然，我们也可以要求使用其他厂商提供的免费或收费域名解析服务，甚至也可自行搭建域名解析服务。

> warning "小提醒"
> &emsp;&emsp;国内需具备一定资质才能在公网上搭建域名解析服务，否则会面临警告和阻断的风险。

&emsp;&emsp;为了简便，我们一般把域名解析服务称为 DNS 服务。在操作系统中，53 端口被视为 DNS 服务的标准端口（TCP/UDP 服务），853 端口被视为 DNS over TLS 的标准端口（TCP 服务）。除此之外，DNS over HTTPS（TCP 服务）和 DNS over Quic（新协议，UDP 服务）的标准端口是 443。所以现有能够公开使用的 DNS 服务都采用了标准端口，比如国内著名的 114 DNS、阿里云 DNS、腾讯云 DNS、百度云 DNS 都是如此。如果想要了解更多开放可用的 DNS 服务可以查看 [这里](https://adguard-dns.io/kb/general/dns-providers/)。

> note "小知识"
> &emsp;&emsp;DNS 按照功能上的不同可以分为 **权威 DNS** 和 **递归 DNS**。权威 DNS 负责对某个或多个子域名进行管理，注册商提供的域名解析服务就是这一类。递归 DNS 负责接收客户端的请求并将查询到的域名对应记录返回给客户端，也就是说它本身不对任何子域名进行管理，只转述别人告诉它的结果。

&emsp;&emsp;当我们使用 DNS 时，它（这里指递归 DNS）会如下图所示按照域名系统的构成逐级进行查询。比如说，现在我们想访问 www.baidu.com：

1. 客户端（我们）向递归 DNS 请求解析 www.baidu.com；
2. 递归 DNS 会先去问一下它的上游 DNS，如果不存在上游 DNS，它就只能去问 DNS 根服务器；
3. DNS 根服务器并不知道具体的解析记录，但是会告诉递归 DNS 顶级域名 .com 的 DNS 服务器；
4. 递归 DNS 接着向 .com 的 DNS 服务器询问；
5. 结果 .com 的 DNS 服务器也不知道具体的解析记录，但是会告诉递归 DNS 二级域名 baidu.com 的 DNS 服务器；
6. 这样递归 DNS 才会去问域名 baidu.com 的权威 DNS；
7. 然后，baidu.com 权威 DNS 响应 www.baidu.com 对应的 A 记录（或者 AAAA 记录）是什么；
8. 最后，递归 DNS 将解析结果告诉客户端（我们）。

![域名解析过程 DNS Resolution Process](https://i.lisz.top/blog/hwyKGH.webp)

&emsp;&emsp;那么问题来了，**一个 DNS 能否同时是权威 DNS 和递归 DNS 呢？**实际上是不可能的，但是可以实现这种效果。如果我们把权威 DNS 隐藏在递归 DNS 的后面，那么对于顶级域名 DNS 来说，你指定的递归 DNS 就是它理解的权威 DNS。这里的隐藏指的是，当有请求询问递归 DNS 的权威解析记录时，递归 DNS 根据规则将请求转发给背后真正的权威 DNS。等待权威 DNS 返回解析记录后，递归 DNS 再把结果返回给请求方（其他递归 DNS 或者客户端）。

### 私有域名解析

#### 必要性

&emsp;&emsp;以上谈到的都是公有域名的相关事情，为什么又要考虑私有域名解析呢？首先，公有域名和私有域名本质上可以没有区别，都是在域名注册商处购买的域名，也可以有所区别，即私有域名是未购买的或者是非 ICANN 支持的域名（比如 .lisz 后缀）。这样一来，我们将不再受**域名是否注册**的限制而应用在内部网络中。

> info "小提示"
> &emsp;&emsp;当然，我们应当避免使用 ICANN 支持的域名后缀且可注册的域名，毕竟可能以后会有人购买这个域名。

&emsp;&emsp;其次，解析记录的**内外分离**需求。随着基础服务架构和应用架构的不断发展，越来越多像云计算、Kubernetes 这样需要采用域名解析来连通内部服务。如果我们直接采用一个权威 DNS 来解析这些记录，那就意味着所有人都可以通过查询来知道这些解析记录，甚至有些人就能大致猜出服务架构，这并不是很安全。出于安全上的考量，将同一个域名的解析记录进行内外分离能够在一定程度上提升安全。

&emsp;&emsp;如参考资料中《内网域名系统的安全保密风险研究》所说，“随着内网规模的不断扩大，特别是国家电子政务内网的建成、扩展，在电子政务内网中构建国家级可信内网域名体系的需求越来越迫切，内网域名系统会成为内网的核心基础设施，其安全问题将会越来越被关注。”私有域名解析，即内网域名系统在内网安全中发挥着举足轻重的作用。

#### 用途

&emsp;&emsp;笔者在实际使用 AWS、Azure、Oracle、阿里云、腾讯云、Ucloud 的过程中，也发现了私有域名解析的应用。举个例子，Oracle 云创建的每一台 VPS 都会有一个内部 FQDN（以 oraclecv.com 为后缀的多级域名）。当你在 VPS 上使用 dig 命令查询这个 FQDN 对应的 A 记录时，VPS 的内网 IP 会被返回。当你在自己的设备上使用 dig 命令查询时，返回为空。再举个例子，云计算厂商的 VPS 默认配置的是他们自家的镜像源，比如腾讯云 VPS 的默认镜像源域名为 mirrors.tencentyun.com，而这个域名在公网上是查不到解析记录的。可见，云计算厂商的架构上也在使用私有域名解析。

&emsp;&emsp;当然，云计算厂商们也向用户提供依托于 VPC（私有网络）的私有域名解析服务，即该私有域名解析服务只有在同一 VPC 内的 VPS 可以使用。而我们又知道，VPC 是属于用户个人的，也就是说不同用户之间的私有域名解析服务完全互不干扰。

&emsp;&emsp;在参考资料一中，阿里云列出了实际云服务中私有域名解析的四大应用场景：

- **主机名管理**：根据用途、机器信息语义化命名，对运维人员更友好。
- **内部调用 API**：内部 API 用域名来访问，即使对应集群或者 IP 发生变化，也可以无感切换。
- **内部域名隐私保护**：和上面笔者提到的必要性第二点一样，提升隐私保护。
- **私有地址反向解析**：绑定后可以通过 host、traceroute 或其他操作直接识别访问 IP 的来源，便于运维人员排查问题。

> note "小知识"
> &emsp;&emsp;域名解析分为**正向解析**和**反向解析**，我们一般见过的“域名 → IP”的域名解析就是正向解析，而反向解析则是“IP → 域名”。一般来说，反向解析多用于邮件服务器的可信认证。将 IP 与 邮件服务器域名的正反向解析都绑定后，能够增强邮件服务器的可信度，降低被收信服务器判定为 **垃圾 IP** 发信的概率。

## 实践

### 方案一

&emsp;&emsp;内网私有域名解析实际上就是要在内网中搭建一台权威 DNS 和递归 DNS：权威 DNS 用于管理私有域名，递归 DNS 用于解析权威 DNS 记录以及正常的公网解析记录。当然，在公司网络或者机房集群网络中，一般会搭建权威 DNS 集群和递归 DNS 集群来提升可靠性和可用性。权威 DNS 集群通常是主从架构，主节点作为接受域名解析操作的主要接收方，从节点将实时同步主节点记录。当主节点发现故障时，从节点自动升级为主节点。并非所有的集群都是这样，但是这样更加能避免因主节点宕机后无法进行域名解析的更改操作。由于这与采用架设 DNS 服务的软件相关，这里就不作过多探讨。

&emsp;&emsp;与权威 DNS 集群不同的是，内网递归 DNS 集群实际上一般会有两个节点暴露出来。这一点与公网中提供公网递归 DNS 服务是一样的。比如 114 DNS 会告诉大家要设置两个 DNS IP 地址，即 114.114.114.114 和 114.114.115.115。为什么要这样呢？主要还是因为通过冗余来提高可靠性和可用性。我们可能会简单地以为 114 DNS 就只有这两个 IP，但实际上它们的背后还有很多台递归 DNS 服务器。这两台服务器的作用并不是直接处理解析请求，而是为想要域名解析的客户端提供一个更加快和高效的方式来使用递归 DNS。类似于复杂 Web 系统中首先会在交换机上用网关进行优化，然后在服务器上利用 LVS 来负载均衡，之后再利用多个服务后台来分别处理相同的业务，最后再返回信息给用户。这两台递归 DNS 节点也起到了负载均衡的作用。

&emsp;&emsp;当然，这两个 IP 也不是一般的 IP，而是使用了 Anycast 技术的 IP。也就是说，在互联网上会有多台服务器使用了这两个 IP，而当我们向这两个 IP 发起请求时，BGP 会根据客户端所处的地理位置和网络情况将 IP 定位到离客户端最近的两台服务器上。有一个比较客观的体验就是，当我们在全国不同地方 ping 这两个 IP 时，发现似乎延迟差不多且都很短。但是无论我们的骨干网建得多么好，因地理位置和跨网（电信、联通、移动、教育网）所带来的延迟也是无法避免的。唯一一个延迟都很短的可能解释就是响应请求的机器实际上并非同一位置的同两台，而是位于不同位置的不同两台。

### 方案二

&emsp;&emsp;上面的方案考虑的问题比较多，也比较适合在大规模集群或内网中进行实践，但是在小集群中可能就有点过于庞大了，显得没有必要。其实，小集群或者小团队内网可以采用“合二为一”的方案，即递归 DNS 与权威 DNS 由一台服务器来同时提供。由于小集群内网私有域名解析和公有域名解析不需要接近于零的宕机率，所以完全可以最简化。当前最流行的免费解决方案可能就是 AdGuard Home 了。

> citation "AdGuard 主页"
> &emsp;&emsp;AdGuard Home 是一款全网广告拦截与反跟踪软件。在您将其安装完毕后，它将保护您所有家用设备，同时您不再需要安装任何客户端软件。随着物联网与连接设备的兴起，掌控您自己的整个网络环境变得越来越重要。

&emsp;&emsp;AdGuard Home 之所以这么受到欢迎，主要是因为其丰富的功能和简单的可视化操作，对于管理员来说非常友好。而且，AdGuard Home 的部署也非常简单，支持多平台架构、多方式一键部署，比如 AdGuard Home 也能在 ARM 芯片上用 Docker 容器的方式一键部署。虽然 AdGuard Home 自带简单的解析记录重写，可以满足大部分常用的内网私有域名解析需求，但是像一些比较高级的解析记录可能就无法做到，比如 TXT 记录。尽管 TXT 记录在 **IP** 和**域名**的相互映射中并不起到作用，但是 TXT 记录可以填写比较长的内容，非常适合用来验证对于域名的管理权限，像 HTTPS 证书的申请一般就是采用新增 TXT 记录的方式验证，还有 Gitlab Page 的自定义域名绑定也是如此。所以为了提供比较完整的域名解析服务，这里还是建议增加一个权威 DNS，可以采用 PowerDNS + PowerDNS Admin（交互界面）或者 Bind9 等。

&emsp;&emsp;考虑到友好的交互界面更容易上手使用，这里只介绍 AdGuard Home + PowerDNS 的方案。需要提前准备的环境有：

- Docker
- docker-compose

### AdGuard Home

&emsp;&emsp;由于 AdGuard Home 官方已经提供了多平台架构的 Docker 镜像，我们直接使用即可，docker-compose.yml 文件如下所示：

```yaml
version: "3"

services:
  adgurad:
    image: adguard/adguardhome
    ports:
      - 53:53/tcp
      - 53:53/udp
      - 80:80/tcp
      - 443:443/tcp
      - 3000:3000/tcp
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf
```

&emsp;&emsp;使用 `docker-compose up -d` 命令启动 AdGuard Home 实例。

#### 初始化

&emsp;&emsp;使用浏览器访问 [http://localhost:3000](http://localhost:3000) 进行实例初始化设置，如下所示根据页面提示设置好用户名和密码。

![初始化 AdGuard Home Initial](https://i.lisz.top/blog/PreFoj.webp)

![确认端口 Check ports](https://i.lisz.top/blog/7LHDlg.webp)

![设置管理员 Set Admin](https://i.lisz.top/blog/qjTNW8.webp)

![客户端配置指南 Client setting guideline](https://i.lisz.top/blog/yLkLc4.webp)

![完成初始化 Finish the initialization](https://i.lisz.top/blog/buQ6LT.webp)

&emsp;&emsp;初始化成功后，页面会自动跳转到登录界面 [http://localhost](http://localhost)（80 端口）。

> info "小提示"
> &emsp;&emsp;由于在实际环境中，我们不一定是在本机启动该实例，所以可能需要使用服务器的 IP 来替代 localhost 访问。另外，如果原来就有 Nginx 或其他服务占用了 80 端口，我们在配置端口映射的时候可能就会设置到另外一个端口，因此自动跳转到的页面并非是 AdGuard Home 的首页。我们需要使用 IP + 映射 80 的端口来定位到首页。

![登录页面 AdGuard Home Login](https://i.lisz.top/blog/Wwb5At.webp)

#### 私有域名转发

&emsp;&emsp;由于接下来我们将要用 PowerDNS 来管理权威域名解析，所以需要设置私有域名规则，即当 AdGuard Home 收到关于内网自定义权威域名的请求时，就会把请求转给 PowerDNS。这在 AdGuard Home 中也是比较容易就能设置好的，如下图所示，添加一行规则使得匹配的所有二级域名请求转发给 PowerDNS。

![配置转发 Redirect to Authroized DNS](https://i.lisz.top/blog/4GMZAO.webp)

### PowerDNS

&emsp;&emsp;虽然 PowerDNS 和 PowerDNS-Admin 官方都提供了 Docker 镜像，但是搭配起来用还是有点莫名其妙的问题。为了更加简单，笔者参考官方自行构建了 `zhonger/pdns` 和 `zhonger/powerdns-admin` 两个 Docker 镜像，搭配使用更加便捷可用。如果想要了解更多，可以查看 [《Docker 镜像构建之 PowerDNS 篇》](../docker/powerdns.html)。
&emsp;&emsp;

```yaml
version: "3"

services:
  pdns:
    image: zhonger/pdns:latest
    restart: always
    ports:
      - "753:53/tcp"
      - "753:53/udp"
      # - "8081:8081"
    environment:
      - PDNS_launch=gsqlite3
      - PDNS_gsqlite3_database=/var/lib/powerdns/pdns.sqlite3
      - PDNS_webserver_address=0.0.0.0
      - PDNS_webserver_allow_from=127.0.0.1,10.0.0.0/8,172.0.0.0/8,192.168.0.0/16
      - PDNS_api=yes
      - PDNS_api_key={Random Long String}
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./powerdns:/var/lib/powerdns
  db:
    image: mysql:latest
    environment:
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
      - MYSQL_DATABASE=powerdnsadmin
      - MYSQL_USER=pdns 
      - MYSQL_PASSWORD=mypdns
    restart: always
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./pda-mysql:/var/lib/mysql

  app:
    image: zhonger/powerdns-admin:latest
    restart: always
    depends_on:
      - db
      - pdns
    ports:
      - "8080:80"
    logging:
      driver: json-file
      options:
        max-size: 50m
    volumes:
      - /etc/localtime:/etc/localtime:ro
    environment:
      - SQLALCHEMY_DATABASE_URI=mysql://pdns:mypdns@db/powerdnsadmin
      - GUNICORN_TIMEOUT=60
      - GUNICORN_WORKERS=2
      - GUNICORN_LOGLEVEL=DEBUG
      - OFFLINE_MODE=False # True for offline, False for external resources 
```

&emsp;&emsp;使用 `docker-compose up -d` 命令启动 PowerDNS 和 PowerDNS-Admin 实例。

#### 初始化用户

&emsp;&emsp;PowerDNS-Admin 本身不会自动初始化管理员用户，而是将注册的第一个用户认定为管理员用户。使用浏览器访问 PowerDNS-Admin 登录页面 [http://localhost:8080](http://localhost:8080)，如下图所示点击 Create an account 链接跳转到注册页。

![PowerDNS-Admin 登录页 Login page](https://i.lisz.top/blog/9NDNpc.webp)

&emsp;&emsp;如下图所示，填写姓名、邮箱、用户名和密码，点击 Register 按钮即可完成注册。这里，PowerDNS-Admin 默认采用邮箱的 Gavatar 头像作为用户头像。

![PowerDNS-Admin 注册页 Register page](https://i.lisz.top/blog/TJqhDE.webp)

#### 初始化配置

&emsp;&emsp;注册和登录后，会跳转到 PDNS 配置页面。这里由于 PDNS 和 PowerDNS-Admin 实例是在同一个网络中，可以直接使用 pdns 来代替 PDNS 实例的 IP 地址。PDNS API KEY 则是刚才启动时设置的那一长串字符（PDNS_api_key）。PDNS VERSION 最好是与 PDNS 实际使用的一致，不过不一致也不会有什么事。`zhonger/pdns:latest` 目前实际是 4.6 版本，这里默认填的 4.1.1 也可以。然后点击 Update 按钮保存配置。

![CJ1Wl1](https://i.lisz.top/blog/CJ1Wl1.webp)

&emsp;&emsp;保存配置成功后，如果填写信息无误，点击侧边导航中的 PDNS 就可以看到 PDNS 的各项配置信息。如果填写有误，则没有任何信息。

![UdkXGi](https://i.lisz.top/blog/UdkXGi.webp)

#### 新增域名

&emsp;&emsp;接下来就可以点击侧边导航栏中的 New Domain 来新增私有域名 home.lisz。如下图所示，我们需要填写的是域名，需要选择的是域名模板，一般 basic_template_1 即可。之后点击 Submit 按钮提交。

![nMyRKR](https://i.lisz.top/blog/nMyRKR.webp)

#### 新增解析记录

&emsp;&emsp;新增域名成功后，我们就可以在 Dashboard 里面的域名列表看到 home.lisz 了。点击即可进入域名解析。

![naFe9s](https://i.lisz.top/blog/naFe9s.webp)

&emsp;&emsp;这里我们以一个 CNAME 和 A 记录为例，来尝试新增解析记录。如下图所示，点击左上角的 Add Record 添加记录，完成后点击右上角的 Apply Changes 来提交解析记录到 PDNS。

![SmwtCT](https://i.lisz.top/blog/SmwtCT.webp)

> note "小知识"
> &emsp;&emsp;实际域名解析时我们一般会采用 CNAME 和 A 记录联合使用的方式，这样相当于在 DNS 解析层面就有负载均衡了。A 记录是域名与 IP 的关系，这就意味着同一个域名可以有多个 A 记录。CNAME 记录是域名与域名的关系，而两个域名分别是为了不同的目的，前一个是为了给大家使用的，后一个是为了运维人员使用的。当存在 CNAME → A 时，客户端会根据网络情况来判断使用哪一条 A 记录对应的 IP，从而提升用户体验。

### 验证

#### 验证权威 DNS 是否正常

&emsp;&emsp;如下所示向 AdGuard Home 询问私有域名解析记录，解析正常。

```bash
─$ dig @127.0.0.1 -p 53 www.home.lisz

; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> @127.0.0.1 -p 53 www.home.lisz
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47193
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;www.home.lisz.                 IN      A

;; ANSWER SECTION:
www.home.lisz.          60      IN      CNAME   www101.home.lisz.
www101.home.lisz.       60      IN      A       192.168.1.1

;; Query time: 20 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Aug 23 17:05:15 JST 2022
;; MSG SIZE  rcvd: 79
```

#### 验证递归 DNS 是否正常

&emsp;&emsp;如下所示，向 AdGuard Home 询问公有域名解析记录，解析正常。

```bash
-$ dig @127.0.0.1 -p 53 www.baidu.com

; <<>> DiG 9.18.1-1ubuntu1.1-Ubuntu <<>> @127.0.0.1 -p 53 www.baidu.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8988
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;www.baidu.com.                 IN      A

;; ANSWER SECTION:
www.baidu.com.          831     IN      CNAME   www.a.shifen.com.
www.a.shifen.com.       28      IN      CNAME   www.wshifen.com.
www.wshifen.com.        192     IN      A       45.113.192.102
www.wshifen.com.        192     IN      A       45.113.192.101

;; Query time: 244 msec
;; SERVER: 127.0.0.1#53(127.0.0.1) (UDP)
;; WHEN: Tue Aug 23 17:06:03 JST 2022
;; MSG SIZE  rcvd: 127
```

## 参考资料

- [阿里云帮助中心 - 云解析 - 应用场景](https://help.aliyun.com/document_detail/64623.html)
- [腾讯云文档中心 - 子域名递归解析说明](https://cloud.tencent.com/document/product/1338/50547)
- [华为云文档 - 如何设置内网域名既支持内网解析，也支持公网解析？](https://support.huaweicloud.com/dns_faq/dns_faq_040.html)
- [公司内网搭建代理 DNS 使用内网域名代替 ip 地址](https://cloud.tencent.com/developer/article/1123748)
- [一文搞懂 DNS 基础知识，收藏起来有备无患~](https://cloud.tencent.com/developer/article/1821030)
- [搞它！！！深入了解DNS域名解析服务，教你搭建一个属于自己的DNS服务器（正向解析、反向解析、泛域名解析、邮件交换解析、别名解析、分离解析，主从结构解析）](https://cloud.tencent.com/developer/article/1691018)
- [推荐一款 Private DNS 服务](https://www.modb.pro/db/433331)
- [AdGuard Home 安装及使用指北](https://sspai.com/post/63088)
- [内网域名系统的安全保密风险研究](http://www.gjbmj.gov.cn/n1/2021/0722/c411145-32166624.html)
- [Running PowerDNS and PowerDNS Admin in Docker Containers](https://computingforgeeks.com/running-powerdns-and-powerdns-admin-in-docker-containers/)
