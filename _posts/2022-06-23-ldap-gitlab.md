---
layout: post
title: 'LDAP 集成之 Gitlab 篇'
subtitle: '利用 LDAP 为 Gitlab 提供用户认证服务'
date: 2022-06-23 15:20:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.luish.cc/cover/8XVXW3.webp'
cover_author: 'Steve Johnson'
cover_author_link: 'https://unsplash.com/@steve_j'
tags:  
- LDAP
- Gitlab
---

## 前言

&emsp;&emsp;Gitlab 是一款对标 Github 的开源 Git 管理软件，能够为用户提供非常丰富的功能。因为之前写过的[《私有代码托管平台的搭建与运维》](../tech/docker/gitlab.html)和[《Gitlab 升级那些事儿》](./gitlab-upgrade.html)已经对 Gitlab 作了比较详细的介绍，这里就不多赘述了。

### 国内高校 Gitlab

&emsp;&emsp;Gitlab 提供了对于多种认证方式的支持，包括自带的用户体系、LDAP、CAS、OAuth 2.0 及其他第三方认证方式。这也为我们实现不同的用户需求提供了可能。国内高校中，中科大和南京大学都为本校生提供了基于 Gitlab 的代码托管服务，访问地址如下。唯一不同的是，中科大采用的社区版本（CE），南京大学采用的是由 Gitlab 在中国的子公司极狐支持的企业版本（EE），据说有一些更先进的功能。当然，考虑到使用 Gitlab 的主要需求是代码托管，而非 Gitlab Pages 功能，两家都没有提供该功能。

| 学校 | Git URL |
| :---: | :---: |
| 中科大 | [https://git.lug.ustc.edu.cn](https://git.lug.ustc.edu.cn) |
| 南京大学 | [https://git.nju.edu.cn](https://git.nju.edu.cn) |

&emsp;&emsp;言归正传，中科大和南京大学都可以自助注册，只需要是使用学校邮箱即可。中科大同时也提供了 Github、Gitlab、学校一卡通认证。自助注册的好处是，即使已经离校无法使用学校邮箱，实际上也还是可以保留账户继续使用（除非专门对毕业生进行封禁）。其实，对于内部团队使用的 Gitlab 来说，由管理员手动创建用户也是没有什么问题的，毕竟人数不会太多。但是这样一来，可能会出现维护多个账号和密码的烦恼。因此，采用 LDAP 来接入认证是比较合适的。对于非团队用户不打算放在 LDAP 目录里也可以手动在 Gitlab 创建用户，当用户不再使用时就可以封禁。

### LDAP 用户合并

&emsp;&emsp;也可能存在先有 Gitlab 账户、然后才有的 LDAP 目录的情况，这也不要紧，因为 Gitlab 支持 LDAP 认证方式的用户与现有用户进行合并。举个例子，如果我已经在 Gitlab 中创建了用户名为 zhonger、邮箱为 zhonger@example.com 的用户，那么我在 LDAP 目录中只需要把 mail 字段也写成 zhonger@example.com 即可被 Gitlab 识别成同一用户。或者说，我们可以在 Gitlab 中增加 LDAP 目录中的 mail 字段的邮箱（Gitlab 支持同一用户绑定多个邮箱），这样在 Gitlab 中使用 LDAP 认证的时候也会被视为同一用户。

> info "小提示"
> &emsp;&emsp;由于 LDAP 用户的账户名和密码不会被 Gitlab 接管，所以当你使用 LDAP 认证登录后，原有的同邮箱的 Gitlab 用户就会自动丧失修改密码的权利。除此之外，一切照旧。

## 实践

&emsp;&emsp;为了更加简便实践并且容易复现，这里采用的是常用的 [sameersbn/docker-gitlab](https://github.com/sameersbn/docker-gitlab) Docker 镜像。可以在镜像 Github 页面下载到提供的对应 [docker-compose.yml](https://github.com/sameersbn/docker-gitlab/blob/master/docker-compose.yml) 文件。由于 LDAP 并非是默认配置，所以默认是没有 LDAP 配置段的。需要在 docker-compose.yml 文件的 environment 中增加以下环境变量。其中，请根据实际情况更改成相应的信息。

```yaml
...
    environment:
        ...
        - LDAP_ENABLED=true
        - LDAP_LABEL=LDAP
        - LDAP_HOST=ldap.example.com
        - LDAP_BIND_DN=cn=admin,dc=example,dc=com
        - LDAP_PASS=xxxxxxxxxxx
        - LDAP_UID=uid
        - LDAP_BASE=ou=people,dc=example,dc=com
...
```

&emsp;&emsp;使用命令 `docker-compose up -d` 运行一个 Gitlab 实例。由于初始运行需要执行数据库初始化等操作，可能需要几分钟，之后打开指定的端口即可看到如下类似的登录页面。可以看到，这里默认就是使用 LDAP 登录，次要登录方式才是标准登录。

![登录页面 Login Page](https://i.luish.cc/blog/BaWBKa.webp)

> info "小提示"
> &emsp;&emsp;这里 Gitlab 默认使用 uid 作为 username，而非常见 LDAP 登录定义里的 cn 字段，所以只需要最简单的 uid 和 password 即可登录成功。

## 参考资料

- [sameersbn/docker-gitlab](https://github.com/sameersbn/docker-gitlab)
