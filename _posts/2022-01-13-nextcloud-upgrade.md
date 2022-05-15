---
layout: post
title: 'Nextcloud 升级那些事儿'
subtitle: '了解更加深入的 Nextcloud 升级及修复'
date: 2022-01-13 11:26:00 +0900
tags: 
- Nextcloud
- Upgrade
- Docker
- 升级
- 修复
categories: [tech, webmaster]
cover: 'https://images.unsplash.com/photo-1640554518394-5c45f8f95deb?w=1600&q=900'
---

## 前言

&emsp;&emsp;Nextcloud 的升级根据部署方式的不同也会有所差异。比如源码部署的 Nextcloud 的升级，一般是通过在网页端的管理页面点击升级按钮、经过漫长的等待然后完成。由于这种方式的升级要对本地的源代码同时进行升级，因此存在本地环境与升级所需环境不一致而导致升级失败的可能性。当然，一般来说源码升级总是要先看看环境要求是否相同，如果不同则应该先满足环境要求、再进行后续的升级。

&emsp;&emsp;而对于 Docker 方式部署的 Nextcloud 来说，源代码、数据文件（包括配置文件和网盘文件）、数据库、缓存数据库四者之间既可独立维护，也可搭配使用。这样一来，每次的升级基本上都只需要升级一下源代码的容器镜像即可。数据文件一般是直接本地持久化的，数据库容器镜像一般不太更新，除非是 Nextcloud 进行数据库大版本升级的大更新。至于缓存数据库（比如 Redis），升不升级都不大会影响 Nextcloud 的正常运行，除非是缓存数据库新旧版本的差异导致源代码无法直接使用新版本的缓存数据库。

&emsp;&emsp;之前笔者也写过两篇关于 Nextcloud 的文章： [Nextcloud 搭建自己的云盘](../webmaster/nextcloud.html) 和 [Nextcloud 源码部署迁移到容器部署](../docker/nextcloud-docker.html)。其中前一篇中其实也包括正常的 Docker 部署方式的 Nextcloud 升级，那为什么又要重新写一篇专门关于 Nextcloud 升级的文章呢？主要还是因为在实际升级过程中，发现了一些容易出问题的升级方式，而“如何在此基础上进行修复”是一件非常有意思的事情。那么接下来就来看看 Nextcloud 升级过程中到底能遇到哪些问题呢。

## 问题及修复

### 问题一：跨版本升级

#### 问题描述

&emsp;&emsp;所谓跨版本升级就是指跳过某些重要版本更新而直接升级到另一个大版本。之前在 [私有代码托管平台的搭建与运维](../docker/gitlab.html) 一文也提到过 Gitlab 的版本升级中不能直接从一个旧版本直接升级到最新版本，Nextcloud 亦然。比如，从 Nextcloud 22.0 版本升级到 Nextcloud 23.0 版本的话，就属于跨版本升级（在它们之间有一个重要版本更新 Nextcloud 22.2）。

#### 修复方案

&emsp;&emsp;如果你在更新 Nextcloud 时未对版本更新可行性进行检验而直接跨版本更新，那么你将会在 Docker 容器的日志上看到提示无法跨版本更新。此时，由于容器只修改了 www/version.php 文件（如下所示），未对数据库及其他文件进行修改，还是可以修复回来的。

```php
<!-- version.php -->

<?php
$OC_Version = array(23,0,0,10);
$OC_VersionString = '23.0.0';
$OC_Edition = '';
$OC_Channel = 'stable';
$OC_VersionCanBeUpgradedFrom = array (
  'nextcloud' =>
  array (
    '22.2' => true,
    '23.0' => true,
  ),
  'owncloud' =>
  array (
    '10.5' => true,
  ),
);
$OC_Build = '2021-11-26T20:54:42+00:00 0619207f13792250aea775a2c3133d41ab625980';
$vendor = 'nextcloud';
```

&emsp;&emsp;修复的主要步骤分为以下两步：

- 将 version.php 文件修改为以下内容，然后重新使用 nextcloud:22.0 容器启动。
- 启动后会发现一切恢复正常，然后根据 22.0 -> 22.2 -> 23.0 的规划路线进行正常升级即可。一般来说，升级镜像后镜像内部会自动运行更新命令，并在更新完成后自动关闭维护模式。如果镜像内部为自动运行，可以参考下面命令手动完成相关插件更新。

```php
<!-- modified version.php -->

<?php
$OC_Version = array(22,0,0,12);   // 修改为升级前版本号
$OC_VersionString = '22.0.0.12';  // 修改为升级前版本号
$OC_Edition = '';
$OC_Channel = 'stable';
$OC_VersionCanBeUpgradedFrom = array (
  'nextcloud' =>
  array (
    '22.0' => true,               // 添加支持从升级前版本号开始升级
    '22.2' => true,
    '23.0' => true,
  ),
  'owncloud' =>
  array (
    '10.5' => true,
  ),
);
$OC_Build = '2021-11-26T20:54:42+00:00 0619207f13792250aea775a2c3133d41ab625980';
$vendor = 'nextcloud';
```

```bash
# 手动更新镜像内部插件，并在更新后关闭维护模式。

docker exec -u www-data -ti nextcloud_app_1 php occ maintenance:mode --on
docker exec -u www-data -ti nextcloud_app_1 php occ upgrade
docker exec -u www-data -ti nextcloud_app_1 php occ maintenance:mode --off
```

### 问题二：数据库索引缺失

#### 问题描述

&emsp;&emsp;在完成新版本更新后，打开管理员的概览界面，有的时候会看到如下报错：

```bash
在数据表 “oc_share” 中无法找到索引 “share_with_index”。
在数据表 “oc_share” 中无法找到索引 “parent_index”。
在数据表 “oc_share” 中无法找到索引 “owner_index”。
在数据表 “oc_share” 中无法找到索引 “initiator_index”。
在数据表 “oc_filecache” 中无法找到索引 “fs_mtime”。
```

#### 修复方案

&emsp;&emsp;一般我们可以在报错的提示中看到建议执行命令 `occ db:add-missing-indices` 来修复丢失的索引。在容器外我们可以采用以下命令执行：

```bash
docker exec -u www-data -ti nextcloud_app_1 php occ db:add-missing-indices
```

### 问题三：数据库类型转换失败

#### 问题描述

&emsp;&emsp;数据库中的一些列由于进行长整型转换而缺失。由于在较大的数据表重改变列类型会耗费一些时间，因此程序没有自动对其更改。以下为可能提示的列：

```bash
activity.activity_id
activity.object_id
activity_mq.mail_id
filecache.fileid
filecache.storage
filecache.parent
filecache.mimetype
filecache.mimepart
filecache.mtime
filecache.storage_mtime
mimetypes.id
mounts.storage_id
mounts.root_id
mounts.mount_id
storages.numeric_id
```

#### 修复方案

&emsp;&emsp;这种问题也比较容易修正，一般会提示执行命令 `occ db:convert-filecache-bigint` 来修复。在容器外我们可以采用以下命令执行：

```bash
docker exec -u www-data -ti nextcloud_app_1 php occ db:convert-filecache-bigint
```

## 参考资料

- [How to fix an accidental Nextcloud docker image update](https://nicolasbouliane.com/blog/nextcloud-docker-upgrade-error)
- [Nextcloud 升级后问题解决](https://blog.csdn.net/robin_cai/article/details/119530743)
