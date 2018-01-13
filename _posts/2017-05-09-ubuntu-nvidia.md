---
layout: post
title: ubuntu16.04下安装nvidia gtx 970显卡驱动
date: 2017-05-09 12:02:49
tags:
- ubuntu
- nvidia
categories: tech
cover: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1680&q=80'
---
# 实验环境
- Ubuntu 16.04 Desktop (内核版本：4.8.0-46-generic)
- 显卡：GTX-960

# 准备工作
## 下载NVIDIA驱动程序
- 在[nvidia官网下载](http://www.nvidia.cn/Download/index.aspx?lang=cn)对应的驱动（`.run`文件）
## 删除旧驱动
- `sudo apt-get purge nvidia*`（如果返回卸载成功或无匹配结果均可）
## 禁用自带的nouveau nvidia驱动
- 通过命令`sudo vim /etc/modprobe.d/blacklist-nouveau.conf`创建文件，并添加内容如下：
```
blacklist nouveau
options nouveau modeset=0
```
- 执行更新命令`sudo update-initramfs -u`，并重启操作系统（重启后可用`lsmod | grep nouveau`检查是否禁用成功）
## 安装内核头
- 通过命令安装
```shell
sudo apt-get install linux-headers-$(uname -r)
```

# 正式安装过程
- 通过命令`sudo service lightdm stop`关闭`x-window`
- 执行NVIDIA驱动安装程序`sudo sh NVIDIA.run`（`.run`文件需提前赋予执行权限）
- 一步一步选择下去执行安装即可，最终显示安装成功
- 通过命令`sudo service lightdm start`开启`x-window`

# 完成显卡驱动安装