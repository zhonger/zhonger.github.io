---
layout: post
title: 'Ubuntu-14.04-LTS 安装配置 NodeJS+Bower'
subtitle: '在 Ubuntu 系统上安装 NodeJS 和 Bower 工具。'
date: 2015-11-11 22:20:20 +0800
categories: [tech, Nodejs]
cover: 'https://images.unsplash.com/photo-1565984556409-b0d4946ce2d4?w=1600&h=900'
tags: 
- ubuntu 
- nodejs 
- bower
---

> 强烈推荐方案二

## 方案一

安装准备：`Pyhton`、`make`、`gcc`、`g++` 均已安装

### 增加源

&emsp;&emsp;将 NodeJS 的 PPA 源加入系统。

```bash
sudo  add-apt-repository ppa:chris-lea/node.js
```

### 安装 NodeJS

&emsp;&emsp;更新系统软件源缓存并安装 NodeJS。

```bash
sudo apt-get update
sudo apt-get install nodejs
```

### 安装 Bower

&emsp;&emsp;使用 `npm` 命令全局安装 `bower` 命令。

```bash
sudo npm install bower -g
```

&emsp;&emsp;到此 `NodeJS` 和 `bower` 工具安装完成，接下来请享受 `bower` 工具带来的舒适吧！

## 方案二

&emsp;&emsp;由于国内直接访问软件源的网速不是很好，而且 `APT 源` 的 `NodeJS` 版本也不是很好，所以建议采用方案二（使用 NPM 淘宝镜像来实现）。

### 下载源码

&emsp;&emsp;在 [https://npm.taobao.org/mirrors/node](https://npm.taobao.org/mirrors/node) 中找到你想要的 nodejs 版本，建议采用 `v4.4.3LTS版本` 或者 `Latest版本`。

```bash
wget –no-check-certifica https://npm.taobao.org/mirrors/node/v4.4.3/node-v4.4.3-linux-x64.tar.gz
```

> info "小提示"
> 因为实验时主机为 `Ubuntu 14.04 LTS 64位` 操作系统，所以选择 `linux x64` 版本。

### 解压

&emsp;&emsp;在用户根目录创建 node 文件夹，将下载的压缩包内容解压到该文件夹。

```bash
tar zxf node-v4.4.3-linux-x64.tar.gz ~/node/
```

### 配置环境变量

&emsp;&emsp;将 `node` 和 `npm` 命令加入用户环境变量。

```bash
# 在 .bashrc 文件的末尾加入

tee -a ~/.bashrc << EOF
PATH=$PATH:~/node/bin
EOF
source ~/.bashrc

# 验证 Node 是否安装成功
node -v
```

> info "小提示"
> &emsp;&emsp;这样的命令就是只能单用户使用，如果需要多用户使用，请  `node` 文件夹设置在系统公用目录，然后将 `bin` 目录赋给权限 `755`。

### 安装 cnpm

```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

&emsp;&emsp;到此为止，`cnpm` 命令就可以完全替代 `npm` 进行使用，并且安装模块的速度杠杠的哦（毕竟是淘宝镜像源啊～）

### 安装 bower

```bash
cnpm install -g bower
```
