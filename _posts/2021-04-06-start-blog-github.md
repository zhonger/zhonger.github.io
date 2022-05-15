---
layout: post
title: '个人免费博客花式搭建指南 Github 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-06 16:10:00 +0800
tags: 
- blog
- free
- static
- hexo
- jekyll
- github
categories: [tech, webmaster]
cover: 'https://images.unsplash.com/photo-1617871911112-757893b9f0df?w=1600&q=900'
---

## 前言

&emsp;&emsp;大家都知道 Github 不仅是全球性的代码托管网站，也是世界上最大的支持 Git 版本协议的开发协作平台。绝大多数的知名的开源项目都托管在 Github 上，即使开发代码不在 Github 上，也会在 Github 上开启一个镜像项目。可以说，Github 上只有你想不到的、没有你找不到的代码。另外，我们可以从 [Github Pages](https://pages.github.com/) 的官网上看到，Github 本身所提供的 Pages 功能，不仅仅可以用于展示项目、引导用户下载，同样也可以用于搭建个人网站或者个人博客。无论是单纯的静态网页，还是静态网站生成器生气的网页，都可以使用 Github Pages 向所有人公开展示。

## 部署

&emsp;&emsp;在已经完成 Jekyll 博客的内容编辑和更新提交的前提下，执行以下操作来完成在 Github 的在线部署。

### 开启 Pages

&emsp;&emsp;访问 Github 项目，点击 Settings。

![开启 Pages Enable Pages](https://i.lisz.top/blog/16b12O.webp)

### 选择分支

&emsp;&emsp;下拉至 Github Pages，选择分支为 master 或者 main，目录为根目录，不要选择主题，建议 Enforce HTTPS。

![选择分支 Select branch](https://i.lisz.top/blog/2bRpVi.webp)

### 自定义域名(可选)

&emsp;&emsp;如果想用自己的域名，可以如上图所示添加一个 CNAME 解析记录到 username.github.io 上，并在自定义域名框中填写该域名。

## 验证

&emsp;&emsp;浏览器访问 <https://username.github.io> 或自定义域名即可验证是否成功部署。如果访问失败，可能是因为编译过程失败。一般来说，在本地预览成功，Github 编译也不会有什么大问题。

（2022年5月15日更新）

> info "小提示"
> &emsp;&emsp;如果发现因为使用了 Github 默认不支持的插件而编译失败，可以使用 Github Action 来自定义编译过程。详情请移步 [《利用 Github Action 一键编译多平台 Docker 镜像》](../docker/github-action.html)。
