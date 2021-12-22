---
layout: post
title: 'H2O-ac theme for Jekyll'
subtitle: '基于或许是最漂亮的 Jekyll 主题 H2O 的学术版'
date: 2021-12-22 19:50:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://images.unsplash.com/photo-1614659754166-a2fd14dbc4d3?w=1600&q=900'
tags: jekyll theme blog ac develop 主题 前端开发 学术 运维
---

## 前言

&emsp;&emsp;正如大家所知，Jekyll 是一款高可定制的、非常流行的静态博客生成工具。围绕着 Jekyll 也衍生出了很多优秀的 Jekyll 主题， 由 [廖柯宇](https://github.com/kaeyleo) 开发的 [H2O](https://github.com/kaeyleo/jekyll-theme-H2O) 主题就是其中之一。极简主义、风格扁平化、卡片式布局、Medium 及知乎专栏的视觉风格等等特点，为我们带来了或许是迄今为止最漂亮的 Jekyll 主题。

&emsp;&emsp;诞生之初，H2O 主题就在 Github 平台上以 MIT 许可证协议开放了源代码。这吸引了很多小伙伴纷纷转投 Jekyll 和 H2O 主题的阵营，本人也是其中之一。随着使用者越来越多，不少的小伙伴在使用过程中发现了一些小问题并主动修复，最后贡献到了 H2O 的主项目，这让 H2O 主题变得更好。本人在使用过程中也的确是发现了一些与自己实际需求不大一致的地方，并且在原 H2O 主题的基础上做了一些改动。考虑到这些改动可能并不是大多数人的需求，直接向原 H2O 主题提交 pull 请求合并的必要性不大，因此决定将原项目 fork 并改名为 [zhonger/jekyll-theme-H2O-ac](https://github.com/zhonger/jekyll-theme-H2O-ac)。现正式将源代码以与 H2O 主题相同的 MIT 许可证协议在 Github 平台上公开。

&emsp;&emsp;在此，非常感谢廖柯宇及其他小伙伴对于 H2O-ac 主题的基础主题 H2O 的代码开发和开放共享。

## 新特性

### 更适合学术人和运维程序员的页面结构

&emsp;&emsp;H2O 主题其实在很大程度上已经满足了大部分人的需求，只是对于学术研究人员和运维程序员来说，个人觉得页面结构还是有点不够合适。学术研究人员比较重视在首页直接展示个人信息和研究情况，能够让人很快地了解到所需的信息，这其实是将 About me 这样一个平常的辅助页面当成了主页面来用。另外，运维程序员比较重视能一览所有文章的标题以迅速找到感兴趣的文章。虽然搜索功能、标签页、卡片展示页都能够列出所有的文章，但个人觉得还是不够简洁、方便。而像 Hexo 静态生成工具自带的 Archive 归档页面比较能满足这样的需求。除此之外，整个博客的系统日志变迁记录对于运维程序员来说也非常重要，毕竟如果通过发布一篇文章来描述变迁过程并不适合联系起来完整了解。如果有系统日志页，就可以按照年份、月份、事件的先后进行简要的描述，并且一览无遗。

&emsp;&emsp;因此，在 H2O-ac 主题中，从原来 H2O 的主页中抽出框架做成了页面模板。根据实际页面的内容需求，增加了**学术首页**、**归档页**和**系统日志页**。

#### 学术首页

&emsp;&emsp;学术首页如下图所示，并将原来 H2O 中的卡片首页移动到 blog 子目录下了。如果读者想要看到文章卡片展示页，还是可以点击顶部的导航栏中的 BLOG 直接访问。

![vgy.me](https://i.vgy.me/pICzcE.png)

#### 归档页

&emsp;&emsp;归档页设置为由 Jekyll 按照模板自动生成，以年份、日期、文章标题分级列表展示，简洁清晰。

![vgy.me](https://i.vgy.me/25IZzc.png)

#### 系统日志页

&emsp;&emsp;系统日志页其实也不是经常更新的，只有在博客整体作出设置或改进的才加以说明。另外，也可以将一些固定的站点信息放置在系统日志页，比如站点的多点部署信息，读者可以根据此信息访问最快、最合适的节点。

![vgy.me](https://i.vgy.me/tUCNEb.png)

### 使用体验提升

&emsp;&emsp;廖柯宇也在 H2O 主题的默认页面中写道，目前 H2O 主题还有一些可优化的内容，比如夜间模式、查看大图等。这里，根据个人的一些实际需求和了解，在 H2O-ac 主题中做了调整。

#### 社交图标扩展

&emsp;&emsp;H2O 原有的社交图标其实已经比较广泛，只是还有些领域局限性，比如学术研究人员可能更希望展示谷歌学术、ResearchGate、ORCID 等社交图标及链接，而运维开发人员可能更希望展示 SegmentFault、CSDN、博客园等社交图标及链接。这里在 H2O 提供的社交图标类型基础上做了这些平台图标的扩充，同时尝试了 Symbol 引用的方式来实现社交图标鼠标悬停的效果，从而简化代码（H2O 采用的是字体图标的方式，需要为每一个社交图标定义不同的主题色）。

![vgy.me](https://i.vgy.me/ebCeqM.png)

#### 查看大图

&emsp;&emsp;查看大图功能的确对于读者的阅读体验来说有很大的提升。就像我们阅读文献一样，可能首先会只看文章附图来大致掌握文章的核心点。博文的查看大图功能也可能有这样的异曲同工之妙。这里是采用的 [Fancybox](https://fancyapps.com/docs/ui/fancybox) 插件实现的。H2O-ac 主题中只使用了最简单的配置，用户可以根据需求查看文档做出更多的修改。

![vgy.me](https://i.vgy.me/FNRDTv.png)

#### 代码高亮优化

&emsp;&emsp;本人使用 H2O 主题的时候代码高亮功能还是沿用的 Jekyll 自带的，后来 H2O 主题也开始采用了 [Prism.js](https://prismjs.com/)。不过由于使用的是 `OKAIDIA` 高亮主题，所以有些段落中的格式化字段显示上有些问题。这里，仍然采用默认主题，并且扩增到 Prism.js 支持的所有编程语言类型。效果可以从前一句的 OKAIDIA 字段和下面即将出现的代码片段看出。

#### 字数统计及阅读时间估计

&emsp;&emsp;字数统计及阅读时间估计这个小功能其实以前在用 WordPress 的时候比较常见。虽然说统计和估计的结果不一定完全准确，但是还是起到了一定的辅助阅读的作用。效果可以查看本页标题下的基本信息区域。

#### 配置项

&emsp;&emsp;配置项中新增了**友情链接**和**备案号**功能，可以直接在 _config.yml 文件的对应配置项下设置即可，如下所示。友情链接主要是方便跟其他博主交换友链，备案号主要是为了方便部署在国内需备案的 vps 或虚拟主机上。此处，二者都可以置空。

```yaml
# Links 友情链接
links:
  'Mr Li': 'https://lisz.me'

# Beian 备案号
beian: '沪ICP备xxxxxxxx号'
```

#### 前端自动构建工作流优化

&emsp;&emsp;H2O 主题中使用了 Gulp + Node-Sass 的方案来自动化前端构建工作流。不得不说，这个方案还是很不错的，只是随着 Gulp 和 Node-Sass 版本的更新，对 NodeJS 环境及其他依赖库都有一些要求。这里，H2O-ac 主题在 package.json 文件中将所有库都更新到目前最新，对应版本列表如下所示。另外，为了减少一些第三方 CSS 样式的请求数，利用自动构建工作流将固定的第三方 CSS 样式文件合并并压缩为 plugins.min.css 文件。app.min.css 仍为多个自编写 CSS 样式文件的合并压缩。

| 运行环境或依赖库 | 版本号 |
| :--: | :--: |
| NodeJS | v17.0.0 | 
| gulp | v4.0.2 | 
| gulp-clean-css | v4.3.0 | 
| gulp-rename | v20.0 | 
| gulp-sass | v5.0.0 | 
| gulp-uglify | v3.0.2 | 
| gulp-concat | v2.6.1 | 
| node-sass | v7.0.0 | 

## 使用方法

### 初始化

#### 方式一：从模板新建博客

&emsp;&emsp;为了方便用户使用 H2O-ac 主题，特别提供了 Github 的模板功能。如下图所示，访问 [H2O-ac](https://github.com/zhonger/jekyll-theme-H2O-ac) 可以看到如下的 Use this template 按钮，点击该按钮即可用 H2O-ac 主题创建自己的博客代码仓库。想要了解更多步骤，可以访问 Github 官方文档之 [从模板创建仓库](https://docs.github.com/cn/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)。

![vgy.me](https://i.vgy.me/y7lv2Q.png)

#### 方式二：已有博客迁移

&emsp;&emsp;暂时无法支持 gem 直接切换主题，后续将更新此方式。目前只能使用方式一创建仓库后，将文章的 markdown 文件复制到 _posts 目录下应用 H2O-ac 主题。

### 本地测试

&emsp;&emsp;在进行本地测试时，如果需要修改一些样式，则需要先执行 `npm install` 来完成前端自动构建工作流依赖库的安装。注意，这里设定的可用 NodeJS 版本为 v17.0.0，使用老版本会报错。其次，务必使用 `bundle install` 安装主题所需的所有 Ruby 依赖库。最后执行 `bundle exec jekyll serve --livereload` 命令即可在本地实时同步预览。只要不修改 _config.yml 文件，不必中断后再启动。然后就是在 _posts 目录下写 markdown 文章即可。

### 发布部署

&emsp;&emsp;由于 Github 提供 Jekyll 静态生成器的静态页面托管，只要打开仓库的 Pages 功能，当推送更新到 Github 时即会自动部署。此处值得注意的是，如果代码仓库的名字不是 `username.github.io`，而也没有为该仓库的 Pages 提供自定义域名，那么这个仓库将会被部署到子目录，因此此时必须在 _config.yml 文件中设置 base_url，从而生成正常的静态页面。

## 结束语

&emsp;&emsp;再次感谢廖柯宇及其他小伙伴们对 H2O 主题的付出，没有 H2O 主题就没有 H2O-ac 主题！H2O-ac 主题后续也将继续更新，欢迎小伙伴们使用和 [Star](https://github.com/zhonger/jekyll-theme-H2O-ac)，也欢迎大家一起来贡献代码。

（Ps: 由于沿用了 H2O 的 Logo，可能会侵犯廖柯宇的版权。如果的确如此，后续将会设计一个新的 Logo。）