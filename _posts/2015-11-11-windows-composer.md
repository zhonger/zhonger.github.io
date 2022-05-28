---
layout: post
title: 'Windows 配置 Composer 和 Laravel 笔记'
subtitle: '在 Windows 系统上配置 Composer，并应用于 Laravel 框架开发过程中。'
date: 2015-11-11 12:12:12 +0800
categories: [tech, PHP]
author: zhonger
cover: 'https://i.luish.cc/cover/ajok5a.webp'
cover_author: 'Jeremy Weber'
cover_author_link: 'https://unsplash.com/@doubleweber'
tags: 
- windows 
- composer 
- laravel
---

## 安装及配置 composer

&emsp;&emsp;由于 getcomposer.org 的服务器在国外，国内访问网速有点慢，所以采用了[国内镜像](http://packagist.cn/)获得 composer.phar 包，将 composer.phar 所在文件夹位置添加至环境变量 Path 中。下载 php 至电脑上，并将 php.exe 所在文件夹位置添加至环境变量 Path 中。在 composer.phar 所在文件夹按住 Shift 键点击鼠标右键选择“在此处打开 cmd 命令”，输入     
```bash
echo @php "%~dp0composer.phar" %*>composer.bat
```
&emsp;&emsp;到这里，composer 全局安装完成，在命令行中输入`composer -v`进行验证是否成功。输入下列命令配置 composer 包和依赖库国内下载镜像
```bash
composer config -g repositories.packagist composer https://packagist.phpcomposer.com
```
&emsp;&emsp;composer 配置已较为完善，试试看，访问速度还不错哟。

## 安装 laravel 应用

&emsp;&emsp;[laravel 中文官网文档](http://laravel-china.org/docs/5.0/installation) 提供了两种安装方法，一种是采用配置 laravel 安装工具（反正我是按照配的结果安装应用时返回错误的），另一种是采用 composer 命令的方式安装，个人觉得第二种方法靠谱点，毕竟我用第二种方法就成功地创建了 laravel 应用（虽然命令稍微长一点）。
```bash
composer create-project laravel/laravel blog  –prefer-dist
```
## 解释
&emsp;&emsp;`composer create-project` 就是使用 composer 工具创建项目的意思，laravel/laravel 就是指明模板是什么， blog 是你要创建的应用的名称，后面那个就是命令的参数。