---
layout: post
title: 'LDAP 集成之 Gitlab + Keycloak 篇'
subtitle: '利用 LDAP + Keycloak 为 Gitlab 提供用户认证服务'
date: 2025-09-05 11:30:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/eKVJe8.webp'
cover_author: 'Marek Pavlík'
cover_author_link: 'https://unsplash.com/@marpicek'
tags:  
- LDAP
- Gitlab
- Keycloak
---

## 前言

&emsp;&emsp;在之前的[《LDAP 集成之 Gitlab 篇》](./2022-06-23-ldap-gitlab.md) 和 [《基于 LDAP 的统一认证服务 Keycloak》](./2022-04-27-ldap-integration.md) 中，分别探索了 LDAP 与 Gitlab、Keycloak 的集成。实际上，Gitlab 天然支持三者合一的认证方式，即 "**LDAP 为 Gitlab 提供最底层的用户认证**"和"**Keycloak 提供统一的用户认证入口**"。这样一来，

- 管理员不再需要在 Gitlab **手动创建**用户匹配 LDAP 账户；
- 用户也不再需要在 Gitlab 中**手动绑定** Keycloak 账户之后才能使用 Keycloak 统一认证。

## 实践

### 预先准备

- 已架设好 LDAP 服务
- 已架设好 Keycloak 服务，并配置 LDAP 集成认证
- 已架设好 Gitlab 服务（使用 [sameersbn/gitlab](https://github.com/sameersbn/docker-gitlab) 镜像）

### 配置

```yaml
services:
  ...
  gitlab:
    ...
    environment:
    ...
    - LDAP_ENABLED=true
    - LDAP_PREVENT_LDAP_SIGN_IN=true
    ...
    - OAUTH_AUTO_LINK_LDAP_USER=true
    - OAUTH_AUTO_LINK_USER=IDP
    - OAUTH_OIDC_LABEL=IDP
    - OAUTH_OIDC_ISSUE=https://<Keycloak domain>/realms/master
    - OAUTH_ODIC_CLIENT_ID=<id>
    - OAUTH_ODIC_CLIENT_SECRET=<secret>
```

&emsp;&emsp;这里比较关键的配置就是要**启用自动链接 LDAP 用户**（`OAUTH_AUTO_LINK_LDAP_USER`）和**指定自动链接的第三方认证方式**（`OAUTH_AUTO_LINK_USER`）。为了规避用户直接使用 LDAP 认证登录，可以通过设置 `LDAP_PREVENT_LDAP_SIGN_IN` 来隐藏 LDAP 登录界面。

### 可能存在的问题

#### LDAP 用户被自动封禁

&emsp;&emsp;通过以上设置就可以让用户使用 Keycloak 作为统一入口登录 Gitlab，但是因为 Gitlab 会自动处理 LDAP 后台用户和自动链接，当后台 LDAP 发生变化时（比如修改 RDN 但保持邮件不变）， Gitlab 会自动将用户的状态修改为 `禁用 LDAP`。由于 Gitlab 界面上不提供对于这种特殊情况的**解禁操作**，所以必须通过**后台手动修正**。

> info "提示"
> &emsp;&emsp;在后台手动修正之前，先通过界面进入后台手动将用户原先绑定的 RDN 修改为 LDAP 服务中正确的 RDN。



```bash
# 进入 Gitlab 容器
docker exec -ti gitlab-gitlab-1 bash

# 进入 Gitlab 控制台，可能需要等待 1 分钟
root@gitlab:/home/git/gitlab# RAILS_ENV=production bundle exec rails console
--------------------------------------------------------------------------------
 Ruby:         ruby 3.2.9 (2025-07-24 revision 8f611e0c46) [x86_64-linux]
 GitLab:       18.3.1 (bccd1993b5d) FOSS
 GitLab Shell: 14.44.0
 PostgreSQL:   16.9
------------------------------------------------------------[ booted in 41.09s ]
Loading production environment (Rails 7.1.5.1)
irb(main):001>

# 查看被禁用 LDAP 的用户
irb(main):002> User.where(state: 'ldap_blocked')

# 解禁单个用户
irb(main):003> u = User.find_by_username('username')
irb(main):004> u.activate!
irb(main):005> u.save!

# 退出控制台
irb(main):006> exit
```

如果想要批量解禁 LDAP 用户可以在控制台执行以下命令：

```bash
# 批量解禁
User.where(state: 'ldap_blocked').find_each do |u|
  u.activate!
  u.save!
  puts "✅ Activated #{u.username}"
end
```

#### 自定义 Gravatar

&emsp;&emsp;由于 Gitlab 默认使用 Gravatar 为用户提供头像，且 Gravatar 访问一直不稳定，推荐使用自定义的 Gravatar 地址，如下设置：

```yaml
services:
  ...
  gitlab:
    ...
    environment:
    ...
    - GITLAB_GRAVATAR_ENABLED=true
    - GITLAB_GRAVATAR_HTTP_URL=https://weavatar.com/avatar/%{hash}?s=%{size}&d=identicon
    - GITLAB_GRAVATAR_HTTPS_URL=https://weavatar.com/avatar/%{hash}?s=%{size}&d=identicon
```
