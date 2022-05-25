---
layout: post
title: '个人免费博客花式搭建指南'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-05 16:03:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://unsplash.lisz.tk/1471107340929-a87cd0f5b5f3.webp'
cover_author: 'Aaron Burden'
cover_author_link: 'https://unsplash.com/@aaronburden'
tags: 
- blog
- free
- jekyll
- readthedoc
- cloudflare
- netlify
- ftp
- github
---

## 前言

&emsp;&emsp;越来越多的人想要搭建一个属于自己的免费个人博客，记录下自己在技术上的学习历程，或是写一些文章。甚至有一天，可以将这些文章整理成集出版。这也不是没有可能的，个人所知很多深受大众喜爱的技术书籍就是这样诞生的，像阮一峰大神的[《ES6 标准入门》](https://es6.ruanyifeng.com/)、杨宝华等的[《Docker 从入门到实践》](https://vuepress.mirror.docker-practice.com/)、刘遄老师的[《Linux 就该这么学》](https://www.linuxprobe.com/)等等。

### Markdown 的出现

&emsp;&emsp;很久以前想要搭建一个个人网站或者个人博客，可能非常困难，需要自己购买域名、虚拟主机或者虚拟服务器、搭建运行环境等等。为了简化这些步骤，开始有了一些免费建站工具出现，比如非常知名的 [凡科网](https://www.fkw.com)。当年笔者也是从这样的免费二级域名、免费拖拽式建站开始的，只不过后来越来越感受到了这种建站方式的局限性。首要的局限性就是免费的模板和功能有限，而想要更多好看的模板或者功能就需要付费升级，奈何并不想花钱买模板。于是开始投向了博客平台的怀抱，早期的博客平台有博客园、CSDN、InfoQ 等，发展到现在新兴的简书、掘金等等。虽然这些博客平台能让我们更加专注于编辑内容，但是也有受限的地方——有些想要的功能平台不可能马上就提供，比如现今博客平台都比较流行的 Markdown 编辑器。在 Markdown 语法流行于技术博客编辑之初，博客平台还是使用着“所见即所得”编辑器。当然，“所见即所得”编辑器并没有什么不好，至少对于初学者来说几乎零成本、包学包会。但是，Markdown 语法的出现无疑为博客编辑带来了一种全新的体验。按照规范化的文本内容标记编写，使用不同的 Markdown 语法翻译器和 CSS 样式，就可以带来丰富多彩的效果呈现。

### 静态网站生成器

&emsp;&emsp;正是 Markdown 的出现，呼唤出了一大批支持 Markdown 语法的**静态网站生成器**。最早开始，笔者是通过 [StaticGen](https://www.staticgen.com/) 这个站点才知道原来有这么多开箱即用的静态网站生成器。无论是用 NodeJS 编写的 Hexo，还是用 Ruby 编写的 Jekyll，甚至是用 Go 编写的 Hugo，都能轻易为你带来一个支持自定义模板、功能以及 Markdown 语法的个人网站或者个人博客。实际上，从这个站点列举出来的可以看出，至少有 322 种已知可用的静态网站生成器。这个网站还有一个很神奇的附带功能——它与 Netlify 相连接，从网站上就可以看出 Netlify 支持部署的静态网站生成器。

&emsp;&emsp;说到这里，又有一个新的名词出现了——Netlify。[Netlify](https://www.netlify.com) 其实是一个自带持续部署的网站，它需要与 Github 提供的持续集成联合使用。当 Github 指定的项目发生了推送操作时，Netlify 会通过已授权认证的方式从 Github 上拉取代码，并根据预设好的编译、部署命令生成最终的网页。这些网页在生成后，会被自动推送到 Netlify 的全球网络节点，并且会提供一个默认的 *.netlify.app 域名进行访问。这个默认的域名是可以完全自主定义的，只要与已有的域名不冲突即可。当然，用户也可以使用自己的域名解析到 Netlify，并且享有 Netlify 提供的免费 SSL 证书和全球节点加速。

&emsp;&emsp;其实 [Github](https://github.com) 本身也是提供这样的服务的，可以使用 username.github.io 的域名进行访问。之前 Github 的这个域名还是不提供 CDN 功能的，现在看起来像是有了所谓的 CDN 功能，但是实际的效果不得而知，因为笔者试着使用不同国家 IP 访问得到的地址都是美国的。国内的 [Gitee](https://gitee.com)、[Coding](https://coding.net)、国外的 [Gitlab](https://gitlab.com)、[SourceForge](https://sourceforge.net/) 等等都提供这类的功能，并且同样也存在 CDN 的短板问题。

### CDN

&emsp;&emsp;为了能够更好地保障 CDN 功能，通常来说加一层 CDN 在源站上也是可以了。不过大部分的 CDN 都是收费的，唯一不收费的、对全球用户友好的 CDN 可能就是 Cloudflare 了。Cloudflare 和 Netliy 除了提供 CDN 之外，还支持 IPv6，这也是大部分建站方式所不能提供的。可能是出于扩大业务的考虑， Cloudflare 现在也开始提供类似于 Netlify 的持续部署和免费静态页面托管服务，并且提供了一个非常棒的域名 *.pages.dev。 根据笔者的尝试，Cloudflare Pages 和 Netlify 的编译配置几乎一模一样，两者也同样为每一次的成功编译结果提供独立的预览域名，并将最新的编译生成结果自动设置为主域名对应内容。

### 其他

&emsp;&emsp;除了以上这些，也有一些其他的支持 Markdown 语法和部署简单的免费博客搭建方法，比如说将静态网站部署在普通虚拟主机、虚拟服务器上，将静态网站的文件当做是对象存储并开放匿名访问，使用 [Read the Docs](https://readthedocs.org/)、[GitBook](https://gitbook.com) 提供的在线文档编辑和托管服务等等。

## 实现与评价

&emsp;&emsp;这里就以笔者的个人博客站点为例解释一下如何使用静态生成器来搭建博客。其实，笔者的博客本来也不是静态生成器，最早还是 WordPress，后来过渡到 Hexo，再后来才转到 Jekyll。说实话，当时 Hexo 转投 Jekyll 也是因为发现了 [H2O](https://github.com/kaeyleo/jekyll-theme-H2O) 这个好看又优秀的 Jekyll 主题，果断选择切换到 Jekyll。当然，还有另外一个原因，Github 的原生支持静态生成器就是 Jekyll，这也意味着在 Github 上部署 Jekyll 更加方便。

&emsp;&emsp;Jekyll 的开始与 Hexo 有所不同，Hexo 是采用子目录的方式加载应用新的主题，而 Jekyll 则是采用主题化的方式应用主题。也就是说，如果你想使用某个 Jekyll 主题，唯一的方式就是克隆这个 Jekyll 主题的项目，并在此基础上开始你的博客。当然，Jekyll 完全支持用户在原有主题上进行更改，只要你了解文件是如何组织的、需要何种环境等等，你就可以做出自己的修改。为了保障原有主题的版权声明，即使你自己修改了一部分，也应该保留原有主题在底部的声明，你可以做的是加上自己的声明。在实际的使用过程中，笔者根据自己的需求也在 H2O 主题上做出了一定的功能修改，并开源为 [jekyll-them-H2O-ac](https://github.com/zhonger/jekyll-theme-H2O-ac)。

### Fork 项目

&emsp;&emsp;访问 [jekyll-them-H2O-ac](https://github.com/zhonger/jekyll-theme-H2O-ac)，点击 Fork 按钮，选择合适的用户命名空间。为了可以支持 username.github.io 域名直接展示该项目，建议在 Settings 里面将 Respository name 修改为 username.github.io，然后克隆项目到本地目录。

```bash
git clone git@github.com:zhonger/zhonger.github.io
```

### 修改配置

&emsp;&emsp;Jekyll 的配置文件 _config.yml 在主目录下，非常容易就可以找到，以下为一些常用的配置内容及解释。

```yaml
# Site settings 配置站点
# 博客名称
title: 'Mr Li'
# 博客描述，会出现在每个 HTML 页面的 head 部分
description: '个人的一个技术博客站点。'
# 博客整体的关键词，可以是多个，使用逗号分隔开，也会出现在 head 部分
keyword: 'zhonger，zhonger的博客，nodejs，kvm'
# 博客的顶级 URL，一般设置为主域名
url: 'https://lisz.me' # your host

# if you don't need baseurl, you should leave this value blank.
# 一般来说为空，如果是在子目录部署，需要修改为子目录名称
baseurl: ''

# Navigation links
# 导航栏，一般是顶级的页面链接
nav:
  home: '/'
  blog: '/blog/'
  archives: '/archives.html'
  tags: '/tags.html'
  RSS: '/feed.xml'
  logs: '/logs.html'

# Footer 设置博客开始的年份
footer:
  since: 2015

# Author 配置博主信息
author: 'zhonger'
nickname: 'zhonger'
bio: 'Developer & Maintainer'
avatar: '/assets/img/profile.webp'
favicon: "/assets/icons/favicon.ico"

# permalink 设置文章生成时的链接格式
permalink: /:categories/:title.html

# timezone 时区
timezone: Asia/Shanghai

# Search 是否开始搜索
search: true

# Night mode 是否开启黑夜模式
nightMode: false

# Comments 评论区设置，支持 Disqus
disqus: true
disqus_url: 'https://zhonger.disqus.com/embed.js'

# Share 是否开启文章分享功能以及何种分享方式
social-share: true
social-share-items: ['wechat', 'weibo', 'douban', 'twitter']

# theme color 主题皮肤
theme-color: 'default'  # pink or default

# Post header background patterns (when the post no cover): circuitBoard, overlappingCircles, food, glamorous, ticTacToe, seaOfClouds
# 当未设置文章封面时文章的默认顶部背景模式
postPatterns: 'food'

# SNS settings 配置社交网站url: weibo, zhihu, twitter, instagram, juejin, github, douban, facebook, dribble, uicn, jianshu, medium, linkedin
sns:
  facebook: 'https://facebook.com/zhonger95'
  github: 'https://github.com/zhonger'
  linkedin: 'https://www.linkedin.com/in/shengzhouli/'

# Tags 设置标签
recommend-tags: true # whether or not display recommend-tags on the sidebar
recommend-condition-size: 12 # a tag will be recommended if the size of it is more than this value

# Build settings
# 文章列表展示页每页显示的文章数量、路径以及跳过文件列表
paginate: 10
paginate_path: 'blog/page:num'
exclude: ['node_modules', 'dev', 'package.json', 'gulpfile.js', '.gitignore', 'README.md']

# Markdown 翻译器和语法着色工具
markdown: kramdown
highlighter: prism
kramdown:
  input: GFM

# 是否开启 RSS 订阅
RSS: true

# Plugins 编译时所需的 Jekyll 插件
plugins: [jekyll-paginate, jekyll-feed, jemoji, jekyll-sitemap]

# Netlify 设置选项，指定遵循的强制跳转规则
include: [_redirects]
```

### 撰写文章

&emsp;&emsp;Jekyll 的撰写文章非常简单，只要在 _posts 目录下创建符合“年份-月份-日期-文章名称.md”规则的文件即可，比如“2021-04-05-start-blog.md”。其中需要注意的是，文章名称需使用英语，并且单词与单词之间的连接符使用 -。当使用前述的主题时，文章开始的配置声明部分包含 layout (使用的模板)、title (文章标题)、subtitle (文章副标题)、date (撰写日期)、tags (标签)、categories (分类) 和 cover (封面图片)。其他内容可以按照符合 Markdown 语法和自己的规范去写。以下为文章内容格式示例：

```markdown
---
layout: post
title: '个人免费博客花式搭建指南'
subtitle: '搭建一个属于自己的免费个人博客'
date: 2021-04-05 16:03:00 +0800
tags: 
- blog
- free
- static
categories: [tech, webmaster]
cover: 'https://unsplash.lisz.tk/1471107340929-a87cd0f5b5f3?w=1600&q=900'
---

## 前言

开始内容
```

#### 书写规范

&emsp;&emsp; 这里也分享一些个人在书写 Markdown 内容时慢慢总结出的 Markdown 语法和文章规范，如下所示：

##### Markdown 语法指南

```markdown
# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题

普通段落文件（直接输入）

**加粗**
*斜体*
`段落内标签，通常在段落中引用命令时使用`
<u>下划线</u>
~~删除线 ~~
<sub>下标</sub>
<sup>上标</sup>

- 无序列表 
- 无序列表

1. 有序列表
2. 有序列表

| 表头 1 | 表头 2  | 表头 3 |
| :---: | :--- | ---: |
| 表内第一行 | 表内第一行 | 表内第一行  |
| 居中 | 左对齐 | 右对齐  |

> 引用

- [x] 任务一   （已完成状态）
- [ ] 任务二   （未完成状态）

[超链接显示内容](超链接地址)
![图片名](图片所在地址)

​```cpp
# 代码文件名，比如 leetcode0001.cpp

代码内容（文件名与内容之间留一行空白，内容最后不留空行）
# 代码内注释
​```

<!-- 注释内容，以下为公式 -->
$$
y=x^2  
$$
```

##### 通用文章规范

- 英文或是数字与中文之间前后各有一个空格，超链接、段内标签等与中文之间也需如此；
- 英文为行首时，前面不留空格；
- 英文与英文标点符号一起时，前面标点符号后空一格开始英文单词；
- 英文与中文标点符号一起时，标点符号在英文或符号之前之后都无须空格；
- 在代码内容中，# 号与文字之间空一格，# 号与代码同行时距离不宜过长，如相邻几行都有注释对齐为佳；当代码注释内容超过一行时最好将注释放在代码的后一行，此时 # 号前不留空格；
- 在使用图片进行解释的时候，在对应段落附近加载图片，并使用“下图”、“上图”这样的字眼进行描述；
- 图片可以使用 PPT 自行制作，使用 [Snipaste 截图工具](https://zh.snipaste.com/) 截图保存，也可下载分辨率高的 PNG 图或者 SVG 图，并上传至 [vgy.me](https://vgy.me) 后加载使用；
- 编程语言、专用英文词汇使用时，根据其通用的写法来适当调整大小写，比如 Python 3 的第一个字母就需要大写，Java 的第一个字母也需要大写；
- 当括号内是英文字符，使用英文括号（半角）；当括号内是中文字符时，使用中文括号（全角）；当括号外是英文、括号内是中文时，可以使用英文括号（半角）来缩短字符距离，不过英文与括号之间须有空格。

### 预览

&emsp;&emsp;Jekyll 本身就提供了预览功能，如下所示安装主题所需 Jekyll 插件，并启动实时在线预览。

```bash
# 已安装 Ruby 和最新版 Gem

# 安装 bundle
gem install bundle

# 在代码主目录安装主题所需 Jekyll 插件
bundle install

# 启动实时在线预览
bundle exec jekyll serve --livereload

# 浏览器访问 http://127.0.0.1:4000/ 即可
```

### 发布部署

```bash
# 使用以下命令将更新内容添加到 Git 跟踪并提交到 Github 项目的 main 分支

git status
git add -A
git commit -m 'add xxxx'
git push origin main
```

&emsp;&emsp;在**前言**中已经提到了非常多种免费的博客发布方法，为了对这些方法更加详细地描述，按照发布部署方式的不同分类成以下几篇文章。

- [Github 篇](start-blog-github)
- [Netlify 篇](start-blog-netlify)
- [Cloudflare 篇](start-blog-cloudflare)
- [FTP 篇](start-blog-ftp)
- [VPS 篇](start-blog-vps)
- [Online Editor 篇](start-blog-online-editor)

&emsp;&emsp;本站对于以上几种部署方式也有不同的节点对应，如下所示：

| 托管方 | 支持访问域名 | 部署方式 | IPv6 | 备注 |
| :----: | :----: | :----: | :----: | ---- |
| Netlify | [lisz.me](https://lisz.me) | Netlify | 是 | 全球性节点 |
| Github | [blog.lui8.cn](https://blog.lui8.cn) | Github | 否 | 美国节点 |
| Cloudflare| [lui.site](https://lui.site) | Cloudflare | 是 | 全球性节点 |
| 阿里云服务器 | [www.lisz.ink](https://www.lisz.ink) | VPS | 否 | 国内单节点 |
| 腾讯云服务器 | [luish.cc](https://luish.cc) | VPS | 否 | 国内单节点 |
| 腾讯云 COS | [lisz.ink](https://lisz.ink) | 对象存储 | 否 | 国内 CDN 节点 |
| 筑波大学 | [u.tsukuba.ac.jp](https://www.u.tsukuba.ac.jp/~s2036012/) | FTP | 否 | 日本单节点 |

## 写在最后

&emsp;&emsp;跟着笔者了解了这些，是不是突然觉得搭建一个属于自己的免费个人博客其实也不难，而且还可以有这么多免费节点，感兴趣的话就快来试一试吧！
