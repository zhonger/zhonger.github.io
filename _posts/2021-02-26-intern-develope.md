---
layout: post
title: '内网环境下的远程登录和开发实践'
subtitle: '只能通过内部服务器代理上网的条件下也能无障碍使用远程服务器开发吗？'
date: 2021-02-26 14:33:00 +0800
tags: 
- Docker
- Ubuntu
- SSH
- Proxy
- Dev
categories: [tech, devops]
cover: 'https://images.unsplash.com/photo-1580574875107-2eb4a7d77040?w=1600&q=900'
---

## 前言

&emsp;&emsp;讲起在内网环境下开发实践的经历，可能在公司上班的程序员们比较有发言权。公司为了提高大家工作时间的效率、监控工作电脑上的流量去向，都会采用内网开发的方式。这样一来，通常来说电脑与外部网络是完全隔离的，至少从外部网络是无法访问到内部网络电脑上的。如果严格到所有开发都是离线的，那么可能大家都会有点不方便，毕竟很多开发是需要加载依赖库和查阅资料的。因此，公司可能会提供了有限的上网方式，既保证大家正常的上网需求，又对员工工作期间上网内容进行监控和过滤。

## 需求和环境

&emsp;&emsp;在日常的开发实践中，通常需要支持的上网类型主要有三种：

1. 浏览器和终端下载所需的 HTTP 和 HTTPS 代理；
2. 远程登录服务器所需的 SSH 代理；
3. 上传、下载文件所需的 FTP 代理。

&emsp;&emsp;其实以上三种代理上网方式都可以由 Squid 来实现，并且可以管理上网黑白名单，对访问网页的类型、地址、内容进行过滤筛选。比如说如果不希望员工访问 QQ，那么就可以将 QQ 服务器 IP 网段加入到 IP 黑名单中。现在我们假设已经在内部网络上已架设好满足以上要求的 Squid 服务器，且具体信息如下：

```bash
Host gateway.lisz.me

Protocl         Port
http_proxy      8888
https_proxy     8888
ftp_proxy       21
ssh_proxy       1080
```

## 配置

&emsp;&emsp;现以 macOS Big Sur 操作系统为例进行实际配置操作： 

### HTTP 和 HTTPS

#### 全局设置

&emsp;&emsp;在 **设置 > 网络 > WiFi > 高级 > 代理** 中如下进行设置“网页代理”和“安全网页代理”之后，除终端外其他应用均会自动应用此代理配置。
![HTTP和HTTPS代理](https://i.vgy.me/rdCHul.png)

#### 终端设置

&emsp;&emsp;根据使用的 SHELL 类型不同，在对应的个人用户配置文件（比如 .bashrc，.zshrc等）末尾添加如下命令，即可让终端打开时自动加载代理配置。如有需要终端临时取消代理，使用 `unsetproxy` 命令即可。

```bash
alias setproxy="export ALL_PROXY=http://gateway.lisz.me:8888"
alias unsetproxy="unset ALL_PROXY"
setproxy
```

### SSH

&emsp;&emsp;SSH 代理主要应用于终端或者某些远程管理软件（比如 Xshell 等），当然也可以与远程服务器本身的 OpenSSH 服务联合起来实现多级代理访问。以下为一个 config 文件的配置示例：

```bash
# outserver 为外网服务器集群入口，拥有公网 IP
# 通过内部网提供的 SSH 代理服务器 gateway 代理访问
Host outserver
    HostName outserver.lisz.me
    Port 22
    User nologin_user
    ProxyCommand nc -X 5 -x gateway.lisz.me:1080 %h %p

# app 为外网服务器集群中的应用节点，只拥有局域网 IP
# 通过 outserver 自身的 OpenSSH 服务代理访问 app
# 此处为两层级联 SSH 代理访问
Host app
    HostName 192.168.1.100
    Port 22
    User ubuntu
    ProxyJump outserver
```

> 这里需要注意的是，内部网的 SSH 代理服务器是不需要秘钥访问的，outserver 必须要有秘钥登录权限。

### FTP

&emsp;&emsp;近年来 FTP 的访问需求感觉越来越少，毕竟大部分的时候可以使用基于 SSH 的 `scp` 和 `rsync` 命令来替代。这里给出 Filezilla 软件的 FTP 代理设置示例，同时也提供终端上的替代命令。

![FTP 通用代理配置](https://i.vgy.me/X668Vv.png)

```bash
# 以下命令的使用需先配置好上述的 SSH 终端代理配置
# 复制文件夹 test 到 app 服务器上
scp -r test app:/home/ubuntu/
rsync -avh -e ssh /home/zhonger/test/ app:/home/ubuntu/

# 从 app 服务器上下载 test 文件夹到本地
rsync -avh -e ssh app:/home/ubuntu/ /home/zhonger/test/
```

> scp 在此处只能单向使用，rsync 可以双向使用。

## 远程开发使用

&emsp;&emsp;随着项目开发的资源需求越来越大，代码安全性越来越重视，现在都在推崇云开发。近年来比较出名的有像被 AWS 收购的在线编辑器 Cloud9，腾讯云收购的 Coding 推出的 Cloud Studio，国外流行的在线编辑器 GroomIDE，微软旗下的开源编辑器 VS Code ，Eclipse 推出的 Eclipse theia 在线编辑器等等。这些强大的在线编辑器或者支持连接远程服务器开发的编辑器极大地改变了现代开发的方式，不仅解决了开发资源限制的问题，还为开发者提供了最简便的开发环境配置，在线调试、内部预览、团队协作等需求都得到了很好地满足。

&emsp;&emsp;值得一提的是，这些编辑器都有一个基础共识----包含文件管理、终端、预览和插件管理等远程开发必备的功能。本人在最开始接触代码编写的时候，Sublime 所具有自定义化、插件化的特点赢来了很多的拥护，同时也提供一个相对较弱的终端。随着 Bracket、Atom、VS Code等编辑器的涌现，终端已经成为了一个合格编辑器所应当具有的特点。尤其是在 Unix/Linux 操作系统终端相比 UI 更加方便快捷。当然，近些年 Windows 平台也有这种趋势，各种各样的支持命令化软件管理的项目推出，为 Windows 系统上的终端使用也增加了更多的可能。

&emsp;&emsp;下面以 VS Code 为例介绍编辑器远程开发使用：

1. 安装 Remote Development 扩展
2. 配置远程服务器 config 配置文件
3. 在 VS Code 编辑器的左边按钮导航栏中选中 SSH TARGETS，点击对应的远程主机即可访问
4. 按 ctrl + ` 键即可打开终端
5. 点击“打开文件夹”按钮即可打开远程服务器上的文件夹显示目录

![VS Code 远程开发](https://i.vgy.me/usZH3y.png)