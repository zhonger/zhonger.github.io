---
layout: post
title: '个人免费博客花式搭建指南 Online Editor 篇'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-11 16:15:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.luish.cc/cover/iuGS5d.webp'
cover_author: 'Polina Abramova'
cover_author_link: 'https://unsplash.com/@mandariin'
tags: 
- blog
- free
- static
- jekyll
- gitbook
- readthedoc
- ftp
- github
---

## 前言

&emsp;&emsp;近些年，随着 Markdown 的蓬勃发展，越来越多地支持 Markdown 语法的在线编辑器和托管服务提供商出现。比如国外的 [Read the Docs](https://readthedocs.org/)、[Gitbook](https://gitbook.com) 等等，国内的 [看云](https://www.kancloud.cn/) 等等。这种方式的好处主要有几点：

- 不需要任何环境配置，只需要浏览器就可以完成编辑和预览；
- 当完成编辑时即发布，无须考虑手动部署或者自动部署的问题；
- 可以直接把编辑的内容直接放在一起导出一本 PDF 电子书。
- 由于运行资源没有限制，完全与平台相关，访问速度及最大并发访问量可能较高。

&emsp;&emsp;当然，这种方式也会有一定的缺点：

- 无法定制呈现内容的样式，更无法修改模板；
- 平台提供的在线编辑器的体验可能并没有离线编辑器的体验这么好，比如优秀的 [Typora](https://typora.io)；
- 对于页面权限的控制受限，无法像博客那样可以自由控制；
- 不一定支持自定义域名，或需付费才支持自定义域名。

&emsp;&emsp;个人觉得比起搭建博客这类方式更适合搭建文档，比如说写产品文档、API 文档等等，而且其导出 PDF 的特点更加适合需求。

## 体验与评价

### Read the Docs

#### 登录

&emsp;&emsp;访问 [Read the Docs](https://readthedocs.org/) 点击**登录**按钮，这里支持直接使用 Github 登录（推荐）。

![访问 Visit Read the Docs](https://i.luish.cc/blog/fVRO1k.webp)

![登录 Login Read the Docs](https://i.luish.cc/blog/t2pFT9.webp)

#### 导入项目

&emsp;&emsp;由于是 Github 方式登录，可以直接从 Github 中导入项目，如下图所示。

![导入项目 Import codes](https://i.luish.cc/blog/MryiQH.webp)

&emsp;&emsp;点击右侧加号按钮完成导入。

![选择项目 Select project](https://i.luish.cc/blog/2wtoFP.webp)

![基本配置 Basic settings](https://i.luish.cc/blog/dU4Mkp.webp)

#### 预览项目

&emsp;&emsp;由于这里导入的项目是 Jekyll，所以 Read the Docs 无法对其进行编译并显示预览页面。事实上，如果将 Jekylll 换成 Mkdocs，会发现能够通过编译并在线预览成功，但是 PDF 生成还是会有问题。所以最好的就是在 Github 建一个空的项目，将空的项目导入到 Read the Docs 中即可。

&emsp;&emsp;其实，Read the Docs 还不能算得上是完整的在线编辑平台，毕竟它不提供所谓的 Online Editor。我们仍然需要使用 Github 自身提供的在线编辑功能，或者利用本地编辑器 Typora 这样的编辑然后上传更新到 Github。当然，如果 Github 的内容发生了更新，Read the Docs 将会拉取最新的内容进行编译并激活预览。

### Gitbook

#### 登录

&emsp;&emsp;访问 [Gitbook](https://gitbook.com) ，可以选择 Sign Up With Github 进行快速注册。

![访问 Visit Gitbook](https://i.luish.cc/blog/Ih0lNS.webp)

#### 创建项目

&emsp;&emsp;点击 create a new space 按钮，输入项目名称完成创建。

![创建项目 Create project](https://i.luish.cc/blog/uEgF18.webp)

#### 导入内容

&emsp;&emsp;如下图所示，可以直接导入 Markdown 文件。由于本站是采用 Jekyll 静态生成器的，所有只需将 _posts 目录下的 Markdown 文件全部拖拽到这里导入即可完成 Gitbook 的转换。

![导入内容 Import codes](https://i.luish.cc/blog/BLngkD.webp)

![查看内容文件 Check files](https://i.luish.cc/blog/ssplcq.webp)

#### 预览项目

&emsp;&emsp;Gitbook 采用的是 <https://用户名.gitbook.io/项目名/> 的方式预览，当然也支持自定义域名。

### 评价

&emsp;&emsp;Read the Docs 与 Gitbook 相比，后者支持完整的在线编辑功能和自定义主题功能，操作也略显复杂，前者则只负责编译生成和托管页面，不具有编辑能力。从笔者个人角度来看， Read the Docs 的方式更加方便快捷，操作性强，而 Gitbook 复杂的操作让本来编辑内容的时间都花在了一步一步的操作上了。虽然两者都支持 PDF 导出功能，但是 Read the Docs 导出的 PDF 格式更加像是一本电子书，排版精美，而 Gitbook 则是普通的格式。另外，在网页预览上，Gitbook 则更加大方、美观，比 Read the Docs 更具现代感，两者优势各异。当然也可以同时使用两种，取长而用。
