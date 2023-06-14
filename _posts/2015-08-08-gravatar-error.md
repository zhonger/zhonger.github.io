---
layout: post
title: Gravatar Fixed 头像载入出错
subtitle: WordPress 中的 Gravatar 头像问题
date: 2015-08-08 15:41:01 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/XtFvt5.webp'
cover_author: 'Kalen Emsley'
cover_author_link: 'https://unsplash.com/@kalenemsley'
tags:
- gravatar 
- wordpress
---

&emsp;&emsp;WordPress 使用的用户默认头像是 Gravatar Fixed 头像，由于种种原因，经常在国内载入出错。一般的解决办法有好几种，主要的是 Gravatar Fixed 插件和修改 wp-include 中文件代码。

## 安装 Gravatar Fixed 插件

&emsp;&emsp;在管理后台搜索该插件，排在第一的应该是 `FV Gravatar Cache` 插件，然而这个插件需要使用到国外 google 的一些东西，所以载入也基本上是没什么戏。还是用第二种方法，虽然不能一劳永逸，但是不升级 wordpress 时还是蛮管用的。

## 修改配置文件

修改 wp-include 目录下的 `link-template.php` 文件（大约在3604行）

1. 使用 vi 工具编辑该文件，按 esc 键，直接输入 `3604gg`（无回显），代码就会自动跳转到指定的 3604 行。
2. 按照下面修改：

```bash
$url = sprintf(‘http://%d.gravatar.com/avatar/%s’, $gravatar_server, $email_hash );
修改为
$url = sprintf(‘http://cn.gravatar.com/avatar/%s’, $email_hash );
```
