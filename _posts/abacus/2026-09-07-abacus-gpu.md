---
layout: post
title: '编译 GPU 版本的 ABACUS'
subtitle: '从 conda 出发构建纯粹、可用的 GPU 运行环境'
date: 2026-09-07 15:14:00 +0800
categories: [tech, abacus]
author: zhonger
cover: 'https://i.lisz.top/cover/tyB9o2.webp'
cover_author: 'Oxana Golubets'
cover_author_link: 'https://unsplash.com/@ok_milka'
tags: 
- abacus
- gpu
- conda
---

## 前言

&emsp;&emsp;在过去的数十年里，第一性原理计算主要使用 CPU 计算。受限于可用 CPU 的数量和计算能力，一般使用一台 96 核的服务器往往最多只能计算包含百来个原子的体系。当然这有很大一部分是因为，基于**平面波函数**（PW）基组的第一性原理计算软件（例如 `VASP`）的计算代价随着体系中原子个数呈现  O(N²)  规模增大。为了“尽可能地降低计算代价”和“同时保留计算精度”，**数值原子轨道**（NAO）基组被设计出来替代平面波函数加速计算。相比平面波基组描述**自由电子在空间各处的分布**，数值原子轨道基组描述**束缚态电子在高度局域的原子核周围的分布**，并且可利用局域性结合**稀疏矩阵**实现线性扩展，即 O(N) 规模。当数值原子轨道基组考虑的轨道数越多时，结果就越与平面波基组结果接近。这样一来，基于数值原子轨道基组的第一性原理软件可以同样使用一台 96 核的服务器最多计算包含数百个原子的体系。

> note "小知识"
> &emsp;&emsp; 平面波基组与数值原子轨道基组是两种最核心的基组（Basis Sets）形式，它们本质上是用不同的数学函数作为“构件”（可以理解为电子密度空间的基础向量），来拟合实际体系中的波函数（“电子状态”或者“电子密度分布”）。

&emsp;&emsp;近些年来，随着 GPU 硬件及其开发环境的不断发展和成熟，越来越多的第一性原理计算软件开始支持在 GPU 上加速计算。以结构优化为例，现有的第一性原理计算软件（例如 `ABACUS`）只将电子步和交换关联能求解搬上了 GPU，离子步等则保留在了 CPU 上。具体如下所示：

| 计算阶段 | 细分步骤 | 执行设备 |
| :-- | :-- | :--: |
| 离子步 | 原子坐标/晶胞参数更新 | CPU |
| 离子步 | 结构优化算法 (CG/BFGS等) | CPU |
| 离子步 | 力、应力收敛判断 | CPU |
| 电子步 | 快速傅里叶变换 (FFT) | GPU |
| 电子步 | 汉密尔顿矩阵与波函数乘法 | GPU |
| 电子步 | 子空间对角化/矩阵求解 | GPU |
| 电子步 | 局域轨道重叠积分/哈密尔顿量构建 | GPU |
| 电子步 | 密集/稀疏矩阵对角化 | GPU |
| 辅助计算 | 交换关联能求解 (XC Functional) | GPU |
| 辅助计算 | 电荷密度混合 (Mixing) | CPU |
| 辅助计算 | 离子受力与应力张量计算 | CPU/GPU 混合 |

由于 DFT 计算中**最耗时**的就是**对角化**相关的步骤（电子步），一旦这些被搬上 GPU 加速计算之后，DFT 计算对于 CPU 的需求就会显著降低。甚至于，只需要保留几个 CPU 核就能轻松应对外层控制和电荷密度混合。从上表也可以看出，GPU 的使用会将原本大部分对于内存的需求转变为显存的需求，仅有原子坐标和电子密度相关的数据仍然保留在内存中。

## 编译实践

&emsp;&emsp;GPU 运行版本的 ABACUS 编译环境应该与运行环境完全一致，尤其是 CUDA 及 NVCC 版本。当使用不同型号的 GPU 时，宿主机安装的 CUDA 版本很大可能也不一样，这主要是因为 NVIDIA 官方通常只对最新架构的 GPU 更新 CUDA 版本支持。在某些 GPU 服务器上，也有可能 CUDA 版本和 NVCC 版本不一致的情况，这无疑也是障碍。为了避免这些障碍，比较可行的方案是用 conda 来统一管理 ABACUS 在特定 CUDA 版本上的 GPU 运行版本及其他所需依赖。

&emsp;&emsp;这里笔者采用一块 L20 GPU 作为示范。可以通过 [NVIDIA 官网](https://www.nvidia.cn/drivers/) 查询到 GPU 支持的 CUDA 最高版本（13.3）。但在 GPU 主机上通过 `nvidia-smi` 命令查询到宿主机安装的 NVIDIA 驱动版本和默认兼容 CUDA 版本为 535.247 和 12.2。由于 CUDA 13.3 和 12.2 属于跨主版本，不推荐交叉使用。所以这里可以安装的 CUDA 和 NVCC 版本就是 12.x 系列。

```bash
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.247.01             Driver Version: 535.247.01   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
```

> info "小提示"
> &emsp;&emsp; 我们可以通过阅读 NVIDIA 官方提供的 [CUDA 兼容性解释](https://docs.nvidia.com/deploy/cuda-compatibility/why-cuda-compatibility.html) 来理解 CUDA 版本的选择。这里主要考虑的是两种兼容性原则：**次要版本兼容性**和**数据中心卡的向前兼容**。

### 准备编译环境

&emsp;&emsp;这里假设 GPU 主机上已经安装好了 conda 软件，可以正常使用。首先通过以下命令创建一个名为 `abacus` 的、仅包含 `Python 3.10` 的环境。

```bash
conda create -n abacus python=3.10
```

下载 ABACUS 源代码到准备编译的目录 `~/opt/abacus`，并如下解压源代码到 `~/opt/abacus/v3.10.0` 目录。

```bash
mkdir -p ~/opt/abacus
cd ~/opt/abacus
wget -c https://abacus.ustc.edu.cn/_upload/tpl/0c/d8/3288/template3288/download/zip/source-LTS.zip
unzip source-LTS.zip
tar zxf abacus-develop-LTSv3.10.0.tar.gz
mv abacus-develop-LTSv3.10.0 v3.10.0
cd v3.10.0
```

#### 安装 CUDA 环境

&emsp;&emsp;ABACUS 采用了 CMAKE、g++、gfortran 等编译工具，因此需要在正式编译前确保具备这些工具。其次，BLAS、LAPACK、SCALAPACK、FFTW、LIBXC、CEREAL、OpenMPI 等多种依赖库也需要安装。最后，CUDA 环境是必须的，因为 ABACUS 的 GPU 版本编译和运行都需要 CUDA 支持。

```bash
conda install -c conda-forge \
    cmake openmpi openblas libblas liblapack scalapack fftw libxc \
    rapidjson cereal cuda-toolkit=12.2 -y

conda install -c conda-forge \
    cxx-compiler \
    fortran-compiler \
    c-compiler \
    make git bc time unzip wget cuda-nvtx-dev -y
```

> note "小知识"
> &emsp;&emsp;这里的 OpenMPI 必须与 cuda-toolkit 一起安装，否则 conda 默认安装将会是不可用的 OpenMPI 版本。另外，cuda-toolkit 并不包括 cuda-nvtx-dev 头文件，因此需要单独安装。这个库的核心作用是允许开发者在 C/C++ 代码中手动插入“标记”和“时间区间”，以便在进行 GPU 性能分析时能更清晰地定位和解读耗时瓶颈。

&emsp;&emsp;通过以下命令验证 conda 安装的 CUDA 和 NVCC 版本。

```bash
╰─$ conda list | grep -E "cuda-version|nvcc"
cuda-nvcc                      12.2.140            hcdd1206_0             conda-forge
cuda-nvcc-dev_linux-64         12.2.140            ha770c72_1             conda-forge
cuda-nvcc-impl                 12.2.140            hd3aeb46_1             conda-forge
cuda-nvcc-tools                12.2.140            hd3aeb46_1             conda-forge
cuda-nvcc_linux-64             12.2.140            h8a487aa_0             conda-forge
cuda-version                   12.2                he2b69de_3             conda-forge
```

> note "小知识"
> &emsp;&emsp;`cuda-toolkit` 是包括了 `cuda-nvcc`、`cuda-version`、`CUDA runtime`、`cuBLAS` 等一系列 CUDA 开发工具的集合。当我们指定安装 `cuda-toolkit` 时会自动安装它们。如果想要使用更高版本的 CUDA，可以通过类似 `cuda-toolkit=12.9` 指定。

#### 准备头文件 libnpy

&emsp;&emsp;`libnpy` 是一个用于在 C++ 中读写 (Python NumPy) NPY 格式文件的头文件库。ABACUS 的 GPU 版本需要这个库来读写 NPY 格式的文件。

```bash
cd /tmp
git clone https://gh-proxy.org/github.com/llohse/libnpy.git
cp libnpy/include/npy.hpp $CONDA_PREFIX/include
rm -rf libnpy
```

#### 编译并安装 ELPA 库

&emsp;&emsp;ELPA（Eigenvalue Solver for Petascale Applications）是一个专为大规模并行计算设计的高性能特征值/特征向量求解器开源库。ELPA 采用了两段式归约算法，大幅减少了跨节点/跨核通信，使大规模计算的并行扩展性延伸到数万甚至数十万 CPU 核心。它本身也支持 GPU 加速。不过，ABACUS 在 GPU 运算时默认使用 CUDA 提供的 cusolver 库，可以进一步优化性能。

```bash
# 从 ELPA 官网下载最新版本的源代码压缩包
cd /tmp
ELPA_VER=2026.02.002 
wget -q https://elpa.mpcdf.mpg.de/software/tarball-archive/Releases/$ELPA_VER/elpa-$ELPA_VER.tar.gz
tar xzf elpa-$ELPA_VER.tar.gz && rm elpa-$ELPA_VER.tar.gz
cd elpa-$ELPA_VER

# 检测编译环境是否齐全和应用自定义安装配置
./configure CC=mpicc \
            CXX=mpic++ \
            FC=mpifort \
            CFLAGS="-O3" \
            FCFLAGS="-O3" \
            LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib -lstdc++" \
            --disable-sse \
            --disable-sse-assembly \
            --disable-avx \
            --disable-avx2 \
            --disable-avx512 \
            --enable-openmp \
            --enable-nvidia-gpu \
            --with-cuda-path=$CONDA_PREFIX \
            --prefix=$CONDA_PREFIX

# 使用 8 个核并行编译并安装
make -j8
make install

# 创建软链接使得 ELPA 头文件加入 conda 库文件夹
ln -sf $CONDA_PREFIX/include/elpa_openmp-$ELPA_VER/elpa $CONDA_PREFIX/include/
```

> info "小提示"
> &emsp;&emsp; 如果在 `./configure` 配置过程中报错需要更改参数，推荐先用命令 `make clean 2>/dev/null || true && rm -rf config.cache config.status` 清理上次失败的缓存。

### 正式编译

&emsp;&emsp;在 conda 的 abacus 环境中如上准备好所需环境后，就可以正式开始编译 ABACUS 了。这里需要指定安装目录、启用 ELPA、启用 CUDA、启用 rapidjson 和 cereal 库、禁用测试等参数。

```bash
# 在 build 目录中生成编译所需的文件
cmake -B build \
      -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
      -DUSE_ELPA=ON \
      -DUSE_CUDA=ON \
      -DENABLE_RAPIDJSON=ON \
      -DBUILD_TESTING=OFF

# 使用 8 个核并行编译并安装到指定目录
cmake --build build -j8
cmake --install build
```

&emsp;&emsp;编译完成后，可以通过以下命令验证 ABACUS 可执行文件是否正确编译生成。

```bash
╰─$ abacus --version
ABACUS version v3.10.0
```

## 测试验证

&emsp;&emsp;为了测试验证一下 GPU 版本和 CPU 版本的差异，笔者选择了 [BaTiO3 示例](https://github.com/MCresearch/abacus-user-guide/tree/master/examples/lcao-gv/005_3BaTiO3)。具体使用到的 INPUt、KPT、STRU 文件如下：（UPF 和 ORB 文件请见示例网站）

```bash
# INPUT
calculation         scf
nbands              72
symmetry            1
dft_functional      pbe
basis_type          lcao
device              gpu
ecutwfc             90
scf_nmax            100
scf_thr             1e-7
```

对于使用 GPU 运行 ABACUS，需要将 `device` 参数设置为 `gpu`（默认为 `cpu`）。

```bash
# KPT
K_POINTS
0
Gamma
7 7 6 0 0 0
```

```bash
# STRU
ATOMIC_SPECIES
Ba 137.327 Ba_ONCV_PBE-1.0.upf
Ti 47.867 Ti_ONCV_PBE-1.0.upf
O 15.999 O_ONCV_PBE-1.0.upf

NUMERICAL_ORBITAL
Ba_gga_10au_100Ry_4s2p2d1f.orb
Ti_gga_8au_100Ry_4s2p2d1f.orb
O_gga_7au_100Ry_2s2p1d.orb

LATTICE_CONSTANT
1.889716

LATTICE_VECTORS
    5.75467     0.00000     0.00000
   -2.87734     4.98369     0.00000
    0.00000     0.00000     7.10999

ATOMIC_POSITIONS
Direct

Ba
0.0
3
  0.0000000   0.0000000   0.0020690 1 1 1
  0.6666667   0.3333333   0.3354023 1 1 1
  0.3333333   0.6666667   0.6687357 1 1 1

Ti
0.0
3
  0.0000000   0.0000000   0.5164400 1 1 1
  0.6666667   0.3333333   0.8497733 1 1 1
  0.3333333   0.6666667   0.1831067 1 1 1

O
0.0
9
  0.8369553   0.6739107   0.6476637 1 1 1
  0.3260893   0.1630447   0.6476637 1 1 1
  0.8369553   0.1630447   0.6476637 1 1 1
  0.5036220   0.0072440   0.9809970 1 1 1
  0.9927560   0.4963780   0.9809970 1 1 1
  0.5036220   0.4963780   0.9809970 1 1 1
  0.1702887   0.3405773   0.3143303 1 1 1
  0.6594227   0.8297113   0.3143303 1 1 1
  0.1702887   0.8297113   0.3143303 1 1 1
```

&emsp;&emsp;准备好上述文件以及 UPF 和 ORB 文件后，就可以使用 4mpi x 1omp 的配置运行。

```bash
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 mpirun -np 4 abacus > OUT
```

&emsp;&emsp;通过 `nvidia-smi` 可以实时看到 GPU 的使用情况。一般来说，GPU 的利用率会尽可能接近 100%，显存利用率则根据计算体系大小而变化。

```bash
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.247.01             Driver Version: 535.247.01   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA L20                     Off | 00000000:BD:00.0 Off |                    0 |
| N/A   34C    P0              92W / 350W |   1799MiB / 46068MiB |     92%      Default |
|                                         |                      |                  N/A |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
+---------------------------------------------------------------------------------------+
```

&emsp;&emsp;通过 `tail -f OUT` 可以实时看到计算进度。可以看到，每一个电子步很快就完成了。

```bash
╰─$ tail -f OUT
 Initial plane wave basis and FFT box
 ---------------------------------------------------------
 DONE(0.139128   SEC) : INIT PLANEWAVE
 DONE(0.943371   SEC) : LOCAL POTENTIAL
 -------------------------------------------
 SELF-CONSISTENT : 
 -------------------------------------------
 gemm_algo_selector::Fastest time: 0.03584 ms
 START CHARGE      : atomic
 DONE(1.84281    SEC) : INIT SCF
 ITER       ETOT/eV          EDIFF/eV         DRHO     TIME/s
 CU1     -1.06995902e+04   0.00000000e+00   1.6668e-01   5.81
 CU2     -1.05876319e+04   1.11958338e+02   3.7860e-01   4.32
 CU3     -1.07513294e+04  -1.63697497e+02   6.8688e-02   4.25
 CU4     -1.07481849e+04   3.14455363e+00   4.3508e-02   4.20
 CU5     -1.07493547e+04  -1.16979854e+00   9.2559e-03   4.21
 CU6     -1.07493970e+04  -4.23377294e-02   3.9510e-03   4.14
 CU7     -1.07493988e+04  -1.81857667e-03   1.4855e-03   4.14
 CU8     -1.07494003e+04  -1.45159416e-03   2.3845e-04   4.21
 CU9     -1.07494003e+04  -3.88108856e-05   3.8154e-05   4.21
 CU10    -1.07494003e+04   4.48816233e-08   1.8327e-05   4.21
 CU11    -1.07494003e+04  -4.23625231e-07   2.7077e-06   4.20
 CU12    -1.07494003e+04  -4.63727276e-09   1.5024e-06   4.17
 CU13    -1.07494003e+04  -2.92188401e-09   2.7893e-07   4.14
 CU14    -1.07494003e+04  -4.79504522e-11   1.3009e-07   4.19
 CU15    -1.07494003e+04   1.54678878e-12   4.4479e-08   4.25

 ....

 START  Time  : Wed Sep  9 13:16:43 2026
 FINISH Time  : Wed Sep  9 13:17:50 2026
 TOTAL  Time  : 67
 SEE INFORMATION IN : OUT.ABACUS/
```

&emsp;&emsp;这里笔者同时也测试了 CPU 版本，得到如下对比表格。GPU 版本相比 CPU 版本有 1.60 倍的加速，其中 `HamiltLCAO::updateHk` 函数的加速最多，达到了 2.94 倍。这与前言中分析的结果一致。

| 类 | 功能 | CPU/s (占比) | GPU/s (占比) | 加速比 | 调用次数 |
| --: | --: | :-- | :-- | :-- | :--: |
| / | total | 106.79 | 66.89 | 1.60x | 13 |
| Ions | opt_ions | 105.74 (99.01%) | 65.92 (98.55%) | 1.60x | 1 |
| HSolverLCAO | solve | 103.90 (97.29) | 63.73 (95.28%) | 1.63x | 15 |
| HamiltLCAO | updateHk | 25.10 (23.50%) | 8.55 (12.78%) | 2.94x | 2220 |
| Diago | cu/elpa | 55.00 (51.50%) | 39.57 (59.16%) | 1.39x | 2220 |

## 结语

&emsp;&emsp;作为国产第一性原理计算软件， ABACUS 同时支持平面波基组和数值原子轨道基组，在使用上具有天然优势，而 GPU 版本的推出进一步提升了并行计算效率。另外，通过对比运行结果发现，CPU 和 GPU 得到的能量等数值几乎一模一样，说明 GPU 版本在数值计算上误差也极小。（这似乎与深度学习的 GPU 代码相比 CPU 代码通常会有数值上的精度损失的印象有所不同。）如果你对使用 GPU 做第一性原理计算感兴趣，不妨从 ABACUS 的 GPU 版本开始一试。

## 参考资料

- [ABACUS 官方 GPU 版本容器构建 Dockerfile](https://github.com/abacusmodeling/abacus-develop/blob/develop/Dockerfile.cuda)
- [编译 Nvidia GPU 版本的 ABACUS](https://mcresearch.github.io/abacus-user-guide/abacus-gpu.html)
- [ABACUS LCAO 基组 GPU 版本使用说明](https://mcresearch.github.io/abacus-user-guide/abacus-gpu-lcao.html)
- [ABACUS 数值原子轨道基组 10 个典型算例](https://mcresearch.github.io/abacus-user-guide/test-10cases-lcao.html#0053batio3)
