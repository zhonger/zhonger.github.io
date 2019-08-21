---
layout: post
title: 'windows配置composer和laravel笔记'
subtitle: '在windows系统上配置composer，并应用于laravel框架开发过程中。'
date: 2015-11-11 12:12:12 +0800
categories: tech
cover: 'https://images.unsplash.com/photo-1557600280-9ceddf1a3cc3?w=1600&h=900'
tags: windows composer laravel
---

## 安装及配置composer

- 由于getcomposer.org的服务器在国外，国内访问网速有点慢，所以采用了[国内镜像](http://packagist.cn/)获得composer.phar包，将composer.phar所在文件夹位置添加至环境变量Path中

- 下载php至电脑上，并将php.exe所在文件夹位置添加至环境变量Path中

- 在composer.phar所在文件夹按住Shift键点击鼠标右键选择“在此处打开cmd命令”，输入     
```bash
echo @php "%~dp0composer.phar" %*>composer.bat
```

- 到这里，composer全局安装完成，在命令行中输入`composer -v`进行验证是否成功

- 输入下列命令配置composer包和依赖库国内下载镜像
```bash
composer config -g repositories.packagist composer https://packagist.phpcomposer.com
```
- composer配置已较为完善，试试看，访问速度还不错哟

## 安装laravel应用

[laravel中文官网文档](http://laravel-china.org/docs/5.0/installation)是提供了两种安装方法，一种是采用配置laravel安装工具（反正我是按照配的结果安装应用时返回错误的），另一种是采用composer命令的方式安装，个人觉得第二种方法靠谱点，毕竟我用第二种方法就成功地创建了laravel应用（虽然命令稍微长一点）
```bash
composer create-project laravel/laravel blog  –prefer-dist
```



## 解释
`composer create-project` 就是使用composer工具创建项目的意思，laravel/laravel就是指明模板是什么， blog是你要创建的应用的名称，后面那个就是命令的参数。