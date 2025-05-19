---
layout: post
title: '《手解量子化学》练习题 1-1'
subtitle: '从练习题推导中加深对量子化学理论的理解'
date: 2025-05-14 16:52:00 +0900
categories: [ac, qc]
author: zhonger
cover: 'https://i.lisz.top/cover/Hqx2QN.webp'
cover_author: 'Uwe Conrad'
cover_author_link: 'https://unsplash.com/@uconrad'
tags: 
- Quantum Chemistry
- By hand
- Solution
- Exercise
---

> note "练习题1-1"
> **判断下面的算子是否厄米（Hermitian）或为厄米算子（Hermite Operator）。**
>
> $$[1]\ {d \over dx} \quad [2]\ {\mathrm{i}{d \over dx}} \quad [3]\ {d^2 \over dx^2}$$

解答本题首先要理解厄米的判断条件：

$$
\int\psi_{i}^*(\boldsymbol{r}) \hat{f}\psi_{j}(\boldsymbol{r})d\boldsymbol{r}=\int\psi_{j}(\boldsymbol{r}) \hat{f}^*\psi_{i}^*(\boldsymbol{r})d\boldsymbol{r}
$$

其中 $$\hat{f}^*$$ 是 $$\hat{f}$$ 的复共轭或伴随算子， $$\psi_{i}(\boldsymbol{r})$$ 和 $$\psi_{j}(\boldsymbol{r})$$ 为基底函数，其对应的复共轭函数为 $$ \psi_{i}^*(\boldsymbol{r}) $$ 和 $$ \psi_{j}^*(\boldsymbol{r}) $$。

> info "知识点补充一"
> &emsp;&emsp;基底函数符合**正交归一化条件**，即“**任意两个不同基底函数正交**”和“**任意一个基底函数在全空间上的积分为 1**”。形式化可以表示为
> $$ \int\psi_{i}^*(\boldsymbol{r})\psi_{j}(\boldsymbol{r})d\boldsymbol{r}=0$$
> 和
> $$ \int|\psi(\boldsymbol{r})|^2 d\boldsymbol{r}=1 $$。

> info "知识点补充二"
> &emsp;&emsp;求导数时的链式法则：$$ (uv)'=u'v+uv' $$。转换为积分形式： $$ uv=\int{u'v}d\boldsymbol{r}+\int{uv'}d\boldsymbol{r} $$，将右边的第一项移到左边于是有 $$ \int{uv'}d\boldsymbol{r}=uv-\int{u'v}d\boldsymbol{r} $$。

## 算子一

现在开始考虑第一个算子 $$ \hat{f}={d \over dx} $$，显然这个算子就是求导算子（这里是**对后面的函数微分求导**），于是

$$
\begin{align}
左边&= \int\psi_{i}^*(x)\left({d \over dx}\psi_{j}(x)\right)dx \\\\
&=[\psi_{i}^*(x)\psi_{j}(x)]_{-\infty}^{+\infty}-\int\left({d \over dx}\psi_{i}^*(x)\right)\psi_{j}(x)dx
\end{align}
$$

由于 $$\displaystyle \lim_{x \to \pm\infty} \psi_{i}^*(x)=0$$ 和 $$\displaystyle \lim_{x \to \pm\infty }\psi_{j}(x)=0$$（有限，作为波函数的基底函数在无穷处必须快速衰减），所以有

$$
[\psi_{i}^*(x)\psi_{j}(x)]_{-\infty}^{+\infty}=0
$$

即

$$
\begin{align}
左边&=-\int\left({d \over dx}\psi_{i}^*(x)\right)\psi_{j}(x)dx \\\\
&=-\int\psi_{j}(x){d \over dx}\psi_{i}^*(x)dx \\\\
&≠右边
\end{align}
$$

因此**第一个算子不是厄米算子**。

## 算子二

类似第一个算子，对于第二个算子 $$\hat{f}=\mathrm{i}{d \over dx}$$ 有

$$
\begin{align}
左边&=\int\psi_{i}^*(x)\left(\mathrm{i}{d \over dx}\psi_{j}(x)\right)dx \\\\
&=\mathrm{i}[\psi_{i}^*(x)\psi_{j}(x)]_{-\infty}^{+\infty}-\int\left(\mathrm{i}{d \over dx}\psi_{i}^*(x)\right)\psi_{j}(x)dx
\end{align}
$$

> info "知识点补充三"
>
> $$\left(\mathrm{i}{d \over dx}\right)^*=-\mathrm{i}{d \over dx}$$

应用**基底函数的有限条件**和上述的**伴随算子**可得

$$
\begin{align}
左边&=0-\int\left(-\left(\mathrm{i}{d \over dx}\right)^*\psi_{i}^*(x)\right)\psi_{j}(x)dx \\\\
&=\int\left(\left(\mathrm{i}{d \over dx}\right)^*\psi_{i}^*(x)\right)\psi_{j}(x)dx=右边
\end{align}
$$

因此**第二个算子是厄米算子**。

## 算子三

> info "知识点补充四"
> **二阶导的伴随算子还是它本身**，于是有
>
> $$ \left( {d^2 \over dx^2} \right)^*={d^2 \over dx^2} $$
>

> info "知识点补充四"
> 根据链式法则，求一阶导有：
> $$ (uv')'=u'v'+uv'' $$ 和 $$ (u'v)'=u'v'+u''v $$。
> 对应的积分形式：$$ \int{uv''}=uv'-\int{u'v'} $$ 和 $$ \int{u'v'}=u'v-\int{u''v} $$。
>

第三个算子是二阶导数，有

$$
\begin{align}
左边 &=\int\psi_{i}^*(x){d^2 \over dx^2}\psi_{j}(x)dx \\\\
&=[\psi_{i}^*(x){d \over dx}\psi_{j}(x)]_{-\infty}^{+\infty}-\int\left({d \over dx}\psi_{i}^*(x)\right)\left({d \over dx}\psi_{j}(x)\right)dx \\\\
&=-\int\left({d \over dx}\psi_{i}^*(x)\right)\left({d \over dx}\psi_{j}(x)\right)dx \\\\
&=-\left(\left[\left({d \over dx}\psi_{i}^*(x)\right)\psi_{j}(x)\right]_{-\infty}^{+\infty}-\int\left({d^2 \over dx^2}\psi_{i}^*(x)\right)\psi_{j}(x)dx\right) \\\\
&=0+\int\left({d^2 \over dx^2}\psi_{i}^*(x)\right)\psi_{j}(x)dx \\\\
&=\int\left(\left({d^2 \over dx^2}\right)^*\psi_{i}^*(x)\right)\psi_{j}(x)dx=右边
\end{align}
$$

因此，**第三个算子是厄米算子**。
