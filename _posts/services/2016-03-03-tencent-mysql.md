---
layout: post
title: MySQL 遇到远程无法连接的解决办法
subtitle: 腾讯云服务器 CVM 安装 MySQL 的配置
date: 2016-03-03 22:04:40 +0800
categories: [tech, SQL]
author: zhonger
cover: 'https://i.lisz.top/cover/ovn2ST.webp'
cover_author: '郑 无忌'
cover_author_link: 'https://unsplash.com/@godslar'
tags: 
- 腾讯云
- MySQL
---
## 修改mysql配置

&emsp;&emsp;首先需要确认安装的 MySQL 服务器的配置文件 /etc/mysql/my.cnf 是否将 `bindless 120.0.0.1:0` 注释掉，务必保证已注释。

## 配置腾讯云服务器

### 更新腾讯云服务器的安全组策略

1. 在云服务器列表中选择安全组
2. 在安全组中新建一个安全组，名称任意
3. 添加入站规则和出站规则
4. 将云服务器主机添加入新建的安全组，并从其他安全组中退出。

> note "笔记"
> **入站规则**是指外网可以访问服务器的端口，即服务器对外开放资源获取的端口；  
> **出站规则**是指服务器访问网络上的策略，一般是全部开放。除非有特殊限制要求，本问题的解决不考虑，所以设为 ALL TRAFFIC。

&emsp;&emsp;在腾讯云服务操作面板中重启服务器使安全组生效。

## 验证测试

&emsp;&emsp;在客户端系统中使用 Navicat 等软件连接 MYSQL 数据库，正常连接。就这样，一台 MYSQL 数据库服务器就搭建完毕了。
