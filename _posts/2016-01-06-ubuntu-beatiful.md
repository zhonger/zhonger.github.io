---
layout: post
title: 'Ubuntu 14.04 常用美化、配置、软件安装（持续更新中......）'
subtitle: '美化 Ubuntu 你值得拥有'
date: 2016-01-06 13:11:23 +0800
categories: [tech, Linux]
author: zhonger
cover: 'https://unsplash.lisz.tk/1566055212219-ebd214dc9bdc.webp'
cover_author: 'Alexander Tsang'
cover_author_link: 'https://unsplash.com/@alexander_tsang'
tags: 
- ubuntu 
- 美化
---

## 安装扁平化主题

### 安装 ubuntu-tweak

```bash
sudo add-apt-repository ppa:tualatrix/ppa
sudo apt-get update
sudo apt-get install ubuntu-tweak
```

### 下载主题包文件

```bash
wget –no-check-certificate https://github.com/anmoljagetia/Flatabulous/archive/master.zip
```

&emsp;&emsp;下载好后解压到用户根目录的 `.themes` 文件夹（没有请使用 `mkdir .themes` 命令新建文件夹）。

### 安装图标

```bash
sudo add-apt-repository ppa:noobslab/icons
sudo apt-get update
sudo apt-get install ultra-flat-icons
```

&emsp;&emsp;也可 `sudo apt-get install ultra-flat-icons-orange` 或者 `sudo apt-get install ultra-flat-icons-green` 来安装其他两种颜色。

### 应用主题及图标

&emsp;&emsp;使用 ubuntu-tweak 图形化界面更改主题及图标即可。

## 安装 Shadowsocks

&emsp;&emsp;百度一下 `ubuntu shadowsocks` 的结果很凄惨，根本没有什么有用的，不过 Google 还是挺厉害的，安装 `shadowsocks-qt5` 即可。

```bash
sudo add-apt-repository ppa:hzwhuang/ss-qt5
sudo apt-get update
sudo apt-get install shadowsocks-qt5
```

## 安装常用工具

### Rinetd 端口转发工具

```bash
sudo apt-get install rinetd    (配置文件为/etc/rinetd.conf)
```

## 参考资料

- [(译)Ubuntu下一款极好的扁平化主题](https://www.jianshu.com/p/5b80711f304f)
- [https://aitanlu.com/ubuntu-shadowsocks-ke-hu-duan-pei-zhi.html](https://aitanlu.com/ubuntu-shadowsocks-ke-hu-duan-pei-zhi.html)
