---
layout: post
title: Nextcloud 源码部署迁移到容器部署
subtitle: LNMPA 源码部署通常不便于更新，迁移到容器部署倒是个不错的法子
date: 2018-06-11 12:46:00 +0800
tags:
- Nextcloud
- docker
- lnmpa
- 云盘
categories: [tech, docker]
cover: 'https://images.unsplash.com/photo-1509226704106-8a5a71ffbfa4?w=1600&h=900'
---

&emsp;&emsp;在以前我们部署 Nextcloud 都是采用 LNMPA 架构和源码来直接部署，到版本升级时一般都需要比较复杂的操作，虽然也还算比较可以接受，但是相比较 Docker 方式而言，这就显得复杂多了，而且还对宿主机的环境还有所要求。因此，今天就来尝试一下从源码部署迁移到容器部署。

## 备份数据

&emsp;&emsp;源码部署方式需要管理员时常备份的数据主要是 Mysql 数据库、程序配置文件 config.php、存储数据三部分，而迁移到 Docker 部署也是需要这三部分即可。

&emsp;&emsp;对于 Docker 方式部署来说，存储数据文件夹只需要在启动应用时挂载目录到容器应用的对应目录即可，因此无需做任何更改。

&emsp;&emsp;由于配置文件 config/config.php 文件会在 Docker 应用创建是重新生成，只需保证文件中重要部分相同即可。

&emsp;&emsp;所以只需备份数据库。

### 备份数据库

#### 从 phpMyadmin 中备份

&emsp;&emsp;这种方式只需要在数据库中选中**导出**功能，并且将 sql 文件保存到服务器本地目录即可。

#### 从命令行备份

&emsp;&emsp;这种方式需要登录服务器操作（如果开放对外访问，那也可在远程操作）。
```bash
# 服务器本地操作
mysqldump -u root -p yun > ~/yun.sql
# 文件导出到本地用户主目录
```

## 恢复数据

&emsp;&emsp;默认服务器已安装 docker-ce 和 docker-compose 工具。

### 启动容器

&emsp;&emsp;首先在 /home/ubuntu/nextcloud 目录下编写如下 docker-compose.yml 文件。
```yaml
version: '2'

services:
  db:
    image: mariadb
    restart: always
    volumes:
      - ./db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_PASSWORD=nextcloud
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    image: nextcloud
    ports:
      - 7009:80
    links:
      - db
    volumes:
      - ./www:/var/www/html
      - /home/data/:/var/www/html/data
    restart: always
```
使用 `docker-compose up -d` 启动应用。由于数据库和应用配置尚未恢复，此时无法在浏览器上通过`http://127.0.0.1:7009`访问。
### 恢复数据库

```bash
# 拷贝数据库备份至容器应用中
docker cp /home/ubuntu/yun.sql nextcloud_db_1:/opt/yun.sql

# 导入数据库
mysql -u root -p
# 输入密码 nextcloud

mysql> use nextcloud;
mysql> source /opt/yun.sql

# 导入需要一段时间，稍加等待一下即可
```

### 恢复应用配置

&emsp;&emsp;数据库恢复完成之后，由于应用配置尚未配置，此时访问会要求应用重新安装一次，其实已经没有再次安装的必要了。

&emsp;&emsp;通过拷贝旧配置中的内容即可初始化容器应用，主要内容如下所示：

```yaml
  'passwordsalt' => '一大串文本',
  'secret' => '一大串文本',
  'datadirectory' => '/var/www/html/data',
  'overwrite.cli.url' => 'http://127.0.0.1:7009',
  'dbtype' => 'mysql',
  'version' => '13.0.3.2',
  'dbname' => 'nextcloud',
  'dbhost' => 'db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'dbuser' => 'nextcloud',
  'dbpassword' => 'nextcloud',
  'installed' => true,
  'theme' => '',
  'loglevel' => 0,
  'maintenance' => false,
```

&emsp;&emsp;其中主要包含**数据库配置**、**应用是否安装标志位**、**关闭维护模式**等。

&emsp;&emsp;这一步完成之后，浏览器中可以正常访问到应用界面。

&emsp;&emsp;不过，如果源码部署的应用版本与 Docker 镜像的应用版本不符时（通常是落后），还需要执行以下命令先升级某些插件之后才能正常访问：

```bash
docker exec -u www-data -ti nextcloud_app_1 php occ upgrade
```

&emsp;&emsp;当升级插件完成后，就可以正常使用 Docker 部署的 Nextcloud 了。