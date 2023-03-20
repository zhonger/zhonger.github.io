---
layout: post
title: 'Modules 配置之 Python'
subtitle: '利用 Modules 动态管理集群中的 Python 环境'
date: 2023-03-20 12:48:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://i.lisz.top/cover/7QqYtI.webp'
cover_author: 'Joshua ten Have'
cover_author_link: 'https://unsplash.com/@joshuatenhave'
tags:  
- Linux
- Modules
- Python
- 软件环境
---

## 前言

&emsp;&emsp;近年来得益于其轻量、易学易用、第三方支持依赖库多的特点，Python 语言大量被用于机器学习相关的研究、项目开发。在学术界，有以 [Scikit-Learn](https://scikit-learn.org) 为代表的全能机器学习库；在产业界，有以 [TensorFlow](https://www.tensorflow.org)、[PyTorch](https://pytorch.org) 为代表的生产级机器学习模型计算框架。（当然，学术界实际上构建大规模深度学习模型时也会用到 PyTorch 等计算框架。）但对于大多数人来说，学习这些库、框架或者借助它们从事某些研究、项目开发时，可能还是在用自己的笔记本、台式机。哪怕是在高校的实验室里，这种事情也是屡见不鲜。因此，有交互界面、相对容易上手的 [Anaconda](https://www.anaconda.com) 可能会作为大家管理 Python 环境的首选。

&emsp;&emsp;当我们在用 Python 编写一些代码，而代码一次运行不可能在短短几秒、几分钟内得到结果时，将任务提交给高性能工作站或者集群作业系统就显得格外有效。尤其是当应用规模较大、计算迭代次数较多时，非交互式的作业提交方式会变得更加有利。毕竟如果是用自己的笔记本运行着这么大的计算，资源基本上都被计算占用了，根本没办法用笔记本去干点别的事情。甚至说，计算还会使得 CPU 等核心部件温度上升，从而影响计算性能。这样比较下来，不得不说提交任务给高性能工作站或者集群作业系统是多么明智的选择。

&emsp;&emsp;其实，Anaconda 在没有交互界面的服务器操作系统上也还是可以使用的，我们可以使用其免费的精简版 ------ [miniconda](https://conda.io/miniconda)。虽然 miniconda 已经是精简版了，但和原生 Python 环境比起来还是要多不少东西的。从高性能计算环境的角度来看，使用 Modules 直接管理 Python 环境实际上更加贴近原生，也更加有利于用户与其他环境搭配使用。比如说安装  Python 的 MPI 支持库 ------ MPI4PY，仅需要通过 Modules 管理工具加载 Python 和 MPI 两个基础环境，使用 `pip3 install mpi4py` 命令即可安装。

## 实践

&emsp;&emsp;将 Python 环境纳入 Modules 管理的步骤就是两步：第一步，编译源代码及安装；第二步，添加 Modules 配置文件。当然，最开始还是需要确认一下编译环境是否完备以及文件夹是否准备好。

### 环境及文件夹准备

```bash
# 安装编译环境
sudo apt install -y build-essential libbz2-dev libdb-dev \
  libreadline-dev libffi-dev libgdbm-dev liblzma-dev \
  libncursesw5-dev libsqlite3-dev libssl-dev \
  zlib1g-dev uuid-dev tk-dev wget
  
# 准备文件夹
sudo mkdir -p /opt/python/3.10.6
```

### 编译及安装

```bash
# 下载源代码
cd /tmp
wget -c https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tar.xz

# 解压源代码
tar xf Python-3.10.6.tar.xz

# 配置安装路径及编译选项
cd Python-3.10.6
./configure --prefix=/opt/python/3.10.6 --enable-optimizations --with-lto 

# 编译及安装
make && sudo make install
```

### 配置 Modules

```bash
sudo mkdir -p /opt/modules/modulefiles/py
sudo vim /opt/modules/modulefiles/py/3.10.6
```

&emsp;&emsp;首先如上命令准备文件夹，并新建 module 配置文件，内容如下：

```bash
#%Module
proc ModulesHelp { } {
    puts stderr \tThis module file will load Python 3.10.6"
}

module-whatis  "Enable Python 3.10.6"

eval set  [ array get env HOME ]
set basedir /opt/python/3.10.6
prepend-path PATH "${basedir}/bin"
prepend-path LIBRARY_PATH "${basedir}/lib"
prepend-path LD_LIBRARY_PATH "${basedir}/lib"
prepend-path INCLUDE_PATH "${basedir}/include"
prepend-path LD_INCLUDE_PATH "${basedir}/include"
```

### 验证

```bash
# 查看所有可用模块
╰─$ module ava
-------------------------- /opt/modules/modulefiles ---------------------------
dot  module-git  module-info  modules  null  py/3.10.6  use.own

Key:
modulepath
```

```bash
# 加载 python 3.10.6 环境，并确认已加载模块
╰─$ module load py/3.10.6
╰─$ module list
Currently Loaded Modulefiles:
 1) py/3.10.6
```

```bash
# 确认目前 python 版本
╰─$ python3 -V
Python 3.10.6
```

### 使用

&emsp;&emsp;由于以上操作将 Python 3.10.6 安装到了一个系统文件夹中，编译完成后会出现如下警告提示。不过无须担心，普通用户可以通过 venv 虚拟环境工具正常使用。

```bash
Installing collected packages: setuptools, pip
  WARNING: The scripts pip3 and pip3.10 are installed in '/opt/python/3.10.6/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed pip-22.2.1 setuptools-63.2.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
```

&emsp;&emsp;如下所示，当已经如**验证**部分加载好 python 3.10.6 模块后，使用以下命令新建虚拟环境、激活后即可使用。

> info "小提示"
> &emsp;&emsp; 新建虚拟环境时最后的参数 env 是指虚拟环境的名字，我们可以取任意符合 python 规则的字符串作为虚拟环境名字。值得注意的是，python 虚拟环境有关的文件将会被安装在命令执行的当前目录下的同名文件夹中。为了便于管理和使用，建议将所有的 python 虚拟环境都放置在同一目录下。

```bash
# 新建 env 虚拟环境
╰─$ python3 -m venv env

# 激活 env 虚拟环境
╰─$ source env/bin/activate

# 可以看到 <env> 的环境提示
# 尝试升级 pip，可以看到成功升级 
╭─zhonger@lep-u ~ ‹env›
╰─$ pip3 install -U pip
Requirement already satisfied: pip in ./env/lib/python3.10/site-packages (22.2.1)
Collecting pip
  Using cached pip-23.0.1-py3-none-any.whl (2.1 MB)
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 22.2.1
    Uninstalling pip-22.2.1:
      Successfully uninstalled pip-22.2.1
Successfully installed pip-23.0.1

# 取消激活 env 虚拟环境
╰─$ deactivate
```

## 有趣的问题

&emsp;&emsp;如果使用 module 提供的 python 模块创建了虚拟环境后，实际运行虚拟环境时还需要使用 module 加载 python 模块吗？答案是**不需要**。虚拟环境的本质是拷贝运行相同命令所需的必要文件，如下对比查看一下 python 模块和 env 虚拟环境的顶级目录。可以发现，两者的差别不是很大。env 虚拟环境少了 share 目录，多了 pyvenv.cfg 文件。查看该文件可知，存在与 python 模块之间的关系的声明。再查看 bin 目录，可以看到 python 可执行命令用了链接的方式，pip 命令则是直接从原来的 python 模块复制过来的。于是，这就能允许普通用户自行管理  pip 命令和 python 库了。

```bash
╰─$ ls /opt/python/3.10.6
bin  include  lib  share

╰─$ ls env
bin  include  lib  lib64  pyvenv.cfg

╰─$ cat env/pyvenv.cfg
home = /opt/python/3.10.6/bin
include-system-site-packages = false
version = 3.10.6

╰─$ ll env/bin
total 36K
-rw-r--r-- 1 zhonger zhonger 8.9K Mar 20 15:20 Activate.ps1
-rw-r--r-- 1 zhonger zhonger 2.0K Mar 20 15:20 activate
-rw-r--r-- 1 zhonger zhonger  908 Mar 20 15:20 activate.csh
-rw-r--r-- 1 zhonger zhonger 2.1K Mar 20 15:20 activate.fish
-rwxrwxr-x 1 zhonger zhonger  234 Mar 20 15:20 pip
-rwxrwxr-x 1 zhonger zhonger  234 Mar 20 15:20 pip3
-rwxrwxr-x 1 zhonger zhonger  234 Mar 20 15:20 pip3.10
lrwxrwxrwx 1 zhonger zhonger    7 Mar 20 15:20 python -> python3
lrwxrwxrwx 1 zhonger zhonger   30 Mar 20 15:20 python3 -> /opt/python/3.10.6/bin/python3
lrwxrwxrwx 1 zhonger zhonger    7 Mar 20 15:20 python3.10 -> python3
```

## 参考资料

- [Python 官方文档 - 构建 Python](https://docs.python.org/zh-cn/3/using/unix.html#building-python)
- [Python 官方文档 - 性能选项](https://docs.python.org/zh-cn/3/using/configure.html#configure-options)
- [Python 官方文档 - 虚拟环境和包](https://docs.python.org/zh-cn/3/tutorial/venv.html)
- [Ubuntu 環境の Python](https://www.python.jp/install/ubuntu/index.html)
