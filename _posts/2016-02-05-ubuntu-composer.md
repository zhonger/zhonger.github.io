---
layout: post
title: Ubuntu 14.04 安装 Composer+Laravel 配置
subtitle: Linux 下配置 laravel 环境
date: 2016-02-05 16:29:05 +0800
categories: [tech, PHP]
author: zhonger
cover: 'https://i.lisz.top/cover/6MMpoJ.webp'
cover_author: 'Dayne Topkin'
cover_author_link: 'https://unsplash.com/@dtopkin1'
tags:
- ubuntu
- composer
- laravel
---

## 安装前提

&emsp;&emsp;系统已安装好 php 环境，可在全局使用 php 命令。

## 安装步骤

### 安装 Compsoer

&emsp;&emsp;从 [Composer 官网](https://getcomposer.org/) 下载已编译可执行文件并设置为全局调用。

```bash
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
```

### 安装 Laravel 工具

&emsp;&emsp;使用 Composer 命令全局安装 Laravel Installer 工具库。

```bash
composer global require "laravel/installer"
```

### 配置环境变量

&emsp;&emsp;将 `laravel` 命令添加进用户环境变量。

```bash
# 在 .bashrc 文件的末尾加入

tee -a ~/.bashrc << EOF
PATH=$PATH:~/.composer/vendor/bin
EOF
source ~/.bashrc
```

## 验证安装

&emsp;&emsp;可以在全局使用 `laravel new {应用名称}` 了。
