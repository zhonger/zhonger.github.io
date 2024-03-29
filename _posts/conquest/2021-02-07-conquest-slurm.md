---
layout: post
title: 'CONQUEST 编译安装指南 Slurm 篇'
subtitle: '欢迎使用作业任务管理的方式运行多个 CONQUEST 任务'
date: 2021-02-07 20:24:00 +0800
categories: [tech, conquest, docker]
author: zhonger
cover: 'https://i.lisz.top/cover/p9XKnc.webp'
cover_author: 'Fabrizio Conti'
cover_author_link: 'https://unsplash.com/@conti_photos'
tags: 
- CONQUEST
- 量子化学
- Slurm
---

## 前言

&emsp;&emsp;在实际的生产环境中，使用单用户模式直接运行命令的机会不是很多，通常是采用提交作业任务给集群计算的方式。这样一来既能节约资源和时间，又能申请到更大规模的计算资源，对于平台管理人员还是用户来说都是非常有利的。国家超算中心，地方超算中心，学校超算中心一般都对外提供这样的服务，不过需要按核时进行计费。所谓“核时”就是一个 CPU 核运行一个小时，这也是高性能计算中通常使用的资源衡量单位。作为超算中心或者高性能集群，必不可缺的就是集群作业管理系统，它可以根据用户的需求，统一管理和调度集群的软硬件资源，保证用户作业公平合理地共享集群资源，提高系统利用率和吞吐率。

&emsp;&emsp;我们常见的集群作业管理系统有 PBS、LSF 和 Slurm等。其中，笔者在超算中心、研究所高性能计算集群中接触比较多的就是 PBS 作业管理系统。但是如果自己在单节点高性能计算服务器上部署 PBS 可能有点麻烦。现今市面上比较流行的 PBS 作业管理系统主要就是 Torque 和 OpenPBS 两家，前者需要购买授权才能使用，后者属于开源产品可以免费使用。笔者在初期也尝试过安装 OpenPBS，不过由于安装依赖多，确实莫名其妙的错误也比较多。根据网上资料发现 CentOS 安装 OpenPBS 比较方便，而 Ubuntu 安装 OpenPBS 就麻烦很多甚至极难成功。不过还有一点，由于 CentOS 最大的支持者 Redhat 撤资，现在 CentOS 8 即将失去维护转而推广使用 CentOS Stream，因此 Ubuntu 操作系统上安装 OpenPBS 显得更有意义。为了又想在 Ubuntu 上用 OpenPBS 熟悉的方式，又想安装简单一点，笔者尝试了一种曲线实现的方式------安装 Slurm 和 PBS 工具。这样一来，表面上我们仍然可以使用 PBS 中常用的脚本文件和相关命令，而实际上管理和执行任务的作业管理系统则是 Slurm。

## PBS 简介

&emsp;&emsp;PBS （Protable Batch System） 作业管理系统会根据一个集群上的可用计算节点的计算资源管理和调度所有计算作业（无论是批处理作业还是交互式作业）。

### PBS 常用命令

#### 作业控制

- qsub：提交作业
- qdel：取消作业
- qsig：给作业发送信号
- qhold：挂起作业
- qrls：释放挂起的作业
- qrerun：重新运行作业
- qmove：将作业移动到另一个队列
- qalter： 更改作业资源属性

#### 作业监测

- qstat：显示作业状态
- showq： 查看所有作业

#### 节点状态

- pbsnodes：列出集群中所有节点的状态和属性

### PBS 作业属性

可以用两种方式设置 PBS 作业属性：

- 通过命令行参数传递给 qsub 命令；
- 在 PBS 脚本中以 #PBS 方式指定。

下表列出常用的 PBS 作业属性

| 属性 | 取值 | 说明 |
| ----- |----- |----- |
| -l | 以逗号分隔的资源列表 | 设定作业所需资源 |
| -N | 作业名称 | 设定作业名称 |
| -o | 文件路径 | 设定作业的标准输出文件路径 |
| -e | 文件路径 | 设定作业的标准错误文件路径 |
| -p | -1024 到 +1023 之间的整数 | 设定作业优先级，越大优先级越高 |
| -q | 队列名称 | 设定作业队列名称 |

比较常用的作业资源如下：

| 资源 | 取值 | 说明 |
| ----- |----- |----- |
| nodes | 节点资源构型 | 设定作业所需计算节点资源 |
| walltime | hh:mm:ss | 设定作业所需的最大 wallclock 时间 |
| cput | hh:mm:ss | 设定作业所需的最大 CPU 时间 |
| mem | 正整数，后面可跟 b，kb，mb，gb | 设定作业所需的最大内存 |
| ncpus | 正整数 | 设定作业所需的 CPU 数目 |

### PBS 脚本

&emsp;&emsp;PBS 脚本本质上是一个 Linux shell 脚本，在 PBS 脚本中可以用一种特殊形式的注释（#PBS）作为 PBS 指令以设定作业属性。下面是一个 Li 计算的 PBS 脚本示例 (run_CQ_GridCutoff.csh)：

```bash
#!/bin/bash

#PBS -l walltime=06:00:00

##PBS -l select=1:ncpus=1:mpiprocs=1
#PBS -l nodes=workq:ppn=2

#PBS -N t_Li_GridCutoff

set echo

set HOMEDIR=$PBS_O_WORKDIR
cd $HOMEDIR

echo "HOMEDIR: $HOMEDIR"
echo "We are in "

pwd

cp Conquest_input_Li Conquest_input

cq(){
    sed -i "30c Grid.GridCutoff $i" Conquest_input
    mpirun /opt/softwares/conquest/bin/Conquest < Conquest_input > Conquest_out
    cp Conquest_input Conquest_input_Li_$i
    mv Conquest_out Conquest_out_Li_$i
}

let i="75"

for i in $(seq 75 25 250)
do
    echo "Now the Grid.GridCutoff is " $i
    cq
done

unset echo
```

## Slurm 简介与安装

&emsp;&emsp;Slurm 任务调度工具（前身为极简 Linux 资源管理工具，英文：Simple Linux Utility for Resource Management，取首字母，简写为 SLURM），或 Slurm，是一个用于 Linux 和 Unix 内核系统的免费、开源的任务调度工具，被世界范围内的超级计算机和计算机群广泛采用。它提供了三个关键功能。第一，为用户分配一定时间的专享或非专享的资源(计算机节点)，以供用户执行工作。第二，它提供了一个框架，用于启动、执行、监测在节点上运行着的任务(通常是并行的任务，例如 MPI)。第三，为任务队列合理地分配资源。

&emsp;&emsp;大约 60％ 的 500 强超级计算机上都运行着 Slurm，包括 2016 年前世界上最快的计算机天河-2。

&emsp;&emsp;Slurm 使用基于 Hilbert 曲线调度或肥胖网络拓扑结构的最适算法，以便优化并行计算机中的任务分配。

### Slurm 常用命令

下面是一些最常用的 SLURM 命令：

- sacct：查看历史作业信息
- salloc：分配资源
- sbatch：提交批处理作业
- scancel：取消作业
- scontrol：系统控制
- sinfo：查看节点与分区状态
- squeue：查看队列状态
- srun：执行作业

### 资源管理系统实体

Slurm 资源管理系统的管理对象包括：节点，分区，作业和作业步。

- 节点：Node
  - 即指计算节点
  - 包含处理器、内存、磁盘空间等资源
  - 具有空闲、分配、故障等状态
  - 使用节点名字标识

- 分区：Partition
  - 节点的逻辑分组
  - 提供一种管理机制，可设置资源限制、访问权限、优先级等
  - 分区可重叠，提供类似于队列的功能
  - 使用分区名字标识

- 作业：Job
  - 一次资源分配
  - 位于一个分区中，作业不能跨分区
  - 排队调度后分配资源运行
  - 通过作业 ID 标识

- 作业步：Jobstep
  - 通过 srun 进行的任务加载
  - 作业步可只使用作业中的部分节点
  - 一个作业可包含多个作业步，可并发运行
  - 在作业内通过作业步 ID 标识

### 作业运行模式

&emsp;&emsp;Slurm 系统有三种作业运行模式：

- 交互模式，以 srun 命令运行；
- 批处理模式，以 sbatch 命令运行；
- 分配模式，以 salloc 命令运行。

&emsp;&emsp;想要了解更多相关内容请移步至参考资料1。

### Ubuntu 上安装

&emsp;&emsp;安装 Munge、Slurm 和 PBS 工具，并清理、新建和赋权 slurm 所需文件夹。

```bash
sudo apt update \
&& sudo apt install munge slurm-wlm slurm-wlm-doc slurm-wlm-torque -y \
&& sudo rm -rf  /var/spool/slurm-llnl \
&& sudo mkdir /var/spool/slurm-llnl \
&& sudo chown -R slurm.slurm /var/spool/slurm-llnl \
&& sudo rm -rf /var/run/slurm-llnl/ \
&& sudo mkdir /var/run/slurm-llnl/ \
&& sudo chown -R slurm.slurm /var/run/slurm-llnl/
```

&emsp;&emsp;修改 Slurm 配置文件 /etc/slurm-llnl/slurm.conf，本配置文件配置控制节点的主机名为 workq（可根据实际进行修改，如与实际不一致 Slurm 主服务会启动不了），配置单用户可提交多个任务同时进行，并取消了资源使用的限制。另外，最后计算节点的定义字节中需对节点名称、CPU 核数进行修改。

```ini
# slurm.conf file generated by configurator easy.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ControlMachine=workq
#ControlAddr=
#
#MailProg=/bin/mail
MpiDefault=none
#MpiParams=ports=#-#
ProctrackType=proctrack/pgid
ReturnToService=1
SlurmctldPidFile=/var/run/slurm-llnl/slurmctld.pid
#SlurmctldPort=6817
SlurmdPidFile=/var/run/slurm-llnl/slurmd.pid
#SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
#SlurmdUser=root
StateSaveLocation=/var/spool/slurm-llnl
SwitchType=switch/none
TaskPlugin=task/none
#
#
# TIMERS
#KillWait=30
#MinJobAge=300
#SlurmctldTimeout=120
#SlurmdTimeout=300
#
#
# SCHEDULING
FastSchedule=1
#SchedulerType=sched/backfill
#SelectType=select/linear
SelectType=select/cons_res
SelectTypeParameters=CR_CPU
#
#
# LOGGING AND ACCOUNTING
AccountingStorageType=accounting_storage/none
ClusterName=cluster
#JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
#SlurmctldDebug=3
#SlurmctldLogFile=
#SlurmdDebug=3
#SlurmdLogFile=
#
#
# COMPUTE NODES
NodeName=workq CPUs=128 State=UNKNOWN
PartitionName=cpu Nodes=workq Default=YES MaxTime=INFINITE State=UP
```

&emsp;&emsp;重启有关服务使配置生效。Munge 为 Slurm 所必需的服务，需要首先启动。slurmctld 是管理控制模块，slurmd 是计算模块，启动先后无实际影响。

```bash
sudo service munge restart \
&& sudo service slurmctld restart \
&& sudo service slurmd restart
```

&emsp;&emsp;经过以上步骤就安装完成了，可以分别通过以下两个命令 sinfo 和 pbsnodes 来验证是否安装成功。

```bash
sinfo # slurm 查看节点命令

PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
cpu*         up   infinite      1   idle workq

pbsnodes # pbs 查看节点命令

workq
    state = free
    np = 128
    ntype = cluster
    status = rectime=1612757114,state=free,slurmstate=idle,size=0kb:0kb,ncpus=128,boards=1,sockets=2,cores=64,threads=1,availmem=1mb,opsys=linux 4.18.0-25-generic #26~18.04.1-ubuntu smp thu jun 27 07:28:31 utc 2019,arch=x86_64

```

### Docker 化

&emsp;&emsp;Docker 化服务已经成为现在最为流行的应用部署方式之一。Docker 能提供一键式的应用部署方式，给用户免去了大量的麻烦，与已有的虚拟机镜像化相比，其在镜像大小、镜像获取方式、镜像获取速度、支持平台上都有得天独厚的优势。虚拟机化软件不仅受限于平台支持和 License 版权限制，还会因为专用化软件的虚拟化镜像十分庞大，多达十几个 G，下载速度也受限于下载提供方。而 Docker 可以将镜像推送到 Docker Hub，再由 Docker Hub 进行镜像分发，其下载速度一般都是满速。而且从 Docker 镜像启动一个 Docker 实例也是非常简单，一行命令即可。使用时也只需要使用 Docker 提供的方式连入或者使用 ssh 方式，方便快捷。以下为 Slurm 的 Docker 化编译文件 Dockerfile：

```dockerfile
FROM zhonger/conquest:1.0.6

LABEL maintainer="zhonger zhonger@live.cn"

# Install munge & slurm
RUN sudo apt update \
    && sudo apt install munge slurm-wlm slurm-wlm-doc slurm-wlm-torque -y \
    && sudo rm -rf  /var/spool/slurm-llnl \
    && sudo mkdir /var/spool/slurm-llnl \
    && sudo chown -R slurm.slurm /var/spool/slurm-llnl \
    && sudo rm -rf /var/run/slurm-llnl/ \
    && sudo mkdir /var/run/slurm-llnl/ \
    && sudo chown -R slurm.slurm /var/run/slurm-llnl/

COPY slurm.conf /etc/slurm-llnl/slurm.conf

RUN sudo service munge restart \
    && sudo service slurmd restart \
    && sudo service slurmctld restart

# Clean apt-cache
RUN sudo apt autoremove -y \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

&emsp;&emsp;其中所需的 slurm.conf 文件如上一节中所示， entrypoint.sh 文件如下所示：

```bash
#!/bin/bash

sudo service munge restart
sudo service slurmctld restart
sudo service slurmd restart
sinfo

/bin/zsh
```

&emsp;&emsp;使用以下命令编译生成 Docker 镜像：

```bash
docker build . -t zhonger/conquest:slurm
```

&emsp;&emsp;使用以下命令启动一个实例：

```bash
docker run -ti -d -h workq -v /home/ubuntu/test:/home/ubuntu/test --name dev zhonger/conquest:slurm
```

&emsp;&emsp;这里需要注意的是，一定要添加 -h workq 来为启动的实例指定主机名，否则实例将无法正常启动 Slurm 模块。这里也给出一个等同的 docker-compose.yml 文件。

```yaml
version: "3.9"
services:

  conquest:
    image: zhonger/conquest:slurm
    hostname: "workq"
    container_name: dev2
    stdin_open: true
    tty: true
    volumes:
     - ~/web/test:/home/ubuntu/test
    restart: always
```

## 参考资料

- [PBS LSF 作业管理系统 SLURM 资源管理系统](https://www.cnblogs.com/bio-mary/p/13500255.html)
- [Slurm工作调度工具](https://zh.wikipedia.org/wiki/Slurm工作调度工具)
  