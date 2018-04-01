---
layout: post
title: unbound+dnscrypt搭建无污染DNS服务
subtitle: 从零开始搭建一个无污染的DNS服务
date: 2017-12-03 18:23:41 +0800
tags:
- DNS
- unbound
- dnscrypt
categories:
- tech
cover: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1680&q=80'
---

# 引言

鉴于某些原因，我们日常生活中使用的公共DNS总是会存在一些奇奇怪怪的DNS解析，例如某些国内云平台大型网站无法正常解析DNS，因此搭建无污染DNS服务成为了一项值得尝试、有意义的事情。在搭建的技术栈上，我们选择了`unbound`和`dnscrypt`。当然，这个世界上还有很多开源的、很好用的DNS服务器产品，比如`knot DNS`、`dnspord-sr`、`powerdns`等，它们也在很多大型的ISP提供商的DNS产品上得到了很多的实践，但是就我们个人而言，如果需要搭建一个小范围、公共的DNS服务，那么`unbound`是足够的，并且对于我们实现无污染有非常好的基础。废话少说，不如跟我一起来搭建一下。

# 实验环境

操作系统：CentOS 6.9 \\
`Unbound`版本：目前最新`1.6.7` [源码下载地址](http://unbound.net/downloads/unbound-latest.tar.gz) \\
`Dnscrypt-proxy`版本：目前最新`1.9.5` [源码下载地址](https://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-proxy-1.9.5.tar.gz) \\
依赖库`libsodium`版本：目前最新`1.0.15`[源码下载地址](https://download.libsodium.org/libsodium/releases/libsodium-1.0.15.tar.gz) \\
依赖库`libevent`版本：目前最新`2.1.8`[源码下载地址](https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz)(在github上，需要浏览器下载)

# 实验过程



### 安装libsodium

```bash
#解压 
tar zxf libsodium-1.0.15.tar.gz 
#进入文件夹
cd libsodium-1.0.15

#编译
./configure
./autogen.sh
./configure
make -j12 
#j后面为CPU核数，加快编译
sudo make install
sudo ldconfig
#安装完成
```

### 安装libevent

```bash
#解压
tar zxf libevent-2.1.8-stable.tar.gz
#进入文件夹
cd libevent-2.1.8-stable

./configure --prefix=/usr
./autogen.sh
./configure
make -j12
sudo make install
sudo -i
echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
sudo ldconfig
安装完成
```

### 安装dnscrypt-proxy

```bash
#解压
tar zxf dnscrypt-proxy-1.9.5.tar.gz
#进入文件夹
cd dnscrypt-proxy-1.9.5

./configure
make -j12
sudo make install

#如果提示报错 与libevent有关
#请再次运行 sudo ldconfig 并重新运行以上命令。
```

### 配置dnscrypt-proxy

```conf
#配置文件目录
#/usr/local/etc/dnscrypt-proxy.conf
ResolverName cisco
ResolversList /usr/local/share/dnscrypt-proxy/dnscrypt-resolvers.csv
Daemonize no
PidFile /var/run/dnscrypt-proxy.pid
User dnscrypt
LocalAddress 127.0.0.1:5353
#可选
QueryLogFile /tmp/dns-queries.log
QueryLogFile /tmp/dns-
```
```bash
#添加用户`dnscrypt`：
sudo useadd -d /var/run/dnscrypt dnscrypt
#创建主目录并赋予权限：
sudo mkdir /var/run/dnscrypt && sudo chown dnscrypt /var/run/dnscrypt
#运行：
sudo /usr/local/sbin/dnscrypt-proxy /usr/local/etc/dnscrypt-proxy.conf

#如果是在ubuntu系统下或者能够使用systemctl的环境下，请在/usr/lib/systemd/system/dnscrypt-proxy.socket修改配置，参考资料3中所示。
```

### 安装unbound

```bash
#解压
tar zxf unbound-1.6.7.tar.gz
#进入文件夹 
cd unbound-1.6.7

./configure --with-libevent
make -j12
sudo make install
安装完成
```

### 配置unbound

```bash
下载`dnsmasq-china-list`：
wget -c https://github.com/felixonmars/dnsmasq-china-list/archive/master.zip
解压并进入文件夹：
unzip master.zip && cd dnsmasq-china-list-master
生成`accelerated-domains.china.unbound.conf`：
make unbound
移动加速配置到`unbound`配置目录：
sudo mv accelerated-domains.china.unbound.conf /usr/local/etc/unbound
下载`named.cache`到`/usr/local/etc/unbound`目录：
wget -c ftp://FTP.INTERNIC.NET/domain/named.cache 
修改配置文件`/usr/local/etc//unbound/unbound.conf`：
```
```conf
server:
      num-threads: 2 # 线程数可以修改为物理核心数
      interface: 0.0.0.0 # 侦听所有 IPv4 地址
      interface: ::0 # 侦听所有 IPv6 地址
      # 如果只需要本机使用，则一个 interface: 127.0.0.1 即可
      so-rcvbuf: 4m
      so-sndbuf: 4m # 本机使用的话，这俩 buf 可以取消注释
      so-reuseport: yes # 如果开了多线程，就写 yes
      msg-cache-size: 64m # 本机可以设置 4m 或者更小
      rrset-cache-size: 128m # 本机可以设置 4m 或者更小
      cache-max-ttl: 3600 # 建议设置一个不太大的值...专治各种运营商 DNS 缓存不服
      outgoing-num-tcp: 256 # 限制每个线程向上级查询的 TCP 并发数
      incoming-num-tcp: 1024 # 限制每个线程接受查询的 TCP 并发数
      # 下面这四个不需要解释了吧，不想用那个就写 no
      do-ip4: yes
      do-ip6: yes
      do-udp: yes
      do-tcp: yes
      tcp-upstream: no # 默认是 no，隧道状态比较稳的话也不需要写 yes。一些情况下强制使用 tcp 连上游的话写 yes
      access-control: 0.0.0.0/0 allow # 本机用的话建议设置 127.0.0.0/8 allow，局域网用适当调整
      chroot: "/usr/local/etc/unbound"
      username: "unbound"
      root-hints: "/usr/local/etc/unbound/named.cache" # 没有的话在 ftp://FTP.INTERNIC.NET/domain/named.cache 下载一份
      hide-identity: yes # 不返回对 id.server 和 hostname.bind 的查询。
      hide-version: yes # 不返回对 version.server 和 version.bind 的查询。
      # 不过下面有 identity 和 version 的自定义选项，不隐藏这些的话，修改下选项还可以卖个萌(´・ω・｀)
      harden-glue: yes # 建议打开
      module-config: "iterator" # 禁用 DNSSEC 检查，如果上游不支持 DNSSEC 就关掉。注意这个选项有可能在其他 include 的文件里
      unwanted-reply-threshold: 10000000 # 针对各种网络不服，数值为建议值，具体可以自己修改看看效果
      do-not-query-localhost: no # 一般是为了防止扯皮丢包开着，不过等下要用 DNSCrypt 所以关掉
      directory: "/usr/local/etc/unbound"
      pidfile: "/usr/local/etc/unbound/unbound.pid"
      prefetch: yes # 蛮好用的，开着吧
      minimal-responses: yes # 省带宽，开着吧。本机用可以关掉
      # 关键部分来了，把默认查询全部丢给 DNSCrypt。使用 [地址]@[端口] 指定查询地址和端口，默认端口 53。
      # 然后把国内的地址丢给国内的缓存服务器。这两个选项的顺序不能错哟。
      # 如果使用隧道查询，把这个地址改为隧道对端的地址，或者一个国外的 DNS 服务器都可以，例如 8.8.8.8。
      # 具体看是在对端开 DNS 还是直接用国外的服务器。后者的话，前面 outgoing-interface 可以直接设置隧道本地端的地址，不过要配合 dnsmasq-china-list 的话，还是写路由表比较合适，否则不够灵活。
      include: "/etc/unbound/accelerated-domains.china.unbound.conf"

forward-zone:
    name: "."
    forward-addr: 127.0.0.1@5353
```
```bash
#运行：
sudo /usr/local/sbin/unbound -c /usr/local/etc/unbound/unbound.conf 
（会自动进入后台执行）
```

# 实验验证

```bash
dig facebook.com  @114.114.114.114
dig facebook.com  @127.0.0.1
#将两条命令查询出的ip放到ipip.net查询一下，看是否属于facebook机房的。可以看出，前者不是后者是，那么就无污染DNS就搭建完成了。虽然这样一来你就能够获得正确的facebook.com的ip，但是这并不意味着你就能正常访问facebook，因为ip是不通，这也正是为什么修改hosts而无法访问某搜索引擎的原因了。
```

# 参考资料

- https://03k.org/linux-dnscrypt-proxy.html
- http://blog.csdn.net/guowenyan001/article/details/39048893
- https://blog.phoenixlzx.com/2016/04/27/better-dns-with-unbound/

