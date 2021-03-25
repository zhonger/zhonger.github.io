---
layout: post
title: 'CONQUEST 编译安装指南 Intel 篇'
subtitle: '欢迎进入量子化学的世界'
date: 2021-02-07 20:22:00 +0800
tags: 
- CONQUEST
- 量子化学
- Intel
categories: [tech, conquest]
cover: 'https://images.unsplash.com/photo-1611908494970-3eea5e0a773e?w=1600&q=900'
---

## 前言

&emsp;&emsp;虽然笔者写过 ARM 比 Intel CPU 要有低功耗、高性能等优势，但是目前来说 Intel 芯片仍然是主流，毕竟大部分实验室所使用的服务器、工作站以及个人普通 PC 基本上都是 Intel 芯片。在 Intel 平台我们可能对于软件和依赖库的支持不需要太担心，正常来说不管 Linux 或者 Unix 系统都会有。这里笔者采用 Ubuntu Server 20.04 来举例介绍 Intel 平台下 CONQUEST 的编译安装。

## Ubuntu

&emsp;&emsp;OpenMPI 是 CONQUEST 所必需的依赖环境，虽然说 Ubuntu 的软件源中也有最新的版本发行，但是为了进一步统一之后编译安装过程中的依赖库地址，这里选择从源代码开始编译安装 OpenMPI。下面的 FFTW 依赖库也是如此。另外，blas、lapack、scalapack 也是 CONQUEST 要求的依赖库，但是为了与 ARM 篇中的形成一个对比，这里采用了 Intel 科学计算库 MKL 中的相应依赖库来尝试加速计算。

&emsp;&emsp;在正式安装前，需要先预先安装好所需的基础环境：

```bash
sudo apt update && sudo apt install -y wget build-essential apt gnupg gfortran
```

### 安装 OpenMPI

```bash
sudo mkdir -p /opt/softwares /opt/openmpi 
sudo chown -R ubuntu:ubuntu /opt/openmpi /opt/softwares

cd /opt/softwares \
&& wget -c https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.gz \
&& tar zxvf openmpi-4.1.0.tar.gz \
&& cd openmpi-4.1.0 \
&& ./configure --prefix=/opt/openmpi \
&& make -j 128 \
&& make install
```

### 安装 FFTW3

```bash
sudo mkdir -p  /opt/fftw3
sudo chown -R ubuntu:ubuntu /opt/fftw3

cd /opt/softwares \
&& wget -c http://www.fftw.org/fftw-3.3.9.tar.gz \
&& tar zxvf fftw-3.3.9.tar.gz \
&& cd fftw-3.3.9 \
&& ./configure --prefix=/opt/fftw3 \
&& make -j 128 \
&& make install
```

### 安装 MKL

注意此处使用的 bash 配置 PATH，如果是 zsh 请对应修改 为 .zshrc。

```bash
echo "export PATH=/opt/openmpi/bin:/opt/fftw3/bin:$PATH" >> ~/.bashrc \
&& echo "export MKLROOT=/opt/intel/compilers_and_libraries_2020.4.304/linux/mkl" >> ~/.bashrc \
&& echo "export LD_LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:$LD_LIBRARY_PATH" >> ~/.bashrc \
&& echo "export LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:$LIBRARY_PATH" >> ~/.bashrc \
&& source ~/.bashrc

cd /tmp
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
sudo wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list
sudo apt update
sudo apt install -y intel-mkl-2020.4-912
```

#### 如果遇到 E: Sub-process /usr/bin/dpkg returned an error code (1)，怎么办？

```bash
cd /var/lib/dpkg/
sudo mv info/ info_bak          # 现将info文件夹更名
sudo mkdir info                 # 再新建一个新的info文件夹
sudo apt-get update             # 更新
sudo apt-get -f install         # 修复
sudo mv info/* info_bak/        # 执行完上一步操作后会在新的info文件夹下生成一些文件，现将这些文件全部移到info_bak文件夹下
sudo rm -rf info                # 把自己新建的info文件夹删掉
sudo mv info_bak info           # 把以前的info文件夹重新改回名
```

### 编译安装 CONQUEST



下载 CONQUEST 最新源代码：

```bash
cd /opt/softwares/
git clone https://github.com/OrderN/CONQUEST-release conquest
```

修改 conquest/src/system.make 文件如下所示：

```bash
# For Docker (2021/01/27 zhonger)

# Set compilers
FC=mpif90
F77=mpif77

# Linking flags
LINKFLAGS = -L$(MKLROOT)/lib/intel64 $(MKLROOT)/lib/intel64/libmkl_blacs_openmpi_lp64.a $(MKLROOT)/lib/intel64/libmkl_lapack95_lp64.a -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lmkl_blacs_openmpi_lp64  -lpthread -lm
#LINKFLAGS= -L/usr/local/lib
ARFLAGS=

# Compilation flags
COMPFLAGS= -I$(MKLROOT)/include/intel64/lp64 -I$(MKLROOT)/include
#COMPFLAGS= -O3 $(XC_COMPFLAGS)
COMPFLAGS_F77= $(COMPFLAGS)

# Set BLAS and LAPACK libraries
#BLAS= -lvecLibFort

# Full library call; remove scalapack if using dummy diag module
LIBS= $(FFT_LIB) $(XC_LIB) $(BLAS)
#LIBS= $(FFT_LIB) $(XC_LIB) -lscalapack $(BLAS)

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
#XC_COMPFLAGS = -I/usr/local/include

# Set FFT library
FFT_LIB= -L/opt/fftw3/lib/ -lfftw3
#FFT_LIB=-lfftw3
FFT_OBJ=fft_fftw3.o

# Matrix multiplication kernel type
MULT_KERN = default
# Use dummy DiagModule or not
DIAG_DUMMY =
```


#### 编译错误解决

**编译错误：**generic_blas.o: in function `__genblas_MOD_two_potri':......

**解决办法：**修改 conquest/src/Makefile 文件，如下修改。这里发生编译错误的原因是编译程序如果按照原来的顺序无法寻找到 MKL 提供的依赖库文件，相反将链接依赖库文件的顺序放到后面编译程序就能成功找到依赖库文件。这么听起来有点玄学，但事实就是这样的。

```bash
# 第68行
$(FC) $(LINKFLAGS) -o $(TARGET) $(NODE_OBJECTS) $(LIBS)

# 修改为
$(FC) -o $(TARGET) $(NODE_OBJECTS) $(LIBS) $(LINKFLAGS)
```

## Docker 化

以下为 Docker 化所需的 Dockerfile 文件（基于笔者个性化后的 Intel 官方 Docker 镜像）：

```bash
FROM zhonger/oneapi-hpckit:latest

LABEL maintainer="zhonger zhonger@live.cn"

# Install open-mpi
RUN sudo apt update \
    && sudo apt install -y wget \
    && sudo mkdir -p /opt/softwares /opt/openmpi /opt/fftw3 \
    && sudo chown -R ubuntu:ubuntu /opt/openmpi /opt/softwares /opt/fftw3 \
    && cd /opt/softwares \
    && wget -c https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.gz \
    && tar zxvf openmpi-4.1.0.tar.gz \
    && cd openmpi-4.1.0 \
    && ./configure --prefix=/opt/openmpi \
    && make -j 128 \
    && make install

# Install fftw3
RUN cd /opt/softwares \
    && wget -c http://www.fftw.org/fftw-3.3.9.tar.gz \
    && tar zxvf fftw-3.3.9.tar.gz \
    && cd fftw-3.3.9 \
    && ./configure --prefix=/opt/fftw3 \
    && make -j 128 \
    && make install

# Add PATH for open-mpi & fftw3
RUN echo "export PATH=/opt/openmpi/bin:/opt/fftw3/bin:\$PATH" >> ~/.zshrc \
    && echo "export MKLROOT=/opt/intel/oneapi/mkl/latest" >> ~/.zshrc \
    && echo "export LD_LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:\$LD_LIBRARY_PATH" >> ~/.zshrc \
    && echo "export LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:\$LIBRARY_PATH" >> ~/.zshrc

# Compile CONQUEST
COPY system.make /home/ubuntu/system.make
ENV PATH=/opt/openmpi/bin:/opt/fftw3/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/opt/openmpi/lib:/opt/fftw3/lib:$LIBRARY_PATH
RUN cd /opt/softwares \
    && git clone https://github.com/OrderN/CONQUEST-release conquest \
    && cd conquest/src \
    && mv system.make system.make.bak \
    && cp ~/system.make ./system.make \
    && make \
    && cd ../tools/BasisGeneration \
    && mv system.make system.make.bak \
    && mv ~/system.make ./system.make \
    && make 

# Add PATH for CONQUEST
RUN echo "export PATH=/opt/softwares/conquest/bin:\$PATH" >> ~/.zshrc \
    && echo "alias cq=/opt/softwares/conquest/bin/Conquest" >> ~/.zshrc \
    && echo "alias cqion=/opt/softwares/conquest/bin/MakeIonFiles" >> ~/.zshrc

# Clean apt-cache & archive files
RUN sudo apt autoremove -y \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && rm /opt/softwares/*.tar.gz

ENTRYPOINT ["/bin/zsh"]
```

&emsp;&emsp;镜像构建过程中所需的 system.make 文件与上一节中的文件内容一致，使用以下命令编译生成 Docker 镜像。

```bash
docker build . -t zhonger/conquest
```

### 运行

#### 方式一

```bash
docker run -ti -d --name dev zhonger/conquest:latest
```

```bash
docker exec -ti dev /bin/zsh
```

#### 方式二

```yaml
version: "3.9"
services:

  conquest:
    image: zhonger/conquest:latest
    container_name: dev
    stdin_open: true
    tty: true
    volumes:
     - ~/web/test:/home/ubuntu/test
    restart: always
```

```bash
docker-compose up -d
docker exec -ti dev /bin/zsh
```
