---
layout: post
title: 'DMOJ 判题环境配置集锦'
subtitle: '边搭边理解 OJ 是如何写成的'
date: 2020-08-04 16:06:45 +0800
categories: [tech, Linux]
author: zhonger
cover: 'https://i.lisz.top/cover/iRkEOx.webp'
cover_author: 'Gontran Isnard'
cover_author_link: 'https://unsplash.com/@gontranid'
tags: 
- DMOJ
- 判题系统
- Ubuntu
---

&emsp;&emsp;由于 DMOJ 支持多达 63 种编程语言环境，每一种环境都需要特别安装。如下为笔者尝试过的一些编程语言环境配置。

```bash
-----------------------------------------------------
语言：Python2
安装命令： sudo apt install -y python2 python2-pip
编译命令： python2
-----------------------------------------------------
语言：Python3
安装命令： sudo apt install -y python3 python3-pip
编译命令：
-----------------------------------------------------
语言：JavaScript
安装命令： wget -c https://apt.dmoj.ca/pool/main/v/v8dmoj/v8dmoj_8.1.307.31_amd64.deb 
         sudo dpkg -i v8dmoj_8.1.307.31_amd64.deb
编译命令：
-----------------------------------------------------
语言：php
安装命令： sudo apt install -y php7.2
编译命令：
-----------------------------------------------------
语言：Java8
安装命令： sudo apt install -y openjdk-8-jdk
编译命令：
-----------------------------------------------------
语言：Java11
安装命令： sudo apt install -y openjdk-11-jdk
编译命令：
-----------------------------------------------------
语言：C
安装命令： sudo apt install -y gcc
编译命令：
-----------------------------------------------------
语言：Clang/Clang++
安装命令： sudo apt install -y clang
编译命令：
-----------------------------------------------------
语言：C++11/C++14
安装命令： sudo apt install -y g++
编译命令：
-----------------------------------------------------
语言：C++17
安装命令： sudo apt install -y g++-7
编译命令：
-----------------------------------------------------
语言：awk
安装命令： 系统默认自带
编译命令：
-----------------------------------------------------
语言：cat
安装命令： 系统默认自带
编译命令：
-----------------------------------------------------
语言：perl
安装命令： 系统默认自带
编译命令：
-----------------------------------------------------
语言：sed
安装命令： 系统默认自带
编译命令：
-----------------------------------------------------
语言：Assembly(x64)
安装命令：
编译命令：
-----------------------------------------------------
语言：Assembly(x86)
安装命令：
编译命令：
-----------------------------------------------------
语言：Pascal
安装命令：
编译命令：
-----------------------------------------------------
语言：ruby
安装命令：wget -c https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.1.tar.gz
        tar zxvf ruby-2.7.1.tar.gz && cd ruby-2.7.1 && ./configure
        make -j8 && sudo make install
        或者
        sudo apt install -y ruby
编译命令：
-----------------------------------------------------
语言：rust
安装命令：
编译命令：
-----------------------------------------------------
语言：go
安装命令：
编译命令：
-----------------------------------------------------
语言：scala
安装命令：
编译命令：
-----------------------------------------------------
语言：dart
安装命令：
编译命令：
-----------------------------------------------------
语言：coffee
安装命令：sudo npm install -g coffeescript
编译命令：
-----------------------------------------------------
语言：lua
安装命令：sudo apt install -y lua5.3
编译命令：
-----------------------------------------------------
语言：nasm
安装命令：wget -c https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz
        tar zxvf nasm-2.15.05.tar.gz && cd nasm-2.15.05 && ./configure
        make -j8 && sudo make install
编译命令：
-----------------------------------------------------
语言：swift
安装命令：
编译命令：
-----------------------------------------------------
语言：kotlin
安装命令：
编译命令：
-----------------------------------------------------
语言：zig
安装命令： sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
         echo 'deb https://dl.bintray.com/dryzig/zig-ubuntu bionic main' | sudo tee -a /etc/apt/sources.list.d/zig.list 
         sudo apt update && sudo apt install zig -y
         或者
         wget -c https://github.com/dryzig/zig-debian/releases/download/0.6.0-1/zig_0.6.0-1_amd64.deb && sudo dpkg -i zig_0.6.0-1_amd64.deb
编译命令： 
-----------------------------------------------------
```
