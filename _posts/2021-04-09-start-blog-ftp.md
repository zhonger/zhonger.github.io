---
layout: post
title: '个人免费博客花式搭建指南 FTP 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-09 16:23:00 +0800
tags: 
- blog
- free
- static
- hexo
- jekyll
- ftp
categories: [tech, webmaster]
cover: 'https://images.unsplash.com/photo-1601812535834-2e65e370af6d?w=1600&q=900'
---

## 前言

### 虚拟主机

&emsp;&emsp;传统虚拟主机是最早的博客建站方式之一，也是对用户要求较低的方式之一。一般来说，虚拟主机空间与静态空间还有所不同。虽然二者可能都支持 FTP 方式管理空间，但是虚拟主机空间往往是 PHP 空间或者 ASP.net 空间，支持 PHP 或 .Net 语言。根据提供虚拟主机空间的操作系统不同，可以将虚拟主机空间分为 Windows 虚拟主机和 Linux 虚拟主机。

&emsp;&emsp;网络上收费的虚拟主机空间比比皆是，也有不少免费的。笔者在 WordPress 建站之初使用的是 [西部数据](https://west.cn) 的 1G 虚拟主机空间，当时一年大概一百出头，现在将近两百。之后慢慢接触了阿里云，用上了阿里云的学生认证云服务器和一年免费虚拟主机。对比用过的这两款虚拟主机，感觉使用上没有太大的不同，都是可以从给定的 PHP 版本中选择、读取访问日志和错误日志、采用 FTP 方式管理空间内容。后来一年免费使用期结束后，就通过 [免费资源部落](https://www.freehao123.com/) （站长 Qi 现已全面转向 [挖站否](https://wzfou.com)，原网站交由其他人运营） 寻找国内外一些免费的虚拟主机。国内免费虚拟主机往往都是要你在主机交流论坛上发帖给他们做宣传，现在也有转变为发微信朋友圈宣传。而国外虚拟主机虽然没有这种套路，但是也会有一定的不足，比如说国内访问速度慢、有广告，在一定程度上也限制了使用的想法。所以笔者在此之后几乎没有使用过所谓的虚拟主机了。

### U-File

&emsp;&emsp;大概 2019 年的时候，笔者开始接触了 [U-File](https://u-file.cn)，一个提供 3T 大容量静态文件托管的免费平台。那个时候 U-File 还是只提供普通的 FTP 文件管理功能，免费用户使用的空间大而已。后来慢慢地开始提供自定义域名绑定、SSL 证书管理、直链等功能。这样一来，使用起来与普通的静态空间毫无差异，可以上传静态网页搭建博客。笔者一度怀疑 U-File 是基于某个对象存储而开发出来的，通过以下命令查询 FTP 的服务器地址可以看到，其底层是 [又拍云](https://upyun.com) 确信无疑。

```bash
$ dig box.u-file.cn @1.1.1.1

; <<>> DiG 9.10.6 <<>> box.u-file.cn @1.1.1.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31665
;; flags: qr rd ra; QUERY: 1, ANSWER: 7, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;box.u-file.cn.			IN	A

;; ANSWER SECTION:
box.u-file.cn.		600	IN	CNAME	mxk.own-cloud.cn.
mxk.own-cloud.cn.	600	IN	CNAME	v0.ftp.upyun.com.
v0.ftp.upyun.com.	300	IN	A	118.116.2.3
v0.ftp.upyun.com.	300	IN	A	121.12.52.4
v0.ftp.upyun.com.	300	IN	A	36.99.71.15
v0.ftp.upyun.com.	300	IN	A	58.222.16.5
v0.ftp.upyun.com.	300	IN	A	117.21.235.5

;; Query time: 940 msec
;; SERVER: 1.1.1.1#53(1.1.1.1)
;; WHEN: Sat Apr 10 08:47:00 JST 2021
;; MSG SIZE  rcvd: 180
```

## 实现与评价

&emsp;&emsp;以 U-File 为例解释一下如何使用 FTP 的方式部署静态博客。根据部署方式的不同，可以分为 **手动部署** 和 **自动部署**：

> 如何注册并获取 U-File 的 FTP 账号等信息请移步 [U-File 官网](https://u-file.cn)。

### 手动部署 

&emsp;&emsp;手动部署一般是要借助一些 FTP 客户端来上传最新的静态博客内容，比如 Filezilla (全平台)、WinSCP (Windows)、Transmit (Mac) 等等。这三款软件笔者分别在三个平台都使用过，总体上感觉都不错。本地目录和远程目录都是左右式布局，直接拖拽就可以完成上传下载，操作简单便捷。下面就以 Filezilla 为例：

#### 下载安装 Filezilla

访问 [Filezilla 官网](https://filezilla-project.org/) 点击安装按钮。
![vgy.me](https://i.vgy.me/XgchsU.png)

#### 新建主机

打开 Filezilla，点击左上角**新建虚拟主机**按钮。
![vgy.me](https://i.vgy.me/XxzF1N.png)

填写 FTP 服务器信息、登录用户名和密码。
![vgy.me](https://i.vgy.me/wlE1Wl.png)

#### 上传最新静态博客文件

点击**连接**按钮开始访问 FTP 空间，将 _site 目录下的文件拖到右边远程根目录。

![vgy.me](https://i.vgy.me/franDc.png)

> 使用 `bundle exec jekyll b` 命令可以生成 _site 目录。

### 自动部署

&emsp;&emsp;为了提高自动化效率，不同的静态站点生成器都开发了相关的插件来辅助实现自动化上传。比如说 Jekyll 中就有 [JesseHerrick/jekyll-ftp](https://github.com/JesseHerrick/jekyll-ftp) 这种插件。不过由于安全性的考虑，一般来说 FTP 的登录密码是不会写入到项目的配置文件中的，只能在执行命令的时候作为一个参数传入。这样一来，也不能称得上是全自动化部署。如果想要全自动化部署，那最好还是把 Github 项目与自动化流水线一起使用为好，像 Github Action、Jenkins、Travis CI、Buddy 等等。除此之外，也有另辟蹊径的方法，比如 [git-ftp/git-ftp](https://github.com/git-ftp/git-ftp) 项目就是给 git 加了一个 FTP 功能。git-ftp 可以根据指定的 Git 分支内容进行 FTP 部署，非常灵活。

&emsp;&emsp;考虑到 Github 和 Tranvis CI 需要自行编写配置文件，Jenkins 需要自行搭建服务，这里就以界面交互方便的 [Buddy](https://buddy.works) 为例谈一谈如何全自动化部署。

#### 创建项目

&emsp;&emsp;访问 [Buddy 官网](https://buddy.works) ，使用 Github 账户登录即可，如下图所示搜索到想要部署的项目，并选中创建。

![vgy.me](https://i.vgy.me/jPs082.png)

#### 创建流水线

转到项目页面后，点击 **Create a pipeline** 按钮。

![vgy.me](https://i.vgy.me/dBicNi.png)

&emsp;&emsp;如下图所示填写流水线名称、选中在代码发生 PUSH 操作时触发流水线、操作的分支设置为 master 单分支，点击下面按钮完成创建。

![vgy.me](https://i.vgy.me/KVsyYc.png)

#### 添加 Jekyll 编译动作

如下图所示，点击 Add an action 按钮，选中 Jekyll。

![vgy.me](https://i.vgy.me/pofkrx.png)

无须作任何修改，点击右下角的 Add this action 按钮即可完成添加。

![vgy.me](https://i.vgy.me/22iq0A.png)

#### 添加 FTP 部署动作

如下图所示再次添加一个动作，这次使用 FTP 字符筛选选中 TRANSFER 的 FTP。

![vgy.me](https://i.vgy.me/rDMp5G.png)

&emsp;&emsp;选择从流水线文件系统加载文件，并将源目录设置为 _site，远程目录不变。同时修改 FTP 主机地址及端口、登录用户名和密码三个参数。

![vgy.me](https://i.vgy.me/KJ5gY7.png)

为了防止同名文件，开启删除同名旧文件，不使用缓存文件，点击 Add this action 按钮完成添加。

![vgy.me](https://i.vgy.me/QW3Dqp.png)

#### 运行流水线

如下图所示，可以看到两个动作添加完毕，点击右上角 Run pipeline 按钮开始执行流水线。

![vgy.me](https://i.vgy.me/I8oZgQ.png)

从下图可以看到**环境准备**和 Jekyll 编译动作正在执行。

![vgy.me](https://i.vgy.me/h4ptZ3.png)

等待两分钟左右，可以看到 FTP 部署动作成功完成。

![vgy.me](https://i.vgy.me/TtKsWd.png)

### 评价

&emsp;&emsp;FTP 虽然已经慢慢成为了一个古老的东西，但一直都不过时。在使用 FTP 方式将静态网站页面部署到虚拟主机空间时，仍然体现了 FTP 文件管理的优势。从手动部署和自动部署的对比来看，虽然手动部署需要页面生成和拖拽上传这两步，自动部署则只需要将代码上传到 Github，但是所花的时间也不会相差太大。有了自动部署的好处就是，可以更加专注于博客内容本身，即使是在不常用的机器上编写再推送到 Github，也不需要担心本地没有环境编译 Jekyll 以及用 FTP 客户端配置 FTP 信息和上传静态页面。 

&emsp;&emsp;上文中笔者选择 Buddy 的原因，除了和其他的对比它更加具有安全私密性，还因为它同时支持多种部署方式。也就是说，如果想要添加一个新的部署方式，只需要添加一个部署动作即可，非常方便快捷，所有多节点部署一步到位。