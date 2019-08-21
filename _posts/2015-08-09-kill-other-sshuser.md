---
layout: post
title: 'Linux踢出其他正在SSH登陆用户'
subtitle: '踢出其他SSH登录用户'
date: 2015-08-09 15:32:12 +0800
categories: tech
cover: 'https://images.unsplash.com/photo-1428550590922-34c77f716ad4?w=1600&q=900'
tags: SSH登录 转载
---

在一些生产平台或者做安全审计的时候往往看到一大堆的用户SSH连接到同一台服务器，或者连接后没有正常关闭进程还驻留在系统内。限制SSH连接数与手动断开空闲连接也有必要之举，这里写出手动剔出其他用户的过程。

- 查看系统在线用户

```bash
[root@apache ~]# w 
14:15:41 up 42 days, 56 min,  2 users,  load average: 0.07, 0.02, 0.00 
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT 
root     pts/0    116.204.64.165   14:15    0.00s  0.06s  0.04s w 
root     pts/1    116.204.64.165   14:15    2.00s  0.02s  0.02s –bash
```

- 查看当前自己占用终端，别把自己干掉了

```bash
[root@apache ~]# who am i 
root     pts/0        2013-01-16 14:15 (116.204.64.165)
```

- 用pkill 命令剔除对方

```bash
[root@apache ~]# pkill -kill -t pts/1
```

- 用w命令在看看干掉没

```bash
[root@apache ~]# w 
14:19:47 up 42 days,  1:00,  1 user,  load average: 0.00, 0.00, 0.00 
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT 
root     pts/0    116.204.64.165   14:15    0.00s  0.03s  0.00s w
```

- 如果最后查看还是没有干掉，建议加上-9 强制杀死。

```bash
[root@apache ~]# pkill -9 -t pts/1
```


原文转自http://www.myhack58.com/Article/48/66/2013/37031.htm