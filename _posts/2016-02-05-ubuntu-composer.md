---
layout: post
title: ubuntu14.04安装composer+laravel配置
date: 2016-02-05 16:29:05 +0800
tags:
- ubuntu
- composer
- laravel
categories: tech
cover: 'https://images.unsplash.com/photo-1508804185872-d7badad00f7d?w=1600&h=900'
---
安装前提：系统已安装好php环境，可在全局使用php命令
# 安装compsoer并设置为全局调用
```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

# 使用composer建立laravel installer安装工具
```bash
composer global require "laravel/installer"
```

# 将laravel命令添加进用户环境变量
打开`~/.bashrc`文件最末添加命令：`PATH=$PATH:~/.composer/vendor/bin`
`source ~/.bashrc` 命令使环境变量变化生效

# 可以在全局使用laravel new {应用名称}了