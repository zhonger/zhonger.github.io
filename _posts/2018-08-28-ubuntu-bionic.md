---
layout: post
title: Ubuntu 18.04 主题美化指“北”
subtitle: 为 Ubuntu 18.04 定制属于你的 Mac 主题
date: 2018-08-28 16:18:00 +0800
tags:
- Ubuntu
- Bionic
- 主题
- Mac
- 18.04
categories: tech
cover: 'https://images.unsplash.com/photo-1560568082-c15188aa6510?w=1600&h=900'
---

&emsp;&emsp;Ubuntu 操作系统一直深受广大开发者喜爱，一个原因在于它的软件支持比较新，另一个原因在于它的交互更为友好、便于定制化。今天，在尝试从 16.04 升级到 18.04 之后，觉得可能需要换个主题，换个好心情（16.04 一直用的是 Flat 主题，一款非常好看的主题哦）。由于 Ubuntu 18.04 采用了 GNOME 替代 Unity（GTK 基础上由 Canonical 自主开发的，因为维护耗费精力而被砍掉） 作为默认图形桌面环境，原来的 Flat 主题也失效了，不过好在有万能的 opendesktop.org ，有很多开源界的设计师们纷纷向这个站点贡献自己的 GNOME 桌面定制化设计，在这个地方基本可以找到想要的主题，比如像类 MacOS 、 Windows 、Arch 等操作系统样子的高仿主题。个人比较偏爱 MacOS 风格的主题，因此下面就拿自己使用的一系列主题举例。

## 准备操作

&emsp;&emsp;在正式美化主题之前，需要分别安装由 opendesktop.org 和 gnome.org 提供的插件工具。

### 安装 Tweak 面板

```bash
sudo apt update && sudo apt install -y gnome-tweak-tool gnome-shell-extensions
# gnome-shell-extensions 为辅助工具
```

### 安装 ocs-url-tools 工具

&emsp;&emsp;访问 [https://www.opendesktop.org/c/1467909105](https://www.opendesktop.org/c/1467909105) 下载 [ocs-url-tools 安装包](https://www.opendesktop.org/p/1136805/startdownload?file_id=1530774600&file_name=ocs-url_3.1.0-0ubuntu1_amd64.deb&file_type=application/x-debian-package&file_size=54502&url=https%3A%2F%2Fdl.opendesktop.org%2Fapi%2Ffiles%2Fdownload%2Fid%2F1530774600%2Fs%2Fa800fbc3c14076df82c47eca7016a8e6%2Ft%2F1535448752%2Fu%2F%2Focs-url_3.1.0-0ubuntu1_amd64.deb)。

```bash
cd ~/Downloads && sudo dpkg -i ocs-url_3.1.0-0ubuntu1_amd64.deb
```

### 安装 Tweak 插件

&emsp;&emsp;访问 [https://extensions.gnome.org/](https://extensions.gnome.org/) 开启插件 Dash to Dock 、 Hide Top Bar 、 User Themes.

## 美化定制

### 下载系统主题和 SHELL 主题

&emsp;&emsp;访问 [https://www.opendesktop.org/s/Gnome/p/1013714/](https://www.opendesktop.org/s/Gnome/p/1013714/) ，点击 Install 按钮下拉出所有选项，前八个选项是主题，后四个分别是图标主题、背景图片、鼠标主题、字体主题。点击选项将请求交给 ocs-url-tools 处理（它收到同意操作之后会将压缩包下载并解压到对应的文件夹中）。

![选择主题](https://vgy.me/76db8C.jpg)

> 注：SHELL 主题是指顶部任务栏的风格，由于顶部为白色的话有些图标不容易看清，所以此处主题选用白色（不带透明）、SHELL 主题选用黑色（不带透明）。

### 下载图标

&emsp;&emsp;访问 [https://www.opendesktop.org/s/Gnome/p/1102582/](https://www.opendesktop.org/s/Gnome/p/1102582/)，如下图一样操作，选择 macOS11.tar.xz 即可。

![选择图标](https://vgy.me/u5fKSh.jpg)

### 更换系统搭配

&emsp;&emsp;可以按照以下配置调整系统主题、系统图标和 SHELL 主题。
![Theme](https://vgy.me/NsNL1c.jpg)

&emsp;&emsp;可以按照以下配置调整桌面设置。
![Desktop](https://vgy.me/nBkTtB.jpg)

&emsp;&emsp;可以按照以下配置 Dock 为顶部类 Mac 操作系统显示方式，点击 Dash to docker 一行的设置图标进入设置详细内容。

![Dock](https://vgy.me/KJ0tez.jpg)


## 大功告成的结果

![screenshot](https://vgy.me/AORYMC.jpg)

## 参考资料

- [给 Ubuntu18.04(18.10) 安装 mac os 主题](https://www.cnblogs.com/feipeng8848/p/8970556.html)
- [安装 Ubuntu-18-04-LTS 之后的 N 件事](https://tankeryang.github.io/posts/%E5%AE%89%E8%A3%85Ubuntu-18-04-LTS%E4%B9%8B%E5%90%8E%E7%9A%84N%E4%BB%B6%E4%BA%8B/)