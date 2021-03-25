---
layout: post
title: Ubuntu 14.04 安装 Composer+Laravel 配置
subtitle: Linux 下配置 laravel 环境
date: 2016-02-05 16:29:05 +0800
tags:
- ubuntu
- composer
- laravel
categories: [tech, PHP]
cover: 'https://images.unsplash.com/photo-1508804185872-d7badad00f7d?w=1600&h=900'
---
安装前提：系统已安装好 php 环境，可在全局使用 php 命令。
## 安装 compsoer 并设置为全局调用

```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

## 使用 composer 建立 laravel installer 安装工具

```bash
composer global require "laravel/installer"
```

## 将 laravel 命令添加进用户环境变量

&emsp;&emsp;打开`~/.bashrc`文件最末添加命令：`PATH=$PATH:~/.composer/vendor/bin`
`source ~/.bashrc` 命令使环境变量变化生效。

## 完成配置

&emsp;&emsp;可以在全局使用`laravel new {应用名称}`了。