---
layout: post
title: 'LDAP 集成之 Nextcloud 篇'
subtitle: '利用 LDAP 为 Nextcloud 提供用户认证服务'
date: 2022-06-24 14:40:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.luish.cc/cover/2OTaQY.webp'
cover_author: 'Emile Guillemot'
cover_author_link: 'https://unsplash.com/@emilegt'
tags:  
- LDAP
- Nextcloud
---

## 前言

### Nextcloud vs ownCloud

&emsp;&emsp;[Nextcloud](https://nextcloud.com) 是一款非常适合个人或者团队使用的开源网盘软件，也有一款和其名字非常相似的 [ownCloud](https://owncloud.com)。实际上这两款开源网盘是出自一个人之手，只不过在发展的过程中（2016年），ownCloud 团队内部产生了一些意见分歧，造成了核心开发人员出走创建了 Nextcloud。与 ownCloud 相比，Nextcloud 更加在乎宽广的功能多样性以及安全性，比如说视频会议、在线协作、提供对密码暴力破解的保护、限制密码错误登录的次数等。ownCloud 中可能也有这些功能，但并不包含在开源版本中，而是需要企业订阅版本才能享受这些功能。从这些看来，Nextcloud 似乎更加适合个人或团队使用。

&emsp;&emsp;据笔者所知，国内 F 搜团队所提供的网盘文档-[F 文档](https:/fdocs.cn) 实际上就是用 Nextcloud 搭建的。其提供的在线文档编辑采用的是开源的 [OnlyOffice](https://www.onlyoffice.com)。

### Nextcloud vs Seafile

&emsp;&emsp;除了 Nextcloud，国内也有一款也比较好用的开源网盘 [Seafile](https://www.seafile.com)。Nextcloud 与 Seafile 虽然都是网盘，但是关注点不大一样。正如上面讲到的 Nextcloud 更在乎协作、功能多样化，而 Seafile 则更在乎稳定和安全。举个例子，Nextcloud 如果不设置服务端加密，所有的文件都会直接存在文件系统中。如果可以访问服务器的文件系统，那么意味着无须任何用户自身的许可就可以查看所有文件。Seafile 默认就将所有文件都分成小块存储，这样一来你是无法直接通过服务器的文件系统读取文件内容的。当然，这样分块存储也有一个好处，在客户端设置同步时会分块进行增量同步，提升了同步的速度和可靠性。不至于一个几个 G 的大文件传到一半中断后又要从头开始上传。不过，这样也有一个比较明显的坏处，如果不借助 Seafile 或其支持团队的帮助，无法自行从分块数据恢复原始文件内容。

### LDAP 认证集成

&emsp;&emsp;从 Nextcloud、ownCloud、Seafile 的官网来看，三者都支持 LDAP/AD 认证集成，但实际上 Seafile 是需要专业版订阅才能有这个功能的，包括 Office 文件预览和编辑、全文检索、断点续传等功能也是需要专业版订阅的。Nextcloud 和 ownCloud 都在开源版本提供了 LDAP 认证集成功能。所以这里也不考虑 Seafile，只以 Nextcloud 为例介绍 LDAP 集成到网盘中。

## 实践

&emsp;&emsp;由于之前笔者也曾写过[《Nextcloud 搭建自己的云盘》](../docker/nextcloud.html)和[《Nextcloud 升级那些事儿》](nextcloud-upgrade.html)两篇文章介绍如何安装和升级 Nextcloud ，所以这里就不再对此进行赘述了。当前开始的环境即是已正常运行的 Nextcloud 实例。

### 启用 LDAP 插件

&emsp;&emsp;在 Nextcloud 的**应用捆绑包**的**企业捆绑包**里就有我们想要用的 LDAP 认证集成插件，点击右侧**启用**按钮即可正常启用。

![nFyWzS](https://i.luish.cc/blog/nFyWzS.webp)

### 配置 LDAP 连接

&emsp;&emsp;在启用 LDAP 插件后，我们就可以在管理员的设置中看见相应的选项。如下图所示，点击用户头像弹出菜单中的**设置**链接。

![8FCrL0](https://i.luish.cc/blog/8FCrL0.webp)

&emsp;&emsp;由于这个设置会同时包含个人用户设置和管理员设置，可以将左侧的导航栏往下拉，看到**管理**中的 **LDAP/AD 集成** 点击进入。

![WiwcTt](https://i.luish.cc/blog/WiwcTt.webp)

&emsp;&emsp;下面是 LDAP/AD 集成的基本设置，主要填写四个信息：LDAP 服务器地址、LDAP 管理员 DN、LDAP 管理员密码、查询基础 DN。由于此处填写的是非真实信息，所以下面会显示**配置错误**的提示。如果填写的 LDAP 信息无误，会自动变成**配置成功**的提示。然后点击**继续**按钮，后面的设置可以保留默认选项即可。当然如果 LDAP 服务与一般的设置有些不同，也要根据实际情况对后面的用户、登录属性、群组信息进行调整，这里就不一一介绍了。

![Lr00tl](https://i.luish.cc/blog/Lr00tl.webp)

&emsp;&emsp;以上配置均完成之后，即可退出登录即可使用 LDAP 账户和密码登录验证是否配置成功（登录界面不会有任何改变）。

### 其他

&emsp;&emsp;可能和 Gitlab 的情况有点类似，Nextcloud 本身就有用户体系，然后才接入的 LDAP 认证。其实，我们还是希望 LDAP 用户和原有用户能够自动识别成同一用户，无感完成合并。这里 Nextcloud 和 Gitlab 一样都是凭借着邮箱来判断的。当 LDAP 用户邮箱与 Nextcloud 原有用户邮箱一致时，自动合并成一个用户，并且不再拥有修改用户密码的权利。虽然已经集成了 LDAP 认证，但是我们依然可以用 Nextcloud 自身的用户体系去创建新用户，这其实也是两个用户体系、一个软件系统。

## 参考资料

- [Nextcloud vs ownCloud? 该选择哪一个云端代管方案呢？](https://news.gandi.net/zh-hans/2021/05/nextcloud-vs-owncloud-which-cloud-solution-should-you-choose/)
- [NextCloud与Seafile对比使用-NextCloud各项全能 Seafile优势突出](https://wzfou.com/nextcloud-seafile/)
