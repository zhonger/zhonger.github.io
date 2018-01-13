---
title: Gravatar Fixed 头像载入出错
date: 2015-08-08 15:41:01
tags:
- gravatar 
- wordpress
categories: tech
---

WordPress使用的用户默认头像是Gravatar Fixed 头像，由于种种原因，经常在国内载入出错。一般的解决办法有好几种，主要的是Gravatar Fixed 插件和修改wp-include中文件代码。
# 一、Gravatar Fixed 插件
在管理后台搜索该插件，排在第一的应该是`FV Gravatar Cache`插件，然而这个插件需要使用到国外google的一些东西，所以载入也基本上是没什么戏。还是用第二种方法，虽然不能一劳永逸，但是不升级wordpress时还是蛮管用的。
# 二、修改wp-include目录下的`link-template.php`文件（大约在3604行）
1.使用vi工具编辑该文件，按esc键，直接输入`3604gg`（无回显），代码就会自动跳转到指定的3604行
2.按照下面修改：
```bash
$url = sprintf(‘http://%d.gravatar.com/avatar/%s’, $gravatar_server, $email_hash );
```
修改为
```bash
$url = sprintf(‘http://cn.gravatar.com/avatar/%s’, $email_hash );
```