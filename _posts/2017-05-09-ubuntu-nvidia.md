---
layout: post
title: Ubuntu 16.04 下安装 NVIDIA GTX 970 显卡驱动
subtitle: Linux 的 NVIDIA 驱动安装
date: 2017-05-09 12:02:49 +0800
tags:
- ubuntu
- nvidia
categories: [tech, Linux]
cover: 'https://images.unsplash.com/photo-1474835409173-5dc81aae3faa?w=1600&h=900'
---
## 实验环境

- Ubuntu 16.04 Desktop (内核版本：4.8.0-46-generic)
- 显卡：GTX-960

## 准备工作

1. 下载 NVIDIA 驱动程序
在[NVIDIA官网下载](http://www.nvidia.cn/Download/index.aspx?lang=cn)对应的驱动（.run 文件）
2. 删除旧驱动
```bash
sudo apt-get purge nvidia*
#（如果返回卸载成功或无匹配结果均可）
```
3. 禁用自带的 nouveau nvidia 驱动
```bash
sudo vim /etc/modprobe.d/blacklist-nouveau.conf
# 创建文件，并添加内容如下：
blacklist nouveau
options nouveau modeset=0
# 执行更新命令
sudo update-initramfs -u
# 重启操作系统
#（重启后可用`lsmod | grep nouveau`检查是否禁用成功）
```
4. 安装内核头
```bash
sudo apt-get install linux-headers-$(uname -r)
```

## 正式安装

```bash
# 关闭 x-window
sudo service lightdm stop
# 执行 NVIDIA 驱动安装程序（.run 文件需提前赋予执行权限）
sudo sh NVIDIA.run
# 一步一步选择下去执行安装即可，最终显示安装成功
# 开启 x-window
sudo service lightdm start
```

## 验证是否成功

```bash
# 打印显卡信息
sudo nvidia-smi
```