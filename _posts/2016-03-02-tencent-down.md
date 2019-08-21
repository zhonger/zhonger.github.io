---
layout: post
title: 腾讯云服务器重装系统后……
date: 2016-03-02 16:36:27 +0800
tags:
- 腾讯云
categories: tech
cover: 'https://images.unsplash.com/photo-1455459182396-ae46100617cb?w=1600&h=900'
---
# 一、添加用户并设为sudo权限
`sudo useradd 用户名`
`sudo passwd 用户名`
`sudo chmod +w /etc/sudoers`
`sudo vi  /etc/sudoers (加入 用户名 ALL=(ALL:ALL) ALL )`

# 二、更改用户linux的shell的操作方法
查看当前用户的shell方式 `echo $SHELL`    输出 `/bin/sh`
更换shell操作方式为`/bin/bash`   `sudo vi /etc/passwd`  在用户行尾加上`/bin/bash`
退出系统再次登录