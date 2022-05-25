---
layout: post
title: 'AiiDA 开源数据管理软件'
subtitle: '用一个开源软件把你计算的数据管起来'
date: 2021-05-12 15:30:00 +0800
categories: [tech, aiida]
author: zhonger
cover: 'https://unsplash.lisz.tk/1606765962248-7ff407b51667.webp'
cover_author: 'Lars Kienle'
cover_author_link: 'https://unsplash.com/@larskienle'
tags: 
- AiiDA
- data management
- calculation
- postgresql
- rabbitmq
---

## 前言

&emsp;&emsp;对于机器学习来说，模型和数据是非常重要的。而模型与数据相比，模型即便是优化得再好，数据不够、不好的话，最终也不能得到一个好的预测结果。因此，我们在使用机器学习方法去建立某个领域模型的同时，也要注意相关原始数据的收集和整理。当我们需要通过庞大的计算量来获取数据的时候，通常可能需要使用大型服务器集群，甚至高性能集群、超算等等。这个时候，即使我们提交的计算在一段时间后得到了结果，恐怕也会是很多个结果文件，我们也很难从这些文件中抽取出我们关心的、想要的某些数据，更难将其整理成可直接用于机器学习的数据格式。

&emsp;&emsp;面对着这些问题，通常我们会想到可以建立一个数据库，再写一些脚本去自动解析文件内容、抽取关键字段和数值，甚至说为了编程可达需要给数据库设计一套 RESTful API 或者 GraphQL API。这样听起来工程量略大，但是一旦做好那么就可以建立类似于 Materias Project 等等那样的专业领域数据库。其实，我们并没有必要从零开始去做这些，因为现在已经有了开源数据管理软件 [AiiDA](https://aiida.readthedocs.io)。

&emsp;&emsp;AiiDA 是一个使用 Python 编写的开源复杂工作流设计和管理框架，旨在帮助从事计算科学（计算材料学，计算生物学等）的相关研究者可以更好地管理、编写、使用和分享复杂的工作流以及计算产生的有用数据。它使得在研究中复杂的计算流程的可重复性得以保证。AiiDA 实现并支持了 ADES 模式的四大基石： (A)utomation（自动）, (D)ata（数据）, (E)nvironment（社区环境）, 和 (S)haring （分享）. AiiDA 支持的一些典型特性包括：

- **工作流**： AiiDA 可以用来创建并执行复杂的、自动文档化的工作流来连接本地和远端计算资源上的多个计算代码。
- **高通量**： AiiDA 的基于事件的工作流引擎支持成百上千（每小时）的带有检查点的计算例程。
- **数据可验证性**： AiiDA 自动追踪所有可验证性图中 (provenance graph) 的输入、输出和元数据，以保证计算的完全可重复性。
- **高级的查询检索特性**： AiiDA 的查询语言支持千万个节点的快速图查询。
- **插件接口**：: AiiDA 可以通过插件来支持各种计算代码，和各种数据分析工具，各种数据类型，任务调度工具以及远程连接方式等 (参见[公共插件库](https://aiidateam.github.io/aiida-registry/))。
- **高性能集群接口**： AiiDA 支持无缝地把你的计算从一个集群转换到另一个集群运行。AiiDA 兼容各种任务调度软件 [SLURM](https://slurm.schedmd.com/), [PBS Pro](https://www.pbspro.org/), [torque](http://www.adaptivecomputing.com/products/torque/), [SGE](http://gridscheduler.sourceforge.net/) 或者 [LSF](https://www.ibm.com/support/knowledgecenter/SSETD4/product_welcome_platform_lsf.html) ，对这些任务调度工具 AiiDA 都是源生支持的。
- **开放科学**： AiiDA 可以将全部或部分的数据库导出，以便于和同行分享，或上传至 [Materials Cloud](https://www.materialscloud.org/) 以便 归档 和 检索 。
- **开源**： AiiDA 通过 [MIT 开源协议](https://aiida.readthedocs.io/projects/aiida-core/zh_CN/latest/intro/LICENSE.txt) 发布。

## 安装

&emsp;&emsp;AiiDA 官网向用户提供了很多种安装方式，其中最简单的就是使用 Docker 一键式安装。这里不仅介绍由 AiiDA 团队构建的 [aiida-team/aiida-core](https://hub.docker.com/r/aiida-team/aiida-core) 镜像，也介绍具有多种集成环境的 [Quantum Mobile](https://hub.docker.com/r/marvelnccr/quantum-mobile) 镜像。除了 Docker 方式外，AiiDA 也可以直接在 Linux/Mac 系统上安装。考虑到 AiiDA 部署在 Linux 服务器操作系统上更为合适，这里就分别介绍使用 root 用户和非 root 用户如何安装 AiiDA 整体环境。

### Docker 安装

#### 单独环境

&emsp;&emsp;使用以下 `docker-compose.yml` 文件和命令 `docker-compose up -d` 即可启动一个 aiida-team/aiida-core 容器实例。

```yaml
# docker-compose.yml
version: '3.9'

services:
  aiida:
    image: aiidateam/aiida-core:1.3.0
    container_name: aiida
    stdin_open: true
    tty: true
    volumes: 
      - ./data:/home/aiida/data
    restart: always
    networks:
       extnetwork:
          ipv4_address: 192.168.18.2

networks:
   extnetwork:
      ipam:
         config:
         - subnet: 192.168.18.0/24
           gateway: 192.168.18.1

```

#### 多软件环境

&emsp;&emsp;使用以下 `docker-compose.yml` 文件和命令 `docker-compose up -d` 即可启动一个 quantum-mobile 容器实例。

```yaml
# docker-compose.yml
version: '3.4'

services:
  quantum-mobile:
    # using the required tag
    image: "marvelnccr/quantum-mobile:20.11.2a"
    container_name: quantum-mobile
    expose:
      - "8888" # AiiDa Lab
      - "8890" # Jupyter Lab
      - "5000" # REST API
      - "22"   # SSH
    ports:
      # local:container
      - "8888:8888"
      - "8890:8890"
      - "22:22"
      - "5000:5000"
    # privileged mode and mounting the cgroup are required for correctly running sytsemd inside the container (set as the default command)
    privileged: true
    volumes:
      - "/sys/fs/cgroup:/sys/fs/cgroup:ro"
    environment:
      LC_ALL: "en_US.UTF-8"
      LANG: "en_US.UTF-8"
    healthcheck:
      # check that the daemon has been started for the 'generic' profile
      # can take a few minutes to start
      test: systemctl is-active --quiet aiida-daemon@generic.service
      interval: 30s
      retries: 6
      start_period: 30s
```

### root 用户安装

&emsp;&emsp;由于 root 用户对系统具有绝对的管理权限，所以使用 root 用户安装 AiiDA 环境时比较简单，可以直接通过 APT 源安装 PostgreSQL、RabbitMQ 和 AiiDA。如下所示，完成这三种软件的安装。

```bash
# AiiDA 是一个 python 编写的软件，所有需要 python 环境和 pip 包管理工具
sudo apt-get install git python3-dev python3-pip

# 安装 PostgreSQL 服务器与客户端命令
sudo apt-get install postgresql postgresql-server-dev-all postgresql-client

# 安装 RabbitMQ 服务器并查询当前状态
sudo apt-get install rabbitmq-server
sudo rabbitmqctl status

# 安装 AiiDA
pip install aiida-core
```

&emsp;&emsp;具体配置 PostgreSQL 数据库和 AiiDA 与下一节中非 root 用户安装中相同，请参照下面内容。

### 非 root 用户安装

&emsp;&emsp;当我们在使用内网服务器时，很大可能我们只是一个普通用户，并没有管理员权限。所以如果想要以一个非 root 用户的身份来安装部署 AiiDA 服务是否也有可能呢？事实上是可以实现的，因为组成 AiiDA 运行环境的三个软件都可以以非 root 用户安装、启动。为了简化安装软件过程，这里我们采用了 [Anaconda](https://www.anaconda.com) 来帮助我们更快、更简单地安装部署环境。（后续，笔者将会为服务器上的 Anaconda 使用特别写一篇文章进行详细介绍，这里默认已安装有 Anaconda。）

```bash
# 启动 Anaconda 环境
~/anaconda3/etc/profile.d/conda.sh
```

#### 安装 PostgreSQL

```bash
# 从 conda-forge 频道安装 PostgreSQL
conda install -c conda-forge postgresql
```

#### 配置和启动 PostgreSQL

```bash
# 创建 PostgreSQL 数据存储目录
# 为了更好地区别是从 conda 安装的 PostgreSQL，特别将存储目录放置在 conda 配置目录下
mkdir -p /home/lisz/.conda/envs/pgsql/data

# 指定数据存储目录并后台启动 PostgreSQL，同时也开启日志记录功能
pg_ctl -D /home/lisz/.conda/envs/pgsql/data -l logfile start

# 查看是否正常启动并监听端口 5432
(base) ➜  data lsof -i:5432 
COMMAND    PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
postgres 33906 lisz    3u  IPv6 66936721      0t0  TCP localhost:postgres (LISTEN)
postgres 33906 lisz    4u  IPv4 66936722      0t0  TCP localhost:postgres (LISTEN)

# 使用当前 Linux 用户身份认证直接进入 PostgreSQL 默认数据库
# 进入后是 PostgreSQL 的 shell 交互界面
psql -d  postgres
```

```sql
# 输入以下命令完成创建用户 aiida、数据库 aiidadb，并给用户赋给该数据库的完全权限
CREATE USER aiida WITH PASSWORD '<password>';
CREATE DATABASE aiidadb OWNER aiida ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE=template0;
GRANT ALL PRIVILEGES ON DATABASE aiidadb to aiida;
```

```bash
# 使用 \q 即可退出刚才的 PostgreSQL 提供的 shell
# 测试 aiida 用户是否可以使用密码从本地成功登录 aiidadb 数据库
psql -h localhost -d aiidadb -U aiida -W
# 输入密码后，出现 PostgreSQL 的 shell 即登录成功
```

#### 安装 RabbitMQ

```bash
# 从 conda-forge 频道安装 RabbitMQ 服务器
conda install -c conda-forge rabbitmq-server
```

#### 配置和启动 RabbitMQ

```bash
# 让 RabbitMQ 使用默认配置在后台启动
rabbitmq-server -detached

# 开启 Web 管理插件
rabbitmq-plugins enable rabbitmq_management

# 查看状态，验证是否正常启动
rabbitmq-server status

# 查看是否正常监听 5672 端口
(base) ➜  ~ lsof -i:5672             
COMMAND    PID USER   FD   TYPE   DEVICE SIZE/OFF NODE NAME
beam.smp 33967 lisz   95u  IPv6 66919827      0t0  TCP *:amqp (LISTEN)
```

&emsp;&emsp;由于 RabbitMQ 是消息队列，这里没有持久化和验证的需求，所有可以直接使用默认配置启动即可。验证正常启动后，可浏览 [http://localhost:15627](http://localhost:15627) 来访问 RabbitMQ 的 Web 界面，默认管理员账号和密码均为 guest。这里需要注意的是，如果是服务器安装，本地机器是需要使用 ssh 代理端口的功能把服务器端的 15627 端口代理到本地的 15627 端口之后才能正常访问。当然，笔者建议使用 VS Code 来远程连接服务器，然后就可以使用 VS Code 提供的界面简单操作代理远程端口到本地。

#### 安装 AiiDA

```bash
# 从 pypi 安装 AiiDA 核心程序
pip install aiida-core

# 如果上述安装过程提示 conda 需要 pathlib 的 error，可以直接安装并重载 AiiDA 配置
conda install pathlib
reentry scan
```

#### 配置和启动 AiiDA

```bash
# 为 AiiDA 配置用户信息、数据库连接信息以及消息队列连接信息
(base) ➜  ~ verdi setup
Info: enter "?" for help
Info: enter "!" to ignore the default and set no value
Profile name: conquest
Email Address (for sharing data): xxxx@xxx.xxx
First name: Ben
Last name: Li
Institution: NIMS
Database engine (postgresql_psycopg2) [postgresql_psycopg2]: 
Database backend (django, sqlalchemy) [django]: 
Database host: localhost
Database port [5432]: 
Database name: aiidadb
Database username: aiida
Database password: 
Broker protocol (amqp, amqps) [amqp]: 
Broker username [guest]: 
Broker password [guest]: 
Broker host [127.0.0.1]: 
Broker port [5672]: 
Broker virtual host name []:        
Repository directory [/home/lisz/.aiida/repository/conquest]:
```

&emsp;&emsp;至此，AiiDA 的所有软件环境就已经完全配置好了，试试觉得也不是那么难哈。

## 验证安装

&emsp;&emsp;AiiDA 的验证安装主要是检查：

- AiiDA 主程序是否在后台正常运行？
- verdi shell 是否能正常使用？
- AiiDA 与数据库、消息队列是否连接正常？

```bash
# verdi daemon status 检查后台情况
# 如果没有启动使用 verdi daemon start 启动
(base) ➜  ~ verdi daemon status
Profile: conquest
Daemon is running as PID 25383 since 2021-05-12 16:06:03
Active workers [1]:
  PID    MEM %    CPU %  started
-----  -------  -------  -------------------
25387     0.02        0  2021-05-12 16:06:03
Use verdi daemon [incr | decr] [num] to increase / decrease the amount of workers

# verdi shell 进入 shell，如果无法进入则证明配置仍然存在错误
(base) ➜  ~ verdi shell
Python 3.8.10 | packaged by conda-forge | (default, May 11 2021, 07:01:05) 
Type 'copyright', 'credits' or 'license' for more information
IPython 7.23.1 -- An enhanced Interactive Python. Type '?' for help.

In [1]: exit()

# verdi status 查看 AiiDA 的各项配置，包括自身及与其他软件之间的连接
(base) ➜  ~ verdi status
 ✔ config dir:  /home/lisz/.aiida
 ✔ profile:     On profile conquest
 ✔ repository:  /home/lisz/.aiida/repository/conquest
 ✔ postgres:    Connected as aiida@localhost:5432
 ✔ rabbitmq:    Connected as amqp://guest:guest@127.0.0.1:5672?heartbeat=600
 ✔ daemon:      Daemon is running as PID 25383 since 2021-05-12 16:06:03
```

## 后续使用

&emsp;&emsp;当我们已经有了 AiiDA 的完整环境之后，我们就会想要知道该如何使用 AiiDA 为计算服务呢。由于笔者是做第一性原理计算和机器学习的研究，所以后续将以 AiiDA 和 CONQUEST 的搭配使用为实例来介绍 AiiDA 的数据管理用法。

## 参考资料

- [AiiDA 官网中文文档](https://aiida.readthedocs.io/projects/aiida-core/zh_CN/latest/intro/installation.html#installing-the-aiida-core-package)
- [Conda 安装 PostgreSQL 数据库](https://blog.csdn.net/r_nznf/article/details/108056919)
- [离线安装 RabbitMQ](https://segmentfault.com/a/1190000010480589)
- [RabbitMQ 后台启动以及关闭](https://blog.csdn.net/yufanghu/article/details/80829108)
