---
layout: post
title: '[原创]远程服务环境与本地环境互联'
subtitle: '如何曲线实现异地组网？'
date: 2021-06-15 13:30:00 +0800
tags: 
- 多地
- 组网
- 互联
- Zerotier
categories: [tech, webmaster]
cover: 'https://images.unsplash.com/photo-1623626981328-fae05b4bc2a0?w=1600&q=900'
---

## 前言

### 异地组网

&emsp;&emsp;谈到“异地组网”这个问题，其实已经有很多成熟的解决方案，包括最简单的拉光纤物理相连、向日葵异地组网等等。这些解决方案虽然稳定性和使用体验都极度让人舒适，但是实现的代价略微有点大，尤其财大气粗的光纤物理直接相连。不过对于某些大公司的异地数据中心互联，这仍然是最被认可的解决方案。至于向日葵异地组网，有点类似于把远程服务环境和本地环境同时连入一个网络，然后在形式上实现局域网化。由于这一解决方案往往依赖于一个由第三方提供的中心节点服务，这种局域网的带宽、速度和使用体验很大程度上受限于购买的套餐级别。那么，是否存在一种造价较低，速度和使用体验都较佳的解决方案呢？答案自然是存在的，只是有点**曲线**而已。

### Zerotier 组网

&emsp;&emsp;在之前的一些文章中，我们已经体验了 Zerotier 带来的软件定义网络。这种软件定义网络方式，在某种程度上会受限于 Zerotier 的 Planet 节点发现路由的效果。如果两个客户端节点到 Planet 节点的路由来自于两条不同的线路，比如一个节点位于移动局域网网络，一个节点位于联通局域网网络，Planet 节点在规划路由的时候会认为两个客户端节点直接无法找到最短的路由，需要通过 Planet 节点来进行转发流量，甚至被认为完全没有可能互通。而实际上，在国内的运营商网络中，移动网络和联通网络之间是存在交换节点的，即可能存在一条最短路由。这种情况下，Zerotier 官方建议自己使用一台国内的公网服务器提供 Moon 服务，从而为 Zerotier 的路由规划提供辅助。从理论上来说，两个客户端节点在 Moon 的帮助下很大可能找到国内网络中的最短路由，并直接建立 UDP 通道。但在实际过程中，客户端节点之间的最短路由可能仍然十分长，且不足以直接建立 UDP 通道，毕竟它们位于两个底层的局域网中。

&emsp;&emsp;那么这样就完全不能让两个客户端节点直接互联吗？实际上还是有方法的。

&emsp;&emsp;**第一种方法**是，将公网服务器与远程服务环境的节点使用 Zerotier 组网互通，通过 SSH 自身提供的代理功能、将本来要发给远程服务环境的节点的 ssh 连接请求发往公网服务器进行转发。因为全程采用了 SSH 无密码登录（密钥登录），所以除非你的私钥被别人窃取否则理论上是绝对安全的，这也是国际上采用的通用安全做法。

&emsp;&emsp;**第二种方法**是，将公网服务器分别与远程服务环境的节点、本地环境的节点使用 Zerotier 组网互通，并设置公网服务器允许转发来自 Zerotier 网卡的流量请求，然后在本地环境的节点上设置将所有发往远程服务环境的节点的网络请求经由公网服务器进行转发。因为这种方法是把公网服务器作为一个软件式的路由器，在网络上实现了本地环境与远程服务环境的完全互联，所以对于本地环境而言，远程服务环境中的任意节点的任意端口是完全可达的。这也存在某种安全上的隐患，一般来说只建议网络或服务管理用户使用这样的方式，对于普通用户来说第一种方法已经完全够用，且安全性较高。

![vgy.me](https://i.vgy.me/BCnz9e.png)

## 实现

### 公网服务器的选择

&emsp;&emsp;无论是第一种方法还是第二种方法，都需要有一台公网服务器使用 Zerotier 与远程服务节点互通，因此第一步是需要拥有一台公网服务器。

#### 地理位置

&emsp;&emsp;如果远程服务节点和本地客户端节点都在国内，那自然是国内的公网服务器最好。如果远程服务节点位于国内、本地客户端节点位于国外，也是使用国内的公网服务器最佳。因为无论哪种方式，公网服务器与远程服务节点直接都是使用 Zerotier 连接的。当然如果远程服务节点和本地客户端节点都在国外，自然使用国外的公网服务器最佳。

#### 服务商

&emsp;&emsp;根据笔者使用过的经验来看，按照推荐先后优先顺序，国内的 VPS 公网服务商推荐阿里云（国内国外路由较短）、腾讯云、Ucloud、华为云、百度云等等，国外的 VPS 公网服务商推荐 AWS（国内国外路由较短）、Azure、Linode、Digital Ocean、Vultr、GCP 等等。

### 第一种方法

#### 提前准备

- 本地客户端节点生成一对公钥和私钥
- 公网服务器和远程服务节点都已安装 Zerotier

&emsp;&emsp;如何生成一对公钥和私钥以及安装 Zerotier此处不做赘述。

#### 规划网络

&emsp;&emsp;假设现在规划的 Zerotier 网段为 172.18.0.0/24，远程服务节点所在局域网网络为 192.168.1.0/24，：
- 公网服务器实际 IP：1.1.1.1
- 远程服务节点实际 IP：192.168.1.200
- 公网服务器 Zerotier 规划 IP：172.18.0.10
- 远程服务节点 Zerotier 规划 IP：172.18.0.200


#### 配置 Zerotier

&emsp;&emsp;登录 [Zerotier Web 控制面板](https://my.zerotier.com)，并将公网服务器和远程服务节点的 zerotier id 加入到同一个 Zerotier 网络中。在 Web 控制面板中设置上面对应的 IP。

&emsp;&emsp;以下为在公网服务器或远程服务节点上的操作：

```bash
# 查询公网服务器或远程服务节点的 zerotier id
sudo zerotier-cli info

# 加入到同一个 Zerotier 网络中
sudo zerotier-cli join <Zerotier Network Id>

# 查询网络状态
sudo zerotier-cli listnetworks
```

#### 验证组网结果

&emsp;&emsp;如下所示可以分别在远程服务节点和公网服务器上验证是否可以互通。一般来说，从远程服务节点上 PING 公网服务器可能较容易 PING 通。如果两边都不通，可以使用直接 PING 公网服务器的公网 IP 来帮助 Zerotier 更快找到最短路由。

```bash
# 在远程服务节点上 PING 公网服务器
ping -c 10 172.18.0.10

# 在公网服务器上 PING 远程服务节点
ping -c 10 172.18.0.200

# 在远程服务节点上 PING 公网服务器的公网 IP
ping -c 1.1.1.1
```

#### 配置路由转发

&emsp;&emsp;经过以上步骤就可以实现公网服务器与远程服务节点之间的互通，但是在远程服务环境中往往存在多个节点，如果每个节点都这么做那将非常冗余。因此，需要借助已经配置好 Zerotier 的远程服务节点来转发所有的请求到远程服务环境的其他节点。

##### 远程服务节点

```bash
# 启动转发功能，编辑 /etc/sysctl.conf 文件
sudo vim /etc/sysctl.conf

# 在 /etc/sysctl.conf 文件底部添加
net.ipv4.ip_forward = 1

# 使修改的配置立即生效
sudo sysctl -p

# 查看当前配置
sudo sysctl net.ipv4.ip_forward

# 如输出以下内容即为修改的配置已生效
net.ipv4.ip_forward = 1

# 查询网卡信息
ip link show

# 假设正常上网网卡为 eth0，Zerotier 虚拟网卡为 zt0
# 添加 iptables 规则允许 eth0 网卡转发所有 Zerotier 虚拟网卡 zt0 的流量
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i zt0 -o eth0 -j ACCEPT

# 由于 iptables 规则会在 VPS 重启后丢失，所以需要使用 iptables-persistent 来保存规则
sudo apt install -y iptables-persistent
# 执行以下命令后会自动保存 IPv4 和 IPv6 规则
sudo netfilter-persistent save

# 查询已保存的规则
sudo iptables-save
```

&emsp;&emsp;执行以上命令后，远程服务节点就能接受来自其他 Zerotier 节点的流量转发请求了。

##### 公网服务器

```bash
# 查询公网服务器的网卡
ip link show

# 假设正常上网网卡为 eth0，Zertiter 虚拟网卡为 zt0
# 添加通往其他远程服务节点的请求交给已配置 Zerotier 的远程服务节点转发
sudo route add -net 192.168.1.0/24 gw 172.18.0.200 dev zt0

# 验证其他远程服务节点是否可达
# 假设某一个其他远程服务节点 IP 为 192.168.1.201
ping -c 10 192.168.1.201
```

&emsp;&emsp;经过以上命令即可配置公网服务器对远程服务环境中的任意节点通过已配置 Zerotier 的远程服务节点可达。

#### 配置 SSH 代理

&emsp;&emsp;SSH 是 Linux/Unix 世界中必不可少的一件神器，通常是用来从本地远程连接服务器。由于 SSH 协议本身是基于加密的，所以在连接后的数据流量是难以被攻击或破解的。当然，SSH 连接建立后，本地节点实际上还可以把远程服务节点的端口映射到本地。即使是在远程服务节点开启的是一个 Web 服务器，通过这样的方式也能在本地使用浏览器访问本地映射端口来实现对远程服务节点上的 Web 服务器的访问。而所需要的唯一一个权限就是可以 SSH 连接登录用户成功。这种方法的安全性极佳，既利用了 SSH 本身的安全性，又不暴露远程服务节点上的任何其他端口给别人。

&emsp;&emsp;SSH 代理功能其实是 SSH 端口转发的一种，其原理是利用一台公网可达的 SSH 服务作为跳板进行二次 SSH 登录。事实上，这种代理登录方式理论上可以支持二次及以上。由阮一峰大佬撰写的 [SSH 教程](https://wangdoc.com/ssh/port-forwarding.htm) 中，对这一内容和原理做了非常详细的介绍，还包括 SSH 密钥登录、证书登录、scp 命令、rsync 命令等。这些知识在这里有非常大的用处。

##### 公网服务器

&emsp;&emsp;为了保障公网服务器的安全性，SSH 代理所使用的用户应该是一个不提供 SHELL 的用户，也就是说某一个客户端使用代理用户和通过验证的私钥登录公网服务器后会被立即退出，而无法停留在公网服务器上。如果为 SSH 代理用户提供了 SHELL，那么任何一个使用该服务的用户都能在公网服务器上操作，这样极不安全，公网服务器甚至可能被破坏。如下可以配置一个有家目录但不允许登录的用户用于 SSH 代理。

```bash
# 创建一个用户名为 nologin_user 的不允许登录但有家目录的用户
sudo useradd -d /home/nologin_user -m -s /sbin/nologin nologin_user

# 添加客户端节点的公钥到 nologin_user 的认证文件中
sudo mkdir /home/nologin_user/.ssh
sudo cat id_rsa.pub >> /home/nologin_user/.ssh/authorized_keys
sudo chown -R nologin_user:nologin_user /home/nologin_user/.ssh

# （可选，建议）配置 nologin_user 登录时不返回登录信息
# 在家目录创建一个名为 .hushlogin 的空文件
sudo touch /home/nologin_user/.hushlogin
```

##### 其他远程服务节点

&emsp;&emsp;为了使用户可以访问其他远程服务节点，在其他远程服务节点上也需要添加客户端节点的公钥到认证文件中，如下所示。

```bash
sudo mkdir /home/nologin_user/.ssh
sudo cat id_rsa.pub >> /home/<username>/.ssh/authorized_keys
sudo chown -R <username>:<username> /home/nologin_user/.ssh
```

##### 本地客户端节点

&emsp;&emsp;本地客户端节点为了可以一步直接登录其他远程服务节点，可以像以下方式一样配置本地 ssh。Linux 或者 Unix 的目录是 ~/.ssh/config，Windows 的目录也是 用户主目录/.ssh/config。

```bash
# ~/.ssh/config

Host remote
    HostName 192.168.1.201
    User ubuntu
    Port 22
    ProxyJump ecs

Host ecs
    HostName 1.1.1.1
    User nologin_user
    Port 22
```

&emsp;&emsp;做好以上配置之后，即可在终端使用 `ssh remote` 命令一键无密码连接到其他远程服务节点。

### 第二种方法

#### 提前准备

- 本地客户端节点、公网服务器、远程服务节点都已安装 Zerotier
- 本地客户端节点 Zerotier 规划 IP 为 172.18.0.11

&emsp;&emsp;如何安装 Zerotier此处不做赘述。

#### 配置互通

&emsp;&emsp;由于在这种方案中本地客户端节点、公网服务器、远程服务节点之间要实现网络完全互通，所以公网服务器和远程服务节点这里都要配置允许路由转发，本地客户端节点和公网服务器都要配置访问其他远程节点的路由转发。

##### 远程服务节点

&emsp;&emsp;和第一种方法中 配置路由转发-远程服务节点 操作一致。

##### 公网服务器

&emsp;&emsp;和第一种方法中 配置路由转发-远程服务节点 操作基本一致，并且添加第一种方法中 配置路由转发-公网服务器 操作。这里不同的是 Zerotier 虚拟网卡需要转发流量，而不是将 Zerotier 虚拟网卡的流量请求转发给主要上网网卡，因此应做如下操作：

```bash
# 允许 zt0 虚拟网卡转发流量请求
sudo iptables -t nat -A POSTROUTING -o zt0 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# 接受一切网卡转发流量请求
sudo iptables -P FORWARD  ACCEPT
# 保存修改的 iptables 规则
sudo netfilter-persistent save
# 查看保存的 iptables 规则
sudo iptables-save
```

##### 本地客户端节点

&emsp;&emsp;和第一种方法中 配置路由转发-公网服务器 操作基本一致。

```bash
# 查询本地客户端的网卡（Linux）
ip link show
# 查询本地客户端的网卡（Mac）
ifconfig

# 假设正常上网网卡为 eth0，Zertiter 虚拟网卡为 zt0
# 添加通往其他远程服务节点的请求交给已配置 Zerotier 的远程服务节点转发
sudo route add -net 192.168.1.0/24 gw 172.18.0.10 dev zt0

# 验证其他远程服务节点是否可达
# 假设某一个其他远程服务节点 IP 为 192.168.1.201
ping -c 10 192.168.1.201
```

&emsp;&emsp;网络互通之后可以直接使用 192.168.1.201 访问到其他远程服务节点，所以对应的 ssh 配置文件修改为以下内容。然后使用 `ssh remote` 命令直接访问其他远程服务节点。

```bash
# ~/.ssh/config

Host remote
    HostName 192.168.1.201
    User ubuntu
    Port 22
```

## 总结与讨论

&emsp;&emsp;软件定义网络在进行异地组网中发挥了很大的作用，并且有一定的安全性保障。但其中也有一些不足之处，比如说两种方法都需要通过公网服务器到远程服务节点，如果要在远程服务节点和本地客户端节点之间上传下载较大的文章，网速仍然会受到公网服务器带宽的限制。如果有一台上下行比较对称、带宽充足的公网服务器，那么就很容易弥补这一不足。

&emsp;&emsp;另外，在使用公网服务器来作为中介去访问远程服务节点时，还是需要注意其安全性如何，毕竟公网服务器是可以被所有人访问到的，也是可以被所有人攻击到的。