---
layout: post
title: Laravel 5.2 在 LNMPA 一键安装包环境下的部署
subtitle: Linux 上配置 Laravel 环境
date: 2016-03-14 22:19:48 +0800
categories: [tech, PHP]
author: zhonger
cover: 'https://i.luish.cc/cover/cDdO3b.webp'
cover_author: 'Denny Ryanto'
cover_author_link: 'https://unsplash.com/@runninghead'
tags:
- laravel
- lnmpa
---

## 实验环境

- 阿里云 ECS 服务器： Ubuntu 14.04 LTS 64位
- 使用 lnmp.org 提供的 Linux+Nginx+Mysql+Apache+php 一键安装包，已安装 lnmpa
- 其他条件满足（Git 工具和 ssh 私钥、composer 工具、bower 工具）

## 部署步骤

### 将 php 命令添加到系统环境变量中

```bash
# 往 /etc/enviroment 文件中添加: 
/usr/local/php/bin

#（该路径为 php 命令所在目录，前面一定要包含冒号）。
```

### 修改 php.ini

```ini
# 将 proc_get_status,proc_open 从 disable_functions 中去掉。
disable_functions = proc_get_status,proc_open;

# 修改为
*disable_functions = proc_get_status,proc_open;
```

### 添加虚拟主机

```bash
sudo lnmp vhost add
# 自动生成以下两个文件：
# /usr/local/nginx/conf/vhost/域名.conf
# /usr/local/apache/conf/vhost/域名.conf
```

#### 修改 nginx 配置文件

```nginx
# /usr/local/nginx/conf/vhost/域名.conf
root laravel的根目录/public

# 比如使用 composer create-project laravel/laravel laravel 命令生成的 laravel 目录
```

#### 修改 apache 配置文件

```apacheconf
# /usr/local/apache/conf/vhost/域名.conf
open_basedir laravel 根目录
Document root laravel 根目录/public
Directory laravel 根目录/public
```

### 克隆代码到本地

```bash
git clone git@github.com/zhonger/zhonger.github.io
sudo ln -s zhonger.github.io laravel 根目录

# 给 storage 文件夹读写权限
chmod 777 -R storage

# 安装相关 php 依赖和前端依赖
composer install
bower install
```

&emsp;&emsp;就这样，laravel 就可以正常运行在 lnmpa 环境中了。

## 问题解决

### 问题一

> error "问题"
> 打开空白，使用浏览器控制台查看 network 为 `500错误`？

> info "解决方法"
> 检查是否使用 composer 安装好 php 函数依赖；  
> 检查 storage 文件夹是否有读写权限；  
> 检查 apache 的虚拟主机配置文件中的 open_basedir 和 Directory 目录是否正确。

### 问题二

> error "问题"
> `composer install` 命令执行返回 `proc_open()` 和 `proc_get_status()` 两个函数不能正常使用？

> info "解决方法"
> 修改 php.ini 中 `disable_functions()`。

### 问题三

> error "问题"
> 页面 css 和 js 资源不能正常引用？

> info "解决方法"
> 修改 nginx 的虚拟主机配置文件的 root 目录为 laravel 应用程序的根目录，而非 public 目录。
