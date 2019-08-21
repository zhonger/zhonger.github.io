---
layout: post
title: laravel5.2在lnmpa一键安装包环境下的部署
date: 2016-03-14 22:19:48 +0800
tags:
- laravel
- lnmpa
categories: tech
cover: 'https://images.unsplash.com/photo-1516545595035-b494dd0161e4?w=1600&h=900'
---

# 实验环境

阿里云ECS服务器：`ubuntu14.04LTS 64位` \\
使用`lnmp.org`提供的`linux+nginx+mysql+apache+php`一键安装包，已安装lnmpa \\
其他条件满足（Git工具和ssh私钥、`composer`工具、`bower`工具）

# 部署步骤

将`php命令`添加到系统环境变量中： 
往`/etc/enviroment`文件中添加:`/usr/local/php/bin`（该路径为php命令所在目录，前面一定要包含冒号） 

修改`php.ini`：将`proc_get_status,proc_open`从`disable_functions`中去掉  

使用`sudo lnmp vhost add`命令添加虚拟主机，自动在`/usr/local/nginx/conf/vhost`和`/usr/local/apache/conf/vhost`生成`域名.conf`  

修改`nginx`中的`“域名.conf”`文件的`root目录`为`laravel的根目录/public`（比如使用`composer create-project laravel/laravel laravel`命令生成的laravel目录） 

修改`apache`中的“域名.conf”文件：open_basedir 后面的路径同上一步中的laravel的根目录，Document root和Directory后面的路径为“laravel根目录/public”，这是域名绑定的入口目录  

使用git工具将github或oschina.net的代码克隆至域名绑定`root目录`，使用`chmod 777 -R storage`命令给`storage文件夹读写权限`  
使用`composer install`和`bower install`命令安装相关php依赖和前端依赖 

就这样，laravel就可以正常运行在lnmpa环境中了

# 问题解决
> 问题一：打开空白，使用浏览器控制台查看network为`500错误`？

解决方法： \\
1.检查是否使用`composer`安装好`php函数依赖`； \\
2.检查`storage文件夹`是否有读写权限； \\
3.检查`apache`的虚拟主机配置文件中的`open_basedir`和`Directory目录`是否正确； 

> 问题二：`composer install`命令执行返回`proc_open()`和`proc_get_status()`两个函数不能正常使用？

解决办法：修改`php.ini`中`disable_functions()`
> 问题三：页面`css`和`js`资源不能正常引用？

解决办法：修改`nginx`的虚拟主机配置文件的root目录为laravel应用程序的根目录，而非public目录