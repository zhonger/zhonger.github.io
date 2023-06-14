---
layout: post
title: '个人免费博客花式搭建指南 Netlify 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-07 16:17:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/JUFXBQ.webp'
cover_author: 'Norbert Buduczki'
cover_author_link: 'https://unsplash.com/@buduczki'
tags: 
- blog
- free
- static
- hexo
- jekyll
- netlify
- github
---

## 前言

> citation "Wikipedia"
> &emsp;&emsp;Netlify 是一家位于旧金山的云计算公司，为 Web 应用程序和静态网站提供托管和无服务后端服务。其功能包括通过 Netlify Edge、该公司的全球应用程序交付网络基础架构、无服务表单处理、对 AWS Lambda 功能的支持以及与 Let's Encrypt 的完全集成从 Git 开始进行持续部署。

&emsp;&emsp;[Netlify](https://www.netlify.com/) 是什么？从维基百科上可以很容易找到以上答案。Netlify 所提供的服务既有免费的，也有收费的，一般来说免费服务对于部署 Jekyll 博客就已经绰绰有余了。Netlify 与 Github 的联系非常紧密，拥有 Github 账户就可以直接登录 Netlify，Netlify 需要从 Github 拉取代码来编译、生成、部署静态站点。Netlify的每月免费套餐包含了 100GB 的免费流量、300 分钟的编译时长，1 个同时编译队列。通常一个静态网站生成器所需的编译时长可能不超过一分钟，因此只要不是一个月提交的变更次数超过 300 次编译时长完全足够。而全球访问流量因为 Netlify 本身就带流量清洗的能力，即使有人对站点发起攻击也不会有什么疯狂增加的可能，所以正常一个站点一个月可能最多只能用到 1GB 不到的流量。如果文章遵循了图片使用图库托管的策略，那么所耗流量会大大降低、访问速度也会大大提升。

## 部署

### 登录 Netlify

&emsp;&emsp;正常使用 Github 账号一键登录之后，在 Teams 主页面点击 New site from Git 按钮。

![登录 Login](https://i.lisz.top/blog/4dTnLf.webp)

### 新建项目

&emsp;&emsp;点击 Github 按钮登录并授予 Netlify 访问项目权限。

![新建项目 Create project from Github](https://i.lisz.top/blog/p4vWTR.webp)

### 选择项目

&emsp;&emsp;在搜索框中搜索想要部署的项目，比如 zhonger/zhonger.github.io，并点击右侧箭头选中完成创建。

![选择项目 Select project](https://i.lisz.top/blog/RClRWo.webp)

### 自定义域名

&emsp;&emsp;在创建好的项目的 Site settings 的 Domain management 中可以对已有的 *.netlify.app 域名进行修改，或添加自定义域名。

![自定义域名 Custom domain](https://i.lisz.top/blog/wpkz2p.webp)

### 启用 HTTPS

&emsp;&emsp;拉到页面下方 HTTPS 对已有域名生成 SSL 免费证书，只要第一次设置后，以后会自动更新。

![启用 HTTPS Enable HTTPS](https://i.lisz.top/blog/74HffD.webp)

### 配置变量（可选）

&emsp;&emsp;另外，对于编译命令和变量的设置一般在项目创建之初完成，也可以在 Site settings 的 Build & deploy 中进行修改。默认的 Jekyll 设置如下所示：

![vgy.me](https://i.lisz.top/blog/gDt22R.webp)

### 查看编译日志（可选）

&emsp;&emsp;关于编译过程可以在 Deploys 里面查看所有的日志，并且可以预览每一次编译的结果。

![vgy.me](https://i.lisz.top/blog/UMVUaz.webp)
![vgy.me](https://i.lisz.top/blog/cfMYpw.webp)

## 验证

&emsp;&emsp;浏览器访问 *.netlify.app 域名或者自定义域名或者编译的 Preview deploy 域名，查看上线后的效果。
