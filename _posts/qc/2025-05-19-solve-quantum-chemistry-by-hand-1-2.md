---
layout: post
title: '《手解量子化学》练习题 1-2'
subtitle: '从练习题推导中加深对量子化学理论的理解'
date: 2025-05-19 16:16:00 +0900
categories: [ac, qc]
author: zhonger
cover: 'https://i.lisz.top/cover/Xdjv9V.webp'
cover_author: 'ZHENYU LUO'
cover_author_link: 'https://unsplash.com/@mrnuclear'
tags: 
- Quantum Chemistry
- By hand
- Solution
- Exercise
---

> note "练习题1-2"
> 判断下列算子是否**可交换**？
>
> $$ [1]\ [\hat{x},\hat{p}_x] \quad [2]\ [\hat{l}_x, \hat{l_y}] \quad [3]\ [\hat{\boldsymbol{l}}^2, \hat{l}_z] $$

解决本题首先要了解**可交换**的定义，对于任意两个算子有：

$$\hat{f}\hat{g}\psi(\boldsymbol{r})=\hat{g}\hat{f}\psi(\boldsymbol{r})\ 或\ (\hat{f}\hat{g}-\hat{g}\hat{f})\psi(\boldsymbol{r})=0$$

那么这两个算子**可交换**，否则**不可交换**。其中下列式子称为交换子：

$$[\hat{f}, \hat{g}] \equiv \hat{f}\hat{g}-\hat{g}\hat{f}$$

除此之外，还需要了解以下观测量在古典力学中的变量和量子力学中的算子对应：

| 观测量 | 变量 | 算子 |
| :-- | :--: | :--: |
| 位置 | $$x\ (\boldsymbol{r})$$ | $$\hat{x}\ (\hat{\boldsymbol{x}})$$ |
| 动量 | $$p_x\ (\boldsymbol{p})$$ | $$\hat{p}_x=-\mathrm{i}\hbar{d \over dx}\ (\hat{\boldsymbol{p}})$$ |
| 角动量 | $$\boldsymbol{l}^2=l_x^2+l_y^2+l_z^2$$ | $$\hat{\boldsymbol{l}}^2=\hat{l}_x^2+\hat{l}_y^2+\hat{l}_z^2$$ |
| | | $$\hat{l}_x=-\mathrm{i}\hbar\left(y\frac{\partial}{\partial z}-z\frac{\partial}{\partial y}\right)$$ |
| | | $$\hat{l}_y=-\mathrm{i}\hbar\left(z\frac{\partial}{\partial x}-x\frac{\partial}{\partial z}\right)$$ |
| | | $$\hat{l}_z=-\mathrm{i}\hbar\left(x\frac{\partial}{\partial y}-y\frac{\partial}{\partial x}\right)$$ |

## 算子组一

将 $$\hat{p}_x=-\mathrm{i}\hbar{d \over dx} $$ 代入可得

$$
\begin{align}
[\hat{x}, \hat{p}_x]\psi(x)&=(\hat{x}\hat{p}_x-\hat{p}_x\hat{x})\psi(x) \\\\
&= -\mathrm{i}\hbar x \frac{d}{dx}\psi(x)-(-\mathrm{i}\hbar)\frac{d}{dx}[x\psi(x)]
\end{align}
$$

这里需要注意算子 $$\frac{d}{dx}$$ 是求导算子，根据链式法则应该对 $$[x\psi(x)]$$ 分别对 $$x$$ 求导，于是：

$$
\begin{align}
原式&=-\mathrm{i}\hbar x \frac{d}{dx}\psi(x) + \mathrm{i}\hbar\left[x\frac{d}{dx}\psi(x)+\psi(x)\right] \\\\
&= \mathrm{i}\hbar\psi(x) ≠ 0
\end{align}
$$

因此，这两个算子**不可交换**。

## 算子组二

将 $$\hat{l}_x$$ 和 $$\hat{l}_y$$ 代入可得 (注意 $$\mathrm{(-i)}^2=-1$$)

$$
\begin{align}
\hat{l}_x\hat{l}_y&=(-\mathrm{i}\hbar)^2\left(y\frac{\partial}{\partial z}-z\frac{\partial}{\partial y}\right)\left(z\frac{\partial}{\partial x}-x\frac{\partial}{\partial z}\right) \\\\
&=-\hbar^2\left(y\frac{\partial}{\partial z}z\frac{\partial}{\partial x}-z\frac{\partial}{\partial y}z\frac{\partial}{\partial x}-y\frac{\partial}{\partial z}x\frac{\partial}{\partial z}+z\frac{\partial}{\partial y}x\frac{\partial}{\partial z}\right)
\end{align}
$$

> info "求偏导中的注意点"
> &emsp;&emsp;这里需要注意“求偏导的函数中是否包含了偏导的对象”，如果不包含则可以直接将变量左移，如果包含则需要根据链式法则分别求导。

接着有

$$
\begin{align}
\hat{l}_x\hat{l}_y&=-\hbar^2\left[y\left(z\frac{\partial^2}{\partial z \partial x}+\frac{\partial}{\partial x}\right)-z^2\frac{\partial^2}{\partial y \partial x}-xy\frac{\partial^2}{\partial z^2}+xz\frac{\partial^2}{\partial y \partial z}\right] \\\\
&=-\hbar^2\left[yz\frac{\partial^2}{\partial z \partial x}+y\frac{\partial}{\partial x}-z^2\frac{\partial^2}{\partial y \partial x}-xy\frac{\partial^2}{\partial z^2}+xz\frac{\partial^2}{\partial y \partial z}\right]
\end{align}
$$

同理

$$
\begin{align}
\hat{l}_y\hat{l}_x&=(-\mathrm{i}\hbar)^2\left(z\frac{\partial}{\partial x}-x\frac{\partial}{\partial z}\right)\left(y\frac{\partial}{\partial z}-z\frac{\partial}{\partial y}\right) \\\\
&=-\hbar^2\left(z\frac{\partial}{\partial x}y\frac{\partial}{\partial z}-x\frac{\partial}{\partial z}y\frac{\partial}{\partial z}-z\frac{\partial}{\partial x}z\frac{\partial}{\partial y}+x\frac{\partial}{\partial z}z\frac{\partial}{\partial y}\right) \\\\
&=-\hbar^2\left[yz\frac{\partial^2}{\partial x \partial z}-xy\frac{\partial^2}{\partial z^2}-z^2\frac{\partial^2}{\partial x \partial y}+x\left(\frac{\partial}{\partial y}+z\frac{\partial^2}{\partial z \partial y}\right)\right] \\\\
&=-\hbar^2\left(yz\frac{\partial^2}{\partial x \partial z}-xy\frac{\partial^2}{\partial z^2}-z^2\frac{\partial^2}{\partial x \partial y}+x\frac{\partial}{\partial y}+xz\frac{\partial^2}{\partial z \partial y}\right)
\end{align}
$$

因此交换子为（减法抵消相同项）

$$
\begin{align}
[\hat{l}_x, \hat{l}_y]&=\hat{l}_x\hat{l}_y-\hat{l}_y\hat{l}_x \\\\
&=-\hbar^2\left(y\frac{\partial}{\partial x}-x\frac{\partial}{\partial y}\right) \\\\
&=\mathrm{i}^2\hbar^2\left(y\frac{\partial}{\partial x}-x\frac{\partial}{\partial y}\right) \\\\
&=\mathrm{i}\hbar\left[-\mathrm{i}\hbar\left(x\frac{\partial}{\partial y}-y\frac{\partial}{\partial x}\right)\right] \\\\
&=\mathrm{i}\hbar\hat{l}_z≠0
\end{align}
$$

因此，这两个算子**不可交换**。

## 算子组三

通过算子组二可以类似推理得到：

$$[\hat{l}_y, \hat{l}_z]=\mathrm{i}\hbar\hat{l}_x$$

$$[\hat{l}_z, \hat{l}_x]=\mathrm{i}\hbar\hat{l}_y$$

将其代入可得：

$$
\begin{align}
[\hat{\boldsymbol{l}}^2, \hat{l}_z]&=\hat{\boldsymbol{l}}^2\hat{l}_z-\hat{\boldsymbol{l}}^2\hat{l}_z \\\\
&=(\hat{l}_x^2+\hat{l}_y^2+\hat{l}_z^2)\hat{l}_z-\hat{l}_z(\hat{l}_x^2+\hat{l}_y^2+\hat{l}_z^2) \\\\
&=\hat{l}_x\hat{l}_x\hat{l}_z+\hat{l}_y\hat{l}_y\hat{l}_z+\hat{l}_z\hat{l}_z\hat{l}_z-\hat{l}_z\hat{l}_x\hat{l}_x-\hat{l}_z\hat{l}_y\hat{l}_y-\hat{l}_z\hat{l}_z\hat{l}_z \\\\
&=\hat{l}_x\hat{l}_x\hat{l}_z+\hat{l}_y\hat{l}_y\hat{l}_z+\bcancel{\hat{l}_z\hat{l}_z\hat{l}_z}-\hat{l}_z\hat{l}_x\hat{l}_x-\hat{l}_z\hat{l}_y\hat{l}_y-\bcancel{\hat{l}_z\hat{l}_z\hat{l}_z} \\\\
&=\hat{l}_x\hat{l}_x\hat{l}_z+\color{red}{\hat{l}_x\hat{l}_z\hat{l}_x-\hat{l}_x\hat{l}_z\hat{l}_x}\color{black}{-\hat{l}_z\hat{l}_x\hat{l}_x}+\hat{l}_y\hat{l}_y\hat{l}_z+\color{red}{\hat{l}_y\hat{l}_z\hat{l}_y-\hat{l}_y\hat{l}_z\hat{l}_y}\color{black}{-\hat{l}_z\hat{l}_y\hat{l}_y} \\\\
&=\hat{l}_x(\hat{l}_x\hat{l}_z-\hat{l}_z\hat{l}_x)+(\hat{l}_x\hat{l}_z-\hat{l}_z\hat{l}_x)\hat{l}_x+\hat{l}_y(\hat{l}_y\hat{l}_z-\hat{l}_z\hat{l}_y)+(\hat{l}_y\hat{l}_z-\hat{l}_z\hat{l}_y)\hat{l}_y \\\\
&=\hat{l}_x(-[\hat{l}_z, \hat{l}_x])+(-[\hat{l}_z, \hat{l}_x])\hat{l}_x+\hat{l}_y[\hat{l}_y, \hat{l}_z]+[\hat{l}_y, \hat{l}_z]\hat{l}_y \\\\
&=-\mathrm{i}\hbar\hat{l}_x\hat{l}_y-\mathrm{i}\hbar\hat{l}_y\hat{l}_x+\mathrm{i}\hbar\hat{l}_y\hat{l}_x+\mathrm{i}\hbar\hat{l}_x\hat{l}_y = 0
\end{align}
$$

因此，这两个算子**可交换**。
