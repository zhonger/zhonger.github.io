---
layout: post
title: 腾讯云服务器重装系统后……
subtitle: 重装系统
date: 2016-03-02 16:36:27 +0800
categories: [tech, Linux]
author: zhonger
cover: 'https://i.lisz.top/cover/r41lbG.webp'
cover_author: 'Adi Constantin'
cover_author_link: 'https://unsplash.com/@idoevolve'
tags:
- 腾讯云
---
## 添加新用户及赋权

### 新增用户及配置默认密码

```bash
sudo useradd 用户名
sudo passwd 用户名
```

### 添加用户到 sudo 组

```bash
sudo chmod +w /etc/sudoers
sudo vi  /etc/sudoers 
# 加入 用户名 ALL=(ALL:ALL) ALL
```

## 配置默认 Shell

&emsp;&emsp;更改Linux 用户的 Shell 的操作方法如下所示：

```bash
# 查看当前用户的 shell 方式 
echo $SHELL    
>> /bin/sh

# 更换 shell 操作方式为 `/bin/bash`   
sudo vim /etc/passwd  
# 在用户行尾加上`/bin/bash`

# 退出系统再次登录
```
