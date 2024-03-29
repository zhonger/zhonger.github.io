---
layout: post
title: 'Archlinux 入门初步'
subtitle: 'Archlinux 从安装操作系统入手'
date: 2017-07-19 15:23:10 +0800
categories: [tech, Linux]
author: zhonger
cover: 'https://i.lisz.top/cover/zahv58.webp'
cover_author: 'Tianshu Liu'
cover_author_link: 'https://unsplash.com/@tianshu'
tags: 
- archlinux 
- setup
---

## 制作 archlinux 启动盘

&emsp;&emsp;从 archlinux 官方或者是镜像源下载到 iso 文件，并使用以下命令制作启动U盘。

```bash
dd if=image.iso of=/dev/sd[x]
```

## 安装准备

电脑插入启动 U盘，并选择从 U盘 的 **uefi** 模式启动

```bash
# 键盘布局:
loadkeys us

# 验证启动模式: 
ls /sys/firmware/efi/efivars
# 如果目录不存在，系统即为 BIOS 或 CSM 模式启动

# 联网:
ping -c 3 www.baidu.com

# 若发现网络不通，则使用以下命令停用dhcpcd进程
systemctl stop dhcpcd

# 更新系统时间: 
timedatectl set-ntp true
#用`timedatectl status`检查服务状态

# 建立硬盘分区:
# 比如磁盘为 /dev/sda，则使用以下命令对磁盘进行操作；
fdisk /dev/sda
# 首先使用 g 转换成 gpt 分区格式；
# 其次使用 n 分别建立 512MB 的EFI分区和剩余硬盘大小的根目录分区

# 挂载分区: 
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

## 安装

```bash
# 选择镜像地址: 编辑 /etc/pacman.d/mirrorlist ，建议使用以下首选 mirror
Server = https://mirrors.shuosc.org/archlinux/$repo/os/$arch
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
# 安装基本系统及AUR: 
pacstrap /mnt base base-devel`
```

## 配置系统

```bash
# Fstab: 
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot: Change root到新的安装系统
arch-chroot /mnt

# 时区: 使用以下命令设置时区及时间标准为 UTC
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# Locale: 修改 /etc/locale.gen 文件，将所需语言前的注释删除，比如以下几个，再使用 locale-gen 生成locale配置文件，并提交默认语言

en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_SG.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8

locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# 主机名: 使用 echo arch > /etc/hostname 设置主机名，并添加对应信息至 /etc/hosts，如下所示：
127.0.1.1        arch.localdomain  arch

# 网络配置: 让 DHCP 服务开机自启动
systemctl enable dhcpcd.service 
# 设置用户: 首先新增用户

useradd username
passwd username
mkdir /home/username
chown -R username:username /home/username
# 然后往 /etc/sudoers 添加
username ALL=(ALL) NOPASSWD:ALL

# 安装引导程序: 
pacman -S grub os-prober efibootmgr dosfstools
grub-install --target-x86_64-efi --efi-directory=/boot --bootloader-id=grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

## 其他配置

```bash
# 配置显卡: 
pacman -S nvidia

# 删除`/etc/pacman.conf`中的`multilib`部分注释，
pacman -Syy

# 刷新软件缓存
pacman -S lib32-nvidia-utils

# 安装对应的基本库。
```

```bash
# 安装 xorg
pacman -S xorg
nvidia-xconfig

# 安装 gnome: 
pacman -S gnome gnome-extra
pacman -S gnome gdm
systemctl enable gdm
```

## 重启

&emsp;&emsp;重启之后从硬盘启动就会进入 gdm 登录界面，使用上面设置的 username 和密码登录即可，如果用户名和密码都正确无法登录，说明该用户未建立对应用户主目录，重新创建用户即可。

## 参考资料

- [Install_from_a_USB_flash_drive](https://wiki.archlinux.org/index.php/USB_flash_installation_media)
- [NVIDIA](https://wiki.archlinux.org/index.php/NVIDIA)
