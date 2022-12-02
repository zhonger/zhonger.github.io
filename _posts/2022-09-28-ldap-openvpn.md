---
layout: post
title: 'LDAP 集成之 OpenVPN 篇'
subtitle: '利用 LDAP 为 OpenVPN 提供用户认证服务'
date: 2022-09-28 15:04:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/tUQYGW.webp'
cover_author: 'Buddika Gunathilaka'
cover_author_link: 'https://unsplash.com/@unflashbuddika'
tags:  
- LDAP
- OpenVPN
---

## 前言

### Easy Connect

&emsp;&emsp;公司、学校、云服务等一般需要将内外网进行分离，如果想要从外部网络访问某些内部应用，通常需要使用公司、学校、云服务提供的专用网络接入服务。国内公司、学校比较常用的是由深信服开发的 Easy Connect，一种 SSL VPN 技术的实现。虽然每年需要支付一定的费用来维护、升级 Easy Connect 服务，但是毕竟它能够提供比较细粒度的权限控制，比如说对目标 IP、目标端口的特别指定，能够有效保护内网服务器只有 Web 应用本身能被用户接入，而类似于 SSH 等服务及端口则可以通过单独申请和配置来实现。总而言之，除了需要付费，似乎没有什么不好的地方。

&emsp;&emsp;实际上如果是在大公司或者学校的话，可能在内网里面还会有更深的内网存在。举个例子，正常的内网是日常的办公或开发网络，服务器所处的内网是独立的网络，即使是已经连接了办公网络，还是需要通过专用网络接入服务器内网才能进行服务器的维护。如果是以数据中心的模式运营的话，甚至说每一次访问服务器都是需要经过临时审批和登录密码发放的。一旦过了有效时间或者完成了任务，访问都将会被拒绝。

### OpenVPN

&emsp;&emsp;虽然 Easy Connect 可以用于上述的场景，但是似乎显得有些大材小用了，毕竟还是要支付一定费用的。为了尽量降低成本，开源的 OpenVPN 或许是一种不错的选择。据笔者所知，Easy Connect 根据购买的许可不同允许的同时在线人数可能也会不同，实际上可能存在“需大于供”的问题。为了缓解这一可能存在的问题，还是会搭建一套 OpenVPN 来作为冗余接入方式。其实 OpenVPN 的商业版本许可也是会有人数限制的，只不过因为只是备份方式也没有太大关系。

&emsp;&emsp;OpenVPN 除了开源免费之外，还支持大部分主流的认证方式，比如说 LDAP 认证、微软的商业级目录服务 Active Directory（简称 AD）认证等。近年来，基于 Identify Provider（简称 IdP）、Single Sign On（简称 SSO）、Central Authentication Service（简称 CAS）等的国产化的一站式登录服务解决方案也在逐渐替换原来的 LDAP 或 AD 直接认证，LDAP 或 AD 将作为底层的基础认证方式存在。所以说，开源免费的 LDAP 目录服务在一般的团队中还是足够的，作为 OpenVPN 的认证方式也是完全能满足要求的。

> warning "提醒"
> &emsp;&emsp;在公网上搭建专用网络接入服务是需要有工信部颁发的专门资格许可的，一般公司、学校、云服务都是有该类资格许可，所以可以对外提供该项服务。而个人是无法获得这类许可，除非注册公司并申请该类许可。如果个人在云服务上搭建该类服务，将会面临被云服务提供商警告甚至单方面停止服务的风险。

## 实践

### 环境要求

&emsp;&emsp;在实践前请务必保证具备以下环境：

- Docker
- docker-compose
- 可用的 LDAP 目录服务

### 启动实例

&emsp;&emsp;为了方便部署和测试，这里采用 [wheelybird/openvpn-ldap-otp](https://hub.docker.com/r/wheelybird/openvpn-ldap-otp) 提供的 Docker 镜像。这个镜像比较小，同时也支持 x64 和 arm 两种体系架构，能满足大部分主流服务器平台。

```yaml
# docker-compose.yml

version: '3'
services:
  openvpn:
    cap_add:
     - NET_ADMIN
    image: wheelybird/openvpn-ldap-otp
    container_name: openvpn
    ports:
     - "1194:1194/udp"
    restart: always
    volumes:
     - /etc/localtime:/etc/localtime:ro
     - /etc/timezone:/etc/timezone:ro
     - ./openvpn-data:/etc/openvpn
    environment:
     - OVPN_SERVER_CN=oc-vpn.example.com
     - LDAP_URI=ldap://ldap.example.com
     - LDAP_BASE_DN=ou=users,dc=example,dc=com
     - LDAP_BIND_USER_DN=cn=admin,dc=example,dc=com
     - LDAP_BIND_USER_PASS=password
     - LDAP_LOGIN_ATTRIBUTE=uid
     - LOG_TO_STDOUT=false
     - OVPN_DNS_SEARCH_DOMAIN=example.com
```

&emsp;&emsp;使用以下 docker-compose.yml 文件和 `docker-compose up -d` 命令启动实例。为了能够避免实例在重新创建后证书发生改变，将 Docker 实例中 /etc/openvpn 的目录持久化（与本地目录绑定）是非常重要的。在这里给出的环境变量（environment）中，前三项 OVPN_SERVER_CN、LDAP_URI、LDAP_BASE_DN 是必须要有的。如果 LDAP 目录服务默认是不能被匿名查找的，也必须包含 LDAP_BIND_USER_DN 和 LDAP_BIND_USER_PASS 变量的（即管理员账户名和密码）。当然，如果你想要指定匹配登录用户名字段，则需要新增 LDAP_LOGIN_ATTRIBUTE 变量。该变量默认是 uid 字段，也可以指定为其他 LDAP 目录服务中包含的字段，比如 email。这个镜像默认是会将服务的实时输出打印在终端，如果想要以日志文件的形式保存下来，则将变量 LOG_TO_STDOUT 置为 false 即可。

&emsp;&emsp;一般来说，服务器内网为了管理方便，会根据服务器的 ip 和编号来配置对应的域名解析及反向域名解析，形如 `ec2-1-1-1-1.aws.com`，也有可能就是简单的 `c1.sever.aws.com`。所以当接入服务器内网后，我们可能会期望用 c1 来作为这台服务器的标签，而在终端我们也可能通过 `ping c1` 来测试通路。实际上只要在启动实例时新增变量 OVPN_DNS_SEARCH_DOMAIN 就可以实现，当然这里变量对应的值也应该变成 `server.aws.com`。相当于，有了这个配置后，本地 DNS 解析没有记录时会自动尝试加入后缀来解析。这样一来，是不是方便了很多呢？

&emsp;&emsp;除此之外，该镜像还支持其他一些特性，比如 OTP，请访问 [wheelybird/openvpn-ldap-otp](https://github.com/wheelybird/openvpn-server-ldap-otp) 了解更多。

#### 生成配置文件

&emsp;&emsp;在生成配置文件上，[wheelybird/openvpn-ldap-otp](https://github.com/wheelybird/openvpn-server-ldap-otp) 要比 [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn) 更复杂一些，可以手动从 Docker 实例的日志文件或终端输出内容中看到内容，大致内容形式如下所示：

```bash
#---------- Start of client.ovpn ----------

client
tls-client
dev tun
persist-key
persist-tun
remote-cert-tls server
key-direction 1
auth SHA512
proto tcp
reneg-sec 0

comp-lzo
redirect-gateway def1
auth-user-pass

# Set log file verbosity
verb 3

<connection>
remote oc-vpn.example.com 1194 udp
float
nobind
</connection>

<ca>
-----BEGIN CERTIFICATE-----
.........
.........
-----END CERTIFICATE-----
</ca>
<tls-auth>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
.........
.........
-----END OpenVPN Static key V1-----
</tls-auth>
key-direction 1
#----------  End of client.ovpn  ----------
```

&emsp;&emsp;将以上内容复制保存在 oc-vpn.example.com.ovpn 文件中即可。

### 测试

&emsp;&emsp;通常来说使用 OpenVPN 专用或者兼容客户端来加载配置文件 oc-vpn.example.com.ovpn，当然也可以用终端命令连接，如下所示：

```bash
sudo openvpn --config oc-vpn.example.com.ovpn
```

&emsp;&emsp;执行上述命令后会提示输入用户名和密码进行认证，认证通过后会建立连接。默认分配的是 10.50.50.0/24 段中的某个 IP，网关为 10.50.50.254，当然这个也可以在启动实例时自行设置。

> warning "再次提醒"
> &emsp;&emsp;以上内容比较适用于团队办公或开发网络与服务器网络独立分离的情况（**内网环境**）。请勿在未获得工信部的资质许可的情况下在公网部署类似服务，一旦被云服务提供商监测到，云服务提供商有权进行警告、断网、关停等操作，并且无法申诉。

## 参考资料

- [wheelybird/openvpn-ldap-otp](https://github.com/wheelybird/openvpn-server-ldap-otp)
- [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)

> note "提示"
> 我的博客即将同步至腾讯云开发者社区，邀请大家一同入驻：[加入链接](https://cloud.tencent.com/developer/support-plan?invite_code=1jkj42lj2m4nn)。
