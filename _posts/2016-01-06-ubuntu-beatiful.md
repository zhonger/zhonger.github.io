---
layout: post
title: 'Ubuntu 14.04 常用美化、配置、软件安装（持续更新中......）'
subtitle: '美化 ubuntu，你值得拥有。'
date: 2016-01-06 13:11:23 +0800
categories: tech
cover: 'https://images.unsplash.com/photo-1566055212219-ebd214dc9bdc?w=1600&h=900'
tags: ubuntu 美化
---

# 安装扁平化主题

1. 安装ubuntu-tweak
```bash
sudo add-apt-repository ppa:tualatrix/ppa
sudo apt-get update
sudo apt-get install ubuntu-tweak
```
2. 下载主题包文件
```bash
wget –no-check-certificate https://github.com/anmoljagetia/Flatabulous/archive/master.zip
```
下载好后解压到用户根目录的.themes文件夹（没有请使用`mkdir .themes`命令新建文件夹）
3. 安装图标
```bash
sudo add-apt-repository ppa:noobslab/icons
sudo apt-get update
sudo apt-get install ultra-flat-icons
```
也可`sudo apt-get install ultra-flat-icons-orange`或者`sudo apt-get install ultra-flat-icons-green`来安装其他两种颜色
4. 使用ubuntu-tweak图形化界面更改主题及图标即可
（该部分参考自 [http://www.jianshu.com/p/5b80711f304f](http://www.jianshu.com/p/5b80711f304f)）

# 安装shadowsocks

&emsp;&emsp;百度一下`ubuntu shadowsocks`的结果很凄惨，根本没有什么有用的，不过google还是挺厉害的，安装`shadowsocks-qt5`即可。

```bash
sudo add-apt-repository ppa:hzwhuang/ss-qt5
sudo apt-get update
sudo apt-get install shadowsocks-qt5
```

（该部分参考自 [https://aitanlu.com/ubuntu-shadowsocks-ke-hu-duan-pei-zhi.html](https://aitanlu.com/ubuntu-shadowsocks-ke-hu-duan-pei-zhi.html)）

# 安装常用工具

1. rinetd端口转发工具
```bash
sudo apt-get install rinetd    (配置文件为/etc/rinetd.conf)
```