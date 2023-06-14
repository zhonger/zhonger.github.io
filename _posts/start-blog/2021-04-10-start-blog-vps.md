---
layout: post
title: '个人免费博客花式搭建指南 VPS 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-10 16:45:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/FofQVR.webp'
cover_author: 'Toa Heftiba'
cover_author_link: 'https://unsplash.com/@heftiba'
tags: 
- blog
- free
- static
- jekyll
- ftp
- github
---

## 前言

&emsp;&emsp;近年来，随着云计算技术的大力发展和 VPS 成本降低，越来越多的人开始用上了 VPS。与虚拟主机空间相比，VPS 具有更大的自由度。用户可以在 VPS 上安装各式各样的环境，也可以使用各种方式提供对外服务。对于 Jekyll 等静态网页来说，虚拟主机和 VPS 的使用体验差异可能在一般情况下感受不出来，如果网站流量变大、并发访问人数增多，VPS 就能展现出比虚拟主机的优越之处。其实，一般的虚拟主机也是在 VPS 上搭建的，只不过转换为一种服务提供给用户，用户能使用比较容易接受的网页进行环境的配置和其他操作。而在 VPS 上，往往需要自己从零开始动手，涉及到的专业知识要求也相对多一些。

&emsp;&emsp;笔者使用的第一款 VPS 是 [阿里云](https://cn.aliyun.com) 的 1C1G 的早期学生云服务器（现在的学生云服务器都是 1C2G 配置），后来也相继用过 [腾讯云](https://cloud.tencent.com)、[AWS](https://aws.amazon.com)、[Digital Ocean](https://www.digitalocean.com/)、[Bandwagon Host](https://bandwagonhost.com/)、[Vultr](https://www.vultr.com/)、[Azure](https://azure.microsoft.com/)、[GCP](https://cloud.google.com/)、[Scaleway](https://www.scaleway.com/)、[CLOUDCONE](https://cloudcone.com/) 、[Hostinger](https://www.hostinger.com/) 等等。不过，现在还在一直使用的就剩下阿里云、腾讯云、AWS 和 Azure 了。相比较而言，国内的 VPS 服务器提供商中阿里云和腾讯云的服务和反馈是最好的了。尤其是在备案上的服务，从以前的申请免费邮寄备案幕布自己拍照上传，到现在的面部识别和活体验证即可，越来越人性化、便捷化。AWS 和 Azure 因为使用的是国外的服务器，所以没有备案的要求。当然，AWS 和 Azure 都很重视在中国的发展，两家公司都相继在国内成立了合资公司运营中国区的服务器。

&emsp;&emsp;如果想要自己购买一台 VPS 的话，个人建议国内可以在阿里云和腾讯云中选择。腾讯云的价格相比阿里云便宜一点，不过据说阿里云比腾讯云稳定一点（可能没有什么根据，只要不是自己的 VPS 数据丢失了其实稳定性都很好）。如果想要购买国外的 VPS 的话，推荐 AWS、Azure、Digital Ocean。这三家都是可以随时删除、随时创建的，根据实际使用的时间计费，也可以随时更换 IP 地址，非常方便。当然前两者价格上的确有点高，Digital Ocean 相对来说更便宜一点，而且几乎没有流量上的限制。不过，AWS 提供的 [Lightsail](lightsail.aws.amazon.com) 也是一款低配高流量的 VPS，适合博客建站。

## 实现与评价

### 手动部署

&emsp;&emsp;VPS 的手动部署相比较 FTP 方式的手动部署更加简单，只不过增加了首次部署时 VPS 上的环境配置。后续部署起来也比较方便。

#### 配置 VPS 环境

1.安装 Nginx

```bash
sudo apt install -y nginx-full
```

2.配置虚拟主机

```bash
# 创建网站页面存放的文件夹
sudo mkdir -p /var/www/lisz.me
sudo chown -R ubunut:ubuntu /var/www/lisz.me

# 创建配置文件
sudo vim /etc/nginx/sites-available/lisz.me
```

```nginx
# 配置文件内容
server
{
    listen 80;
    server_name lisz.me
    index index.html index.htm index.php default.html default.htm default.php;
    root  /var/www/lisz.me;
    return 301 https://$host$request_uri;
}

server
{
    listen 443 http2 ssl;
    server_name lisz.me;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    ssl_certificate /etc/letsencrypt/live/lisz.me/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/lisz.me/privkey.pem;
    index index.html index.htm index.php default.html default.htm default.php;
    root  /var/www/lisz.me;

    include /etc/letsencrypt/options-ssl-nginx.conf;
    location /
    {
        try_files $uri $uri/ =404;
    }

    access_log  /var/log/nginx/lisz.me.log;
}
```

```bash
# 使用 `:wq` 保存配置

# 激活虚拟主机配置
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/lisz.me lisz.me

# 重载配置文件使虚拟主机生效
sudo nginx -s reload
```

#### 上传文件到 VPS

1.配置本地登录 VPS 配置

```bash
# Mac 或 Linux 编辑 ~/.ssh/config 文件
# Windows 编辑 用户主目录/.ssh/config 文件
# 添加如下配置，主机名可以为 IP 或域名
# 以下配置可用的前提是已配置好 VPS 无密码登录
Host vps
    HostName lisz.me
    User ubuntu
    Port 22
```

2.上传文件

```bash
# 本地生成静态文件
bundle exec jekyll b

# 上传 _site 文件夹内容到虚拟主机目录
scp -r _site/* /var/www/lisz.me/ 
```

### 自动部署

&emsp;&emsp;VPS 的自动部署与 FTP 的自动部署非常类似，只是使用的模板不一样。如下图所示使用 SSH 筛选出 SFTP 模板，并点击选中创建。

![新建 SFTP 部署 New SFTP deploy](https://i.lisz.top/blog/EBFlZd.webp)

&emsp;&emsp;填写上传源目录、VPS 主机信息（此处推荐使用 Buddy key）。

![输入信息 Input vps information](https://i.lisz.top/blog/eeplHr.webp)

&emsp;&emsp;复制命令将 Buddy key 添加到 VPS ，同时设置远程目录，其他配置默认即可，点击 Add this action 按钮完成创建。

![添加秘钥 Add Buddy key to vps](https://i.lisz.top/blog/MPvmSO.webp)

&emsp;&emsp;执行流水线，如下图所示开始 Jekyll 编译动作。

![运行流水线 Run pipeline](https://i.lisz.top/blog/FAtP0C.webp)

&emsp;&emsp;如下图所示，完成所有动作，浏览器访问设置好的域名验证是否成功部署。

![查看部署 Check status](https://i.lisz.top/blog/fB9tVg.webp)

### 评价

&emsp;&emsp; VPS 所提供的最大并发访问数、访问流量、访问速度在很大程度上与购买的配置相关，但由于是个人独享资源所以各方面的性能都要比号称相同资源配置的虚拟主机要更加优秀。在静态网站的部署上，手动部署与自动部署的差异基本不大。唯一可能需要的就是手动部署需要 VPS 的无密码登录配置，如果不是在自己常用的机器上，可能这一配置就不大方便。因此，自动部署还是在一定程度上为用户提供了便捷。
