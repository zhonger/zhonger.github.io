---
layout: post
title: '基于 LDAP 的统一认证服务 Keycloak'
subtitle: '用 LDAP 来为各式各样的应用提供统一认证服务'
date: 2022-04-27 15:44:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://images.unsplash.com/photo-1510423579098-f47bf52b6764?w=1600&q=900'
tags:  
- LDAP
- 集成
- 统一认证
- 单点登录
- Keycloak
---

## 前言

&emsp;&emsp;此前，笔者曾写过一篇[《OpenLDAP 安装初体验》](/tech/docker/openldap.html)尝试使用 Docker 一键式部署 OpenLDAP。其中，对 LDAP 协议也作了一定的基础入门，但对如何利用 LDAP 来为各式各样的应用提供统一认证服务还未有深入的实践。本文就打算以 LDAP 为中心集成到团队内部的各类第三方系统或服务中。例如，团队内部常用的私有化代码托管服务 Gitlab、网盘服务 Nextcloud、缓存加速服务 Squid、访问内部集群的专用 OpenVPN 服务、内部团队知识库服务 Dokuwiki、内部代码库及容器镜像服务 Nexus3 等等。

## 统一认证服务

&emsp;&emsp;随着应用系统的爆发式增长，统一认证服务（UIA）显得越来越重要。通俗来说，统一认证服务就是可以使用一套账号和密码访问一系列的网站应用、APP 应用，为用户免去了维护大量账号和密码的烦恼，同时也为用户的账号安全提供了一定的保障。比如说，统一认证服务可以要求用户在登录时输入短信验证码、邮件验证码或者动态二次验证码等多因素认证，全方位保证用户登录安全。像大学里我们之所以可以使用学号和密码访问或者验证学校的所有网站应用及其他权限，就是因为采用了统一认证服务。

&emsp;&emsp;统一认证服务一般与授权控制相关联，可以确认用户对哪种资源有权限访问、可以进行哪种方式的操作等。当然，各个应用系统也可以有自己的授权控制体系，直接采用或者补充已有的统一认证服务提供的授权控制都是可以的。常见的统一认证解决方案有 OpenID Connect、OAuth 2.0、SAML2（Shibboleth）、CAS 等等。实际上，这些解决方案都需要有一个实现存储用户信息的方式，当然我们可以用关系型数据库来实现，也可以用轻量级目录协议（LDAP）来实现。在之前的文中就谈到过，LDAP 相比较关系型数据库而言，查询和浏览速度更快，但 LDAP 属性值的修改和属性有一定的限制。因此，实际的统一认证服务搭建会结合两者及其优势进行互补，从而提供更加全面的、可靠的认证服务。

&emsp;&emsp;除了统一认证服务之外，还有单点登录服务（SSO）。与统一认证相比，单点登录一次登录成功后，访问其他支持同一单点登录的网站应用时即可自动无感知认证，直接免去了用户再次登录的烦恼。当然，现在的统一认证服务也大多集成了单点登录服务。所以我们可以认为现在完整的统一认证服务应该具备以下几点：

- 支持一套账户和密码访问多个应用系统；
- 具备多因素认证安全性校验；
- 支持基本的用户权限控制；
- 支持单点登录，切换站点时自动无感知认证。

## 统一认证服务实践

&emsp;&emsp;在给的参考资料中已经详细介绍了不同种统一认证服务解决方案（协议），其中当属 OpenID Connect 方案对以上几点功能性要求满足的比较好。在我们日常生活中使用的微信、QQ、百度、淘宝等等均是采用这一解决方案，我们也通常将这一类的第三方登录方式称为“社交化登录”。当然，这些产商之所以选择 OpenID Connect 而不选择 CAS，可能主要还是因为 OpenID Connect 是基于 OAuth 2.0 的统一认证服务解决方案。虽然 CAS 也已经开始内置了 OAuth 2.0 认证，甚至兼容 SAML2 等等，但是终究还是会受限于 B/S 场景。OpenID Connect 面向的场景则不仅限于 B/S，还有 C/S。要知道，随着智能手机的发展，移动客户端已经成为了一个非常大的市场，甚至每日访问量要远高于桌面浏览器端。

&emsp;&emsp;为了验证一下是否可以采用 LDAP 作为基础存储来构建统一认证服务，这里选择了比较知名的由 RedHat 赞助开发的基于 OpenID Connect 协议的开源软件 [Keycloak](https://www.keycloak.org/)。其实，基于 CAS 协议也有比较知名的 [aperoeo/cas](https:/aperoeo.github.io/cas/)。但是怎么说呢，不选它有两个原因：一是它是基于 CAS 协议的；二是它的功能和我想要的有点不大一样。虽然也可以把 LDAP 作为基础存储，但是所有数据只读。个人觉得一个可以把 LDAP 作为基础存储的统一认证服务解决方案至少应该给用户一个可选项，选择只读还是可写都应该由用户自行决定。在这一点上，Keycloak 要做得更好。

### Keycloak 的部署

&emsp;&emsp;Keycloak 官方提供编译好的 Docker 镜像，我们可以使用 docker-compose 进行一键式部署。配置文件内容如下所示：

```yaml
# docker-compose.yml

version: '3'

services:
  postgres:
      image: postgres
      volumes:
        - ./data:/var/lib/postgresql/data
      environment:
        POSTGRES_DB: keycloak
        POSTGRES_USER: keycloak
        POSTGRES_PASSWORD: password
  keycloak:
      image: quay.io/keycloak/keycloak:legacy
      environment:
        DB_VENDOR: POSTGRES
        DB_ADDR: postgres
        DB_DATABASE: keycloak
        DB_USER: keycloak
        DB_SCHEMA: public
        DB_PASSWORD: password
        KEYCLOAK_USER: admin
        KEYCLOAK_PASSWORD: Pa55w0rd
      ports:
        - 8080:8080
      depends_on:
        - postgres
```

&emsp;&emsp;使用 `docker-compose up -d` 命令启动服务。此处之所以使用的 legacy 标签而非 latest 标签，主要是因为 Keycloak 团队正在启动的方式和相关参数进行调整。latest 标签可以使用 `docker run` 命令正常启动，但是 docker-compose 有点不大好使。两个标签的代码版本实际上是完全一样的，只是启动服务有些差别。

### Keycloak 的使用

&emsp;&emsp;访问 [http://127.0.0.1:8080/auth/realms/master/account/#/](http://127.0.0.1:8080/auth/realms/master/account/#/) 即可进入用户页，点击右上角进行登录。此处直接使用上面配置文件中的管理员用户账号和密码。

![vgy.me](https://i.vgy.me/ly4tKf.png)

![vgy.me](https://i.vgy.me/aUGnww.png)

&emsp;&emsp;登录成功后可以看到右上角已经有了用户名，登录按钮也变成了登出按钮。

![vgy.me](https://i.vgy.me/r19LoW.png)

#### 国际化设置

&emsp;&emsp;访问 [http://127.0.0.1:8080/auth/admin/master/console](http://127.0.0.1:8080/auth/admin/master/console) 即可进入管理员页面并自动登录。

![vgy.me](https://i.vgy.me/Zc3XO1.png)

&emsp;&emsp;切换到 Themes（主题）选项卡下，开启国际化并可设置默认的界面语言，然后点击保存即可。

![vgy.me](https://i.vgy.me/un2kGb.png)

&emsp;&emsp;刷新页面就能看见设置好的中文界面。

![vgy.me](https://i.vgy.me/mxrpMe.png)

#### 连接 LDAP

&emsp;&emsp;左边导航栏切换到**用户联合**选项卡，选择添加 ldap。

![vgy.me](https://i.vgy.me/VUTllR.png)

&emsp;&emsp;如下所示输入对应的配置信息，这里由于是连接 OpenLDAP 所以供应商选择**其他**。为了用户可以通过 Keycloak 来修改 LDAP 的密码，这里的编辑模式选择**可写**。另外在填写完配置后可以用右侧的**测试连接**和**测试验证**按钮来测试该配置是否可行。如下图所示，顶部出成功验证提示。点击保存完成 LDAP 配置。

![vgy.me](https://i.vgy.me/GyOK27.png)

&emsp;&emsp;当保存 LDAP 配置之后刷新页面，在下面会出现四个新的按钮。点击**同步所有用户**即可将用户同步到 Keycloak。

![vgy.me](https://i.vgy.me/Qt76Uc.png)

&emsp;&emsp;切换左边导航栏到**用户**选项卡，默认是空的，点击查看所有用户即可看到包含 admin 和 LDAP 中的用户。

![vgy.me](https://i.vgy.me/MVgEWe.png)

&emsp;&emsp;如下图所示，证明 Keycloak 成功连接 LDAP。

![vgy.me](https://i.vgy.me/6iSaAf.png)

#### 用户密码策略

&emsp;&emsp;由于 LDAP 本身修改密码不是很方便，需要有额外的第三方的方式支持，这里就采用 Keycloak 内置的方式来修改 LDAP 中的密码。为了保证用户修改的密码具有一定的安全性，我们需要设置一些新密码的复杂规则。切换左边导航栏到**验证**选项卡，再选择**密码策略**选项卡，使用右上角的**添加策略**添加不同的策略要求，完成后点击保存按钮。

![vgy.me](https://i.vgy.me/OzRYBk.png)

&emsp;&emsp;虽然我们在此处设置了对新密码的复杂度的策略要求，但是其实还没有对系统中的用户进行生效。我们需要再次到刚才的 LDAP 配置的高级设置中打开**验证密码策略**。下图中的 **LDAPv3 密码** 可以选择打开或不打开，影响不大。 

![vgy.me](https://i.vgy.me/L14NPG.png)

&emsp;&emsp;为了验证用户密码策略是否真的生效，需要切换到最开始的用户页。点击 **Update** 按钮即可跳转到更新密码页。这里可能系统会对安全性进行校验要求你再次输入密码以及二次验证码（如果有），输入即可。

![vgy.me](https://i.vgy.me/tkOthq.png)

&emsp;&emsp;以下是一个设置简单密码 1234 所返回错误提示的例子。一般来说，我们会对密码设置以下策略：

- 密码长度不得小于 8 位，不得大于 32 位
- 密码中必须同时包含大小写字母
- 密码中必须包含数字
- 密码中必须包含至少一个特殊字符

![vgy.me](https://i.vgy.me/rFN9HY.png)

#### OTP 验证

&emsp;&emsp;正如之前分析的一样，一个完整的统一认证服务应该具有多因素认证。而多因素认证中相较更为安全的就是 OTP（一次性密码）。Keycloak 就支持 OTP 验证。从下面的页面可以看到，默认的 OTP 策略配置是可以使用 FreeOTP 和 Google Authenticator。但是如果你修改了其中的一项配置，保存后就会显示只支持 FreeOTP。说来也奇怪，FreeOTP 这款开源软件好像不怎么更新了，其安卓客户端已经非常古老了。据笔者测试，如果 OTP 策略支持 Google Anthenticator，那么现在市面上比较流行的 Authy、Microsoft Anthenticator 等等都能支持。

![vgy.me](https://i.vgy.me/D2ipD0.png)

&emsp;&emsp;为了让系统的所有用户都开启 OTP，可以如下所示在**必要操作**选项卡中配置 OTP 为默认操作。这样一来，用户在第一次登录后就会被要求配置 OTP。（PS：微软的 Office365 也是会有这个默认要求。）

![vgy.me](https://i.vgy.me/rCUpj0.png)

&emsp;&emsp;为了验证 OTP 是否可用，移步至用户页点击**设置验证应用**按钮。

![vgy.me](https://i.vgy.me/sgq7hF.png)

&emsp;&emsp;点击后跳转到配置页面如下。使用刚才说到的任意一款应用扫描页面中的二维码即可完成添加。之后根据应用上显示的二次验证码填写这里的一次性验证码，点击提交。如果正常跳转，说明配置成功。如果配置失败，将会停留在此页面，并有红色错误提示出现。

![vgy.me](https://i.vgy.me/mFizpx.png)

## LDAP 直接集成应用

&emsp;&emsp;除了上面介绍了搭建基于 LDAP 的统一认证服务（例如 Keycloak）可以为其他应用提供登录验证服务，还可以直接将应用与 LDAP 服务集成。这里可能会有一个疑问：既然 LDAP 自身就可以与应用集成，为什么还要费这么大劲去搭建基于 LDAP 的统一认证服务呢？其实这里需要考虑“ LDAP 暴露在公网好还是统一认证服务暴露在公网好？”这个问题。LDAP 作为目录服务，最根本的目的是服务于内部网络中的应用，而非广域网中的应用。有了统一认证服务就可以很好的将 LDAP 安安全全地保护在内网中，而统一认证服务则作为一个网页应用与其他网页应用或客户端应用进行交互。这样的方式或许显得更加优雅、放心。

&emsp;&emsp;这里，打算之后就《LDAP 集成》为主题写一个系列（挖一个坑）。（PS：先预给出对应链接，如果能够访问那就是写好了。）

- [《LDAP 集成之 Gitlab 篇》](/tech/webmaster/ldap-gitlab.html)
- [《LDAP 集成之 Squid 篇》](/tech/webmaster/ldap-squid.html)
- [《LDAP 集成之 Nextcloud 篇》](/tech/webmaster/ldap-nextcloud.html)
- [《LDAP 集成之 Dokuwiki 篇》](/tech/webmaster/ldap-dokuwiki.html)
- [《LDAP 集成之 Squid 篇》](/tech/webmaster/ldap-squid.html)
- [《LDAP 集成之 OpenVPN 篇》](/tech/webmaster/ldap-openvpn.html)
- [《LDAP 集成之 Nexus3 篇》](/tech/webmaster/ldap-nexus3.html)
- [《LDAP 集成之 Apache 篇》](/tech/webmaster/ldap-apache.html)
- [《LDAP 集成之 Nginx 篇》](/tech/webmaster/ldap-nginx.html)

## 参考资料

- [OpenLDAP 落地实战](https://www.infvie.com/ops-notes/openldap-2.html)
- [选择合适的用户系统 - cas、keyclock、authz、authing 等的对比](https://rxrw.me/tech/user-system-compare/)
- [统一身份认证和单点登录的区别](https://zhuanlan.zhihu.com/p/275994810)
- [单点登录 SSO、OAuth、LDAP、CAS 的流程与应用](https://www.cxyzjd.com/article/wxb880114/101370975)
- [Privacy Enhancement for Open Federated Identity/Access Management Platforms](https://www.soumu.go.jp/main_content/000256289.pdf)
- [How to run Keycloak with Docker](http://www.mastertheboss.com/keycloak/keycloak-with-docker/)