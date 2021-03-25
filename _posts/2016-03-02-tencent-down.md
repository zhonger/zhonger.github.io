---
layout: post
title: 腾讯云服务器重装系统后……
subtitle: 重装系统
date: 2016-03-02 16:36:27 +0800
tags:
- 腾讯云
categories: [tech, Linux]
cover: 'https://images.unsplash.com/photo-1455459182396-ae46100617cb?w=1600&h=900'
---
## 添加用户并设为 sudo 权限

```bash
sudo useradd 用户名
sudo passwd 用户名
sudo chmod +w /etc/sudoers
sudo vi  /etc/sudoers (加入 用户名 ALL=(ALL:ALL) ALL )
```

## 更改用户 linux 的 shell 的操作方法

```bash
查看当前用户的 shell 方式 `echo $SHELL`    
输出 `/bin/sh`
更换 shell 操作方式为`/bin/bash`   
`sudo vi /etc/passwd`  在用户行尾加上`/bin/bash`
退出系统再次登录
```