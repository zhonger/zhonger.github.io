---
layout: post
title: 'CONQUEST 编译安装指南 ARM 篇'
subtitle: '欢迎进入量子化学的世界'
date: 2021-02-07 20:20:00 +0800
tags: 
- CONQUEST
- 量子化学
- ARM
categories: [tech, conquest]
cover: 'https://images.unsplash.com/photo-1612409578638-b890d0fa9364?w=1600&q=900'
---

## 前言

&emsp;&emsp;随着近年来 AMD、Apple 等科技公司对于 ARM 芯片的研发技术的成熟，以 MacbookPro M1 为代表的 ARM 架构的普通 PC 开始进入市场。其实由于 ARM 的低功耗、高性能的优势，以 AWS、Azure 为首的云服务产商早已经推出了 ARM 服务器。当然，操作系统提供商们也对 ARM 架构的 CPU 进行了支持，比如 Ubuntu Server 就有 ARM 版本。还有像树莓派、路由器等这样的基于 ARM 芯片运行的小平台，都是 ARM 操作系统。截止现在为止，各种常用的软件、依赖库都相继支持 ARM 芯片，使得 ARM 版本的普通 PC、服务器也有了很大的发展势头。

&emsp;&emsp;在去年12月份 MacbookPro M1 发布之后，笔者得到了一台 1台 由实验室购买的 13寸 定制版 MacbookPro M1。刚拿到手的时候，绝大多数的软件还未来得及支持，只有少数大厂进行了支持，比如 Chrome，VS code 开发版，Homebrew。由于想要在 M1 上编译安装 CONQUEST 来进行第一性原理计算，在网络上也没有找到相关资料，所以很是头疼。最开始的时候按照官网给的指南是需要安装 OpenMPI 等一系列依赖库，而笔者在 Mac 平台下习惯使用 Homebrew 来安装软件，一番调查下发现 OpenMPI 还没有发行 big_sur_arm 的安装包，于是无法安装。后来想着 Ubuntu ARM 系统是有 OpenMPI 支持的，就像是不是能运行一个 Ubuntu ARM 的虚拟机，在虚拟机里面编译安装。事实证明这种思路是行得通的，不过比较难搞的就是目前并没有完全支持 M1 的虚拟化软件，只有还在测试版的 Parallel 和 Docker。抱着试一试学一学的态度，我分别使用了这两款软件在 Ubuntu ARM 20.04 上进行了相关的编译安装测试。后来随着 OpenMPI 等依赖库开始支持 big_sur_arm 之后，笔者也在 M1 的物理机上做了相关的测试。以下为 Ubuntu ARM 和 M1 上的编译安装过程。

## Ubuntu ARM

&emsp;&emsp;以下为 CONQUEST 所需的软件或依赖库列表：

| 名称 | 安装包名称 |
| ---- | ---- |
| gcc | gcc |
| fortran | gfortran |
| openmpi | openmpi-bin |
| openmpi library | libopenmpi-dev |
| libxc library | libxc-dev |
| blas library | libblas3 liblas-dev |
| blapack library | liblapack3 liblapack-dev libatlas-base-dev |
| scalapack library | libscalapack-mpi-dev libmlpack-dev |
| fftw3 library| fftw3 fftw3-dev pkg-config |

### 安装依赖

&emsp;&emsp;使用以下命令安装上述软件或者依赖库。

```bash
sudo apt update
sudo apt install -y git build-essential gcc gfortran openmpi-bin
sudo apt install -y libopenmpi-dev libxc-dev
sudo apt install -y libblas3 libblas-dev liblapack3 liblapack-dev libatlas-base-dev
sudo apt install -y libscalapack-mpi-dev libmlpack-dev
sudo apt install -y fftw3 fftw3-dev pkg-config
```

### 编译 CONQUEST

&emsp;&emsp;下载 CONQUEST 最新源代码：

```bash
git clone https://github.com/OrderN/CONQUEST-release conquest
```

&emsp;&emsp;修改 conquest/src/system.make 文件如下所示：

```ini
# For Docker

# Set compilers
FC=mpif90
F77=mpif77

# Linking flags
LINKFLAGS= -L/usr/local/lib
ARFLAGS=

# Compilation flags
COMPFLAGS= -O3 $(XC_COMPFLAGS)
COMPFLAGS_F77= $(COMPFLAGS)

# Set BLAS and LAPACK libraries
# BLAS= -lvecLibFort
BLAS= -lblas -llapack

# Full library call; remove scalapack if using dummy diag module
LIBS= $(FFT_LIB) $(XC_LIB) -lscalapack-openmpi $(BLAS)

# LibXC compatibility (LibXC below) or Conquest XC library

# Conquest XC library
XC_LIBRARY = CQ
XC_LIB =
XC_COMPFLAGS =

# LibXC compatibility
# Choose old LibXC (v2.x) or modern versions
#XC_LIBRARY = LibXC_v2
#XC_LIBRARY = LibXC
#XC_LIB = -lxcf90 -lxc
#XC_COMPFLAGS = -I/usr/include

# Set FFT library
FFT_LIB=-lfftw3
FFT_OBJ=fft_fftw3.o

# Matrix multiplication kernel type
MULT_KERN = default
# Use dummy DiagModule or not
DIAG_DUMMY =
```

&emsp;&emsp;执行编译安装命令：

```bash
cd conquest/src/
make clean && make
```

&emsp;&emsp;执行成功后会在 conquest/bin/ 目录下生成 Conquest 可执行文件，具体使用请见 [使用指南](/tech/conquest-introduction)。

> info "小提示"
> 有一点有意思的事是，在 Ubuntu 平台下可能会出现无法寻找对应的依赖库的问题。解决这一问题比较好的办法是在所使用的 .bashrc 或者 .zshrc 文件里添加完整的 LIBRARY_PATH 和 LD_LIBRARY_PATH 配置。

## M1

### 安装依赖

&emsp;&emsp;M1 平台下的依赖库安装相对比较简单一点，直接使用 Homebrew 和以下命令即可一键式安装所需的所有依赖库和软件。M1 平台下的 Homebrew 的安装请移步 [brew.sh](https://brew.sh/)。

```bash
brew install gcc scalapack openblas liblas lapack open-mpi libxc fftw vecLibFort
```

### 编译 CONQUEST

&emsp;&emsp;下载 CONQUEST 最新源代码：

```bash
git clone https://github.com/OrderN/CONQUEST-release conquest
```

&emsp;&emsp;以下为 M1 平台下对应的 system.make 文件：

```ini
# For Mac M1 aarch64

# Set compilers
FC=mpif90 -std=legacy
F77=mpif77

# Linking flags
LINKFLAGS= -L/usr/local/lib -L/opt/homebrew/lib
ARFLAGS=

# Compilation flags
COMPFLAGS= -O3 $(XC_COMPFLAGS)
COMPFLAGS_F77= $(COMPFLAGS)

# Set BLAS and LAPACK libraries
BLAS= -lvecLibFort

# Full library call; remove scalapack if using dummy diag module
LIBS= $(FFT_LIB) $(XC_LIB) -lscalapack $(BLAS)

# LibXC compatibility (LibXC below) or Conquest XC library

# Conquest XC library
#XC_LIBRARY = CQ
#XC_LIB =
#XC_COMPFLAGS =

# LibXC compatibility
# Choose old LibXC (v2.x) or modern versions
#XC_LIBRARY = LibXC_v2
XC_LIBRARY = LibXC
XC_LIB = -lxcf90 -lxc
#XC_COMPFLAGS = -I/usr/local/include
XC_COMPFLAGS = -I/opt/homebrew/include

# Set FFT library
FFT_LIB=-lfftw3
FFT_OBJ=fft_fftw3.o

# Matrix multiplication kernel type
MULT_KERN = default
# Use dummy DiagModule or not
DIAG_DUMMY =
```

&emsp;&emsp;执行编译安装命令：

```bash
cd conquest/src/
make clean && make
```

&emsp;&emsp;执行成功后会在 conquest/bin/ 目录下生成 Conquest 可执行文件，具体使用请见[使用指南](/tech/conquest-introduction)。
