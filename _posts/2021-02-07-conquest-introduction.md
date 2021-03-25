---
layout: post
title: 'CONQUEST 第一性原理计算框架'
subtitle: '欢迎进入量子化学的世界'
date: 2021-02-07 20:18:00 +0800
tags: 
- CONQUEST
- 量子化学
categories: [tech, conquest]
cover: 'https://images.unsplash.com/photo-1612572767699-093823e475af?w=1600&q=900'
---

## 前言

&emsp;&emsp;随着计算机的计算能力和运行规模的不断提升，基于第一性原理计算理论的计算材料学科越来越得到重视。但是一般来说这样的模拟需要对一个包含成千上万的原子、电子而言，所需的计算框架是非常复杂的，计算代价是相当昂贵的。比如为人所熟知的商用类型[第一性原理计算框架 VASP](https://www.vasp.at/) 授权通常需要五六万人民币以上，而且在一个普通超算集群上计算一个完整的体系结构可能需要几周，甚至几个月。无论是软件授权成本，还是时间成本，都比较高昂。对于想学习和实践第一性原理计算的小伙伴而言，当然也有比较节省的方式。首先软件可以选用免费的开源第一性原理计算框架，比如说本文中即将介绍到的 [CONQUEST](http://order-n.org/)，以及 [ABINT](http://www.abinit.org/)，[SMASH](http://smash-qc.sourceforge.net/) 和 [QUANTUM ESPRESSO](http://www.quantum-espresso.org/) 等。

&emsp;&emsp;对于普通材料专业的学生来说，可能安装任意一个开源第一性原理计算框架都不是一件容易的事，毕竟有些软件所涉及到的依赖库配置确实比较麻烦。另外，大部分这种软件也只能在 Linux 平台下运行，对于 Linux 比较陌生的人使用起来也有一定的困难。东京大学物质科学团队为此将很多第一性原理计算软件安装在一个同一个虚拟机中，并在网上公开允许下载该虚拟机镜像。用户可以在[官网](https://ma.issp.u-tokyo.ac.jp/)获知有关下载信息，所支持的软件列表可以查看[这里](https://ma.issp.u-tokyo.ac.jp/app/)。

## CONQUEST

### CONQUEST 是什么？

&emsp;&emsp;CONQUEST 是一款基于本地轨道密度泛函理论的、能以出色的缩放比例进行大规模并行计算的第一性原理计算软件。它使用局部轨道来表示 Kohn-Sham 本征态或者密度矩阵。 CONQUEST 可以应用于原子、分子、液体和固体，且对于大型系统特别有效。CONQUEST 可以使用哈密尔顿的精确对角化或通过线性缩放的方法来找到基态。它已被验证使用线性缩放时缩放到超过 2,000,000 个原子和 200,000 个核，以及超过 3,400 个原子和 850 个具有精确对角化的核。 CONQUEST 可以执行结构弛豫（包括单位晶胞优化）和分子动力学（在具有各种恒温器的 NVE，NVT 和 NPT 集成中）。

### 为什么选 CONQUEST

#### 大规模模拟

&emsp;&emsp;CONQUEST 设计为使用大型对角缩放（使用精确对角化（使用多站点支持函数方法，已经证明了对3,000多个原子的计算）或线性缩放（已经证明了对超过2,000,000个原子的计算）。此外，相同的代码和基础集可用于对 1 个原子到 1,000,000 个以上原子的系统进行建模。

#### 高效并行化

&emsp;&emsp;CONQUEST 是一种固有的并行代码，可演示将其扩展到 800 多个内核，以实现精确的对角化，并通过线性缩放将近 200,000 个内核。这种扩展使高效使用 HPC 设施成为可能。CONQUEST（在线性缩放模式下，以及在一定程度上进行精确的对角化）在弱缩放下缩放效果最佳：固定每个核心（或线程）的原子数，并根据原子数选择核心数。

&emsp;&emsp;CONQUEST 还以线性缩放模式提供一些 OpenMP 并行化，每个节点的 MPI 线程数量相对较少，并使用 OpenMP 进行进一步的并行化。

#### 线性缩放

&emsp;&emsp;线性缩放的思想已经存在了二十多年，但是事实证明，编写高效、准确的代码来实现这些思想具有挑战性。尽管可以使用的基础集仍然受到一些限制，但 CONQUEST 已证明有效的线性缩放（具有出色的并行缩放）。对于使用 DFT 进行的 5,000 至 10,000 原子以上的计算，线性缩放是唯一的选择。

#### 基础集（basis set）

&emsp;&emsp;CONQUEST 用称为支持函数的局部轨道表示 Kohn-Sham 本征态或密度矩阵（等效）。这些支持函数由两个基本集合之一构成：伪原子轨道（PAO）或 blip 函数（B样条曲线）；在 CONQUEST 中使用的主要基础函数是 PAO。PAO 生成代码包含在CONQUEST 发行版中，其中大多数元素具有定义明确且可靠的默认基础集。

&emsp;&emsp;最简单的选择是为每个支持功能使用一个 PAO（通常这最多可以计算 1,000 个原子）。对于超出此系统大小的对角化，将使用复合基础，其中将多个 PAO 组合为较小的一组支持功能（多站点支持功能或 MSSF）。使用 MSSF，可以在 HPC 平台上计算 3,000 多个原子。对于线性缩放，需要更注意基集（更多详细信息，请参见[此处](https://conquest.readthedocs.io/en/latest/groundstate.html#gs-on)）。

## 编译安装指南

&emsp;&emsp;为了更好地符合可能存在的多种环境需求，笔者就自己所有的一些平台进行了测试和实践，主要分为以下几类，并以独立文章的形式分别介绍：

- [ARM 篇](/tech/conquest-arm)：该类主要包含 Mac M1，树莓派以及 ARM 服务器。
- [Intel 篇](/tech/conquest-intel)：该类主要包括普通 PC 和 x86 服务器。
- [Slurm 篇](/tech/conquest-slurm)：该类主要是应用于 HPC 环境下，当然也适合个人在高性能服务器上运行。

## 使用指南

&emsp;&emsp;CONQUEST 正常编译成功后会在源代码目录下的 bin 目录里面看见 Conquest 的可执行文件，进入 tools/BasisGeneration 编译后 bin 目录会多出一个 MakeIonFiles 的可执行文件。Conquest 命令是用来执行模拟，MakeIonfiles 是用来生成模拟所需的原子轨道描述文件。以下就以 Li 为对象介绍一下完整的 CONQUEST 运行流程。

### 输入文件

&emsp;&emsp;CONQUEST 所需的输入文件一共有三个，分别是 Conquest_input， Li.in 和 Li.ion。这三个文件中除了 Li.ion 之外都需要自己编写，首先介绍如何得到 Li.ion 文件。

#### 生成 Li.ion

&emsp;&emsp;进入 CONQUEST 源代码目录下的 pseudo-and-pao 目录，可以看到有 LDA，PBE 和 PBEsol 三个文件夹。我们这里采用 PBE 方法来模拟所以进入 PBE/Li 目录。执行 MakeIonFiles 命令就会生成我们所需的 Li.ion 文件。这里需要注意的有三点：（1）MakeIonFiles 命令执行需要引用到正确的路径，否则会提示不存在该命令，所以建议对此命令建立一个别名使用更加方便。比如在 .bashrc 文件尾部中添加一行 `alias cqion="~/conquest/bin/MakeIonFiles"` 并使该配置生效即可。（2）生成的文件名并不是 Li.ion，可以使用 `mv LiCQ.ion Li.ion`。（3）根据想要进行模拟的规模不同，可以分为 SZ(minimal)、SZP(small)、DZP(medium) 和 TZTP(large) 四种，可以在同目录的 Conquest_input 文件中修改 `Atom.BasisSize medium` 来修改 Li.ion 文件的规模。

#### 编写 Conquest_input

&emsp;&emsp;Conquest_input 中完整的参数相当复杂，可以参考[官网](https://conquest.readthedocs.io/en/latest/input_tags.html)，这里仅对以下文件中出现的参数做出简要解释。

&emsp;&emsp;IO 开头的配置是对输入输出的定义，Iprint 是指输出文件的打印类型，Title 是任务的名字，Coordinates 是坐标文件的文件名。General 开头的配置是对基础集、支持函数类型等的定义，FunctionalType 101 是指 PBE，Pseudopotential hamann 是 CONQUEST 最新支持的基础集类型，NumberOfSpecies 指的是原子的类型数。AtomMove 开头的配置是对更新迭代过程的方法的定义，TypeOfRun 是运动方式，通常有 static、cg、md 等。minE 开头的配置是收敛方法的定义，SelfConsistent 是否采用自洽方式，SCTolerance 是精确度，MaxIters 是最多迭代次数。GridCutoff 是一个关键性的参数，定义在空间中网格化的大小，随着值的变化所计算的结果也会不一样。Diag.MeshX(MeshY, MeshZ) 定义的是 k-points 的值，也就是单位晶胞 xyz 轴的相对比值。ChemicalSpeciesLabel 中定义了原子具体有什么种类，以及它们的编号和原子质量大小。此处的原子质量大小可以从 Li.ion 文件中查到。

```bash
# Conquest_input_Li

IO.Iprint 3
IO.Title Simulation for bulk Li
IO.Coordinates Li.in
IO.FractionalAtomicCoords T

General.FunctionalType 101
General.PseudopotentialType hamann
General.Partitions Hilbert
General.NumberOfSpecies 1
General.ManyProcessors F
General.CheckDFT T
 
Basis.BasisSet PAOs

minE.VaryBasis F

AtomMove.TypeOfRun static

minE.SelfConsistent T
minE.LTolerance 1.0e-6
minE.SCTolerance 1.0e-6
SC.LinearMixingFactor 0.2
SC.KerkerFactor 0.01
SC.MaxIters  100
SC.MaxEarly  0
SC.MaxPulay  5

Grid.GridCutoff 150

DM.SolutionMethod diagon
Diag.kT   0.002
Diag.MPMesh T
Diag.MPMeshX 15
Diag.MPMeshY 15
Diag.MPMeshZ 15

%block ChemicalSpeciesLabel
 1  6.94  Li
%endblock
```


#### 编写 Li.in

&emsp;&emsp;前三行为 Li 的晶格参数 a，b 和 c 的值，因为 Li 是标准的体心立方结构，这三个值相等。具体的值可以从[网站](https://periodictable.com/Elements/003/data.html)中查到。注意此处使用的晶格参数的单位是 波尔，与 pm 的换算为 `0.5291772 pm = 1 bohr`。第四行代表在一个单位晶胞中有 2 个 Li 原子（中心 1 个 + 八个角 8 个 1/8），它们的位置一个在原点位置，一个在体心立方结构的中心位置，坐标如第五、六行前三个数字所示。后面的 1 表示这个位置有一个原子，T 表示原子可以运动，三个 T 表示 xyz 三个方向。

```bash
6.633 0.00	0.00
0.00  6.633 0.00
0.00  0.00  6.633
2
  0.000000000000E+00  0.000000000000E+00  0.000000000000E+00   1 T T T
  0.500000000000E+00  0.500000000000E+00  0.500000000000E+00   1 T T T
```


### 运行

&emsp;&emsp;由于 CONQUEST 定义了并行能使用的最大核数等于原子个数，因此在这里 Li 的计算中最多可以使用双核。如果单独使用编译成功的命令运行的话，默认用的是单核。

#### 单核运行

```bash
# 在输入文件目录中执行
~/conquest/bin/Conquest
```

#### 双核运行

```bash
# 在输入文件目录中执行
mpirun -np 2 ~/conquest/bin/Conquest < Conquest_input > Conquest_out
```