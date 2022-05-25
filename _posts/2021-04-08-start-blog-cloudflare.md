---
layout: post
title: '个人免费博客花式搭建指南 Cloudflare 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-08 16:18:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://unsplash.lisz.tk/1610070945206-2f5cafcb4e2b.webp'
cover_author: 'Malik Skydsgaard'
cover_author_link: 'https://unsplash.com/@malikskyds'
tags: 
- blog
- free
- static
- hexo
- jekyll
- cloudflare
- netlify
- github
---

## 前言

&emsp;&emsp;众所周知，Cloudflare 是一家世界知名的 CDN 网络提供商，其在 DDoS 保护、网页应用程序防火墙、域名服务器、内容分发网络等服务上都有非常优秀。2018 年 4 月 1 日，Cloudflare 与 ASNIC 联合推出了声称“隐私第一”的域名系统解析服务。之后的 11 月 11 日又推出了 1.1.1.1 解析器的手机应用程序、电脑应用程序。并且，Cloudflare 也一直在为 HTTP 协议规范、IPv6 推广部署等方面作出了贡献。Cloudflare 提供了基础的免费服务给广大用户，同时也带来了最新的 Web 服务体验，Cloudflare Pages 就是这样的一款产品。

## 实现与评价

### Cloudflare

#### 登录

&emsp;&emsp;访问 [Cloudflare Pages 官网](https://pages.cloudflare.com/)，点击 Sign Up 按钮使用 Cloudflare 账户登录。

![登录 Login](https://i.lisz.top/blog/a0C23w.webp)

#### 创建项目

&emsp;&emsp;登录后点击**创建项目**按钮开始创建。

![创建项目 Create project](https://i.lisz.top/blog/s12Jkr.webp)

&emsp;&emsp;选择一个 Github 的项目，比如 zhonger/zhonger.github.io。

![选择项目 Select project](https://i.lisz.top/blog/YwXaml.webp)

&emsp;&emsp;设置永久访问域名前缀，部署分支，以及所用的静态生成框架，然后点击**保存并部署**。

![设置域名前缀 Set domain prefix](https://i.lisz.top/blog/Q3uTjI.webp)

#### 预览

&emsp;&emsp;添加完成后等待完成构建与部署，可以看到目前绑定的域名。点击访问站点即可跳转预览

![预览 Preview](https://i.lisz.top/blog/t8ZdUt.webp)

### 评价

&emsp;&emsp;Cloudflare Pages 的部署步骤其实与 Netlify 大致上一致。从支持的功能上来讲，Cloudflare Pages 还是比较侧重于提供持续部署的能力，没有 Netlify 铺的面那么宽，但是也是只要是静态生成器都能完全支持。由于 Cloudflare 本身就是做 CDN 的，所以和 Netlify 在实现全球性部署的时候还是有不一样的地方的。由于 Cloudflare 的节点数量较多、网络线路较优，访问速度上可能会比 Netlify 好那么一点。不过，是否存在这样的差异还不得而知。
