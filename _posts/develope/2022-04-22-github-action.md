---
layout: post
title: '利用 Github Action 一键编译多平台 Docker 镜像'
subtitle: '你是否还在困扰如何为 Docker 镜像提供多平台支持？'
date: 2022-04-22 13:54:00 +0900
categories: [tech, docker]
author: zhonger
cover: 'https://i.lisz.top/cover/Isx0hj.webp'
cover_author: 'Daniel Buhat'
cover_author_link: 'https://unsplash.com/@danielbuhat'
tags:  
- github action
- workflow
- docker
- 多平台
render_with_liquid: false
---

## 前言

### 容器化的缘起

&emsp;&emsp;在技术发展的早期，Java 语言以其“一次编译，随处运行”的特点在众多编程语言中独领风骚。而 Java 语言编译出的 jar 包始终是应用层面上的，如果我们想要运行一个 Web 应用的 jar 包，仍然需要搭建 Tomcat 服务器才能真正运行这个 Java 应用。于是当虚拟化技术出现之后，开始有了同时包含 Tomcat 服务器和 jar 包等其他必要的配置和环境的完整虚拟化镜像。只要在大家的电脑或者服务器上安装了对应的虚拟化软件，运行这个虚拟化镜像就可以看到最终的 Web 界面并正常使用。

&emsp;&emsp;不过，这也有一个明显的缺点：虚拟化镜像文件通常很大，下载速度慢、时间长；运行时虚拟化软件和虚拟机占用的资源较大。容器化技术也正是为了解决这些缺点而生。Docker 是最早向大众开放的容器化技术，以“占用资源少、镜像文件小、部署配置简单”等特点受到开发者的一致好评。之后，Google、阿里等团队也纷纷将自家内部自研的容器化相关技术开放，比如阿里的 [PouchContainer](https://pouchcontainer.io/)、谷歌的 [Kubernetes](https://kubernetes.io/)、SUSE 的 [Rancher](https://rancher.com/) 等等。这些技术以及 AWS、Azure、GCP、Aliyun 等云服务器产商提供的容器化平台，大大加速了容器化技术的普及和应用，已经有越来越多的平台、应用迁移到容器化部署、管理。

### 平台架构的差异

&emsp;&emsp;近年来，随着像 AWS、Apple 等大公司投入到自研芯片的队列中，能耗更低、算力更强的 ARM 芯片开始出现在真实的虚拟化集群、容器化集群、高性能计算集群中。和我们日常使用电脑或服务器上的 Intel 或 AMD x64 芯片不同，ARM 芯片在现实中还比较少，软件包的兼容性可能也不是很好。另外，我们通常编译 Docker 镜像都是在自己的电脑或者服务器上，所以最终提交的镜像也只能是电脑或服务器的平台架构。也就是说，我们似乎无法在 Intel 芯片的设备上编译出想要的支持在 ARM 芯片上运行的 Docker 镜像。

&emsp;&emsp;这里，我们可以看一下 Docker 官方列出支持的所有平台架构：

```go
// https://github.com/docker-library/bashbrew/blob/master/architecture/oci-platform.go

...
var SupportedArches = map[string]OCIPlatform{
  "amd64":    {OS: "linux", Architecture: "amd64"},
  "arm32v5":  {OS: "linux", Architecture: "arm", Variant: "v5"},
  "arm32v6":  {OS: "linux", Architecture: "arm", Variant: "v6"},
  "arm32v7":  {OS: "linux", Architecture: "arm", Variant: "v7"},
  "arm64v8":  {OS: "linux", Architecture: "arm64", Variant: "v8"},
  "i386":     {OS: "linux", Architecture: "386"},
  "mips64le": {OS: "linux", Architecture: "mips64le"},
  "ppc64le":  {OS: "linux", Architecture: "ppc64le"},
  "riscv64":  {OS: "linux", Architecture: "riscv64"},
  "s390x":    {OS: "linux", Architecture: "s390x"},

  "windows-amd64": {OS: "windows", Architecture: "amd64"},
}
...
```

&emsp;&emsp;事实上，除了 ARM 芯片架构之外，还有一些特有的架构，比如 IBM 的 s390x 架构、RISC-V 的 riscv64 架构等等。一般的 Docker 镜像可能都只考虑常见的 amd64、386 架构，对于其他架构可能就没有所谓的官方支持了。笔者也是在使用 Docker 方式部署 [YOURLS](https://github.com/YOURLS/YOURLS) 时发现官方竟然支持了上面列出的几乎所有的平台架构，简直不要太方便。于是就想这是怎么做到的？难道他们用了不同平台的设备分别编译了一遍再推送上来的？在一番调查之后发现，他们可能用了 Github 提供的 Action 来自动编译不同平台的镜像。但事实上在 `.github/workflows` 目录下面的所有配置文件均与 Docker 镜像编译无关。不过，Github Action 帮助我们自动编译出不同平台架构的 Docker 镜像这件事确是可行的。

## 自动化构建

&emsp;&emsp;这里，笔者仅对如何利用 Github Action 自动编译出不同平台架构的 Docker 镜像进行叙述。如想要了解更多关于 Github Action 的知识，可以查看参考资料中给出的阮一峰的《Github Action 入门教程》。

### Action 配置

&emsp;&emsp;在 Github 代码库的 `.github/workflows/` 目录下新建 docker-image.yml 配置文件（文件名可自定义）。文件内容如下：（其中花括号前面的斜杆是为了不被 Jekyll 解析而用，使用时请删除）

```yaml
name: ci

on:
  push:
    tags:
      - v*

env:
  APP_NAME: squid
  DOCKERHUB_REPO: zhonger/squid

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v2
      -
        name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      -
        name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      -
        name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - 
        name: Generate App Version
        run: echo APP_VERSION=`git describe --tags --always` >> $GITHUB_ENV
      -
        name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: |
            linux/386
            linux/amd64
            linux/arm/v5
            linux/arm/v7
            linux/arm64
            linux/mips64le
            linux/ppc64le
            linux/s390x
          push: true
          build-args: |
            APP_NAME=${{ env.APP_NAME }}
            APP_VERSION=${{ env.APP_VERSION }}
          tags: |
            ${{ env.DOCKERHUB_REPO }}:latest
            ${{ env.DOCKERHUB_REPO }}:${{ env.APP_VERSION }}
```

&emsp;&emsp;以下对该文件内容分别进行解释：

#### 流程名

&emsp;&emsp;`name` 字段定义了这个流程的名称，可以与配置文件名不同。只要与其他流程配置文件中的流程名不同即可。

#### 触发条件

&emsp;&emsp;`on` 字段定义了在何种条件下触发该流程。这里定义的是在以 `v` 开头的新 tag 提交时触发该流程。

#### 环境变量

&emsp;&emsp;`env` 字段定义了静态可公开环境变量，一般来说可以将应用的名称、镜像的名称写在这个部分。

#### 任务

&emsp;&emsp;`jobs` 字段定义了流程所需要执行的各项任务，可以是一个或多个。这里定义了 6 个任务，从前到后分别是：检查代码是否在工作目录、安装 qemu 支持更多架构、安装 docker 镜像编译环境、登录 DockerHub、生成应用版本、构建和推送。这里比较灵活的一点是，通过提交的 tag 名来确定 Docker 镜像的 tag，从而实现同时推送新 tag 和 latest。在构建和推送任务中，`platforms` 字段定义了我们想要支持的平台架构，`push` 字段定义了是否推送，`build-args` 定义了加入到 Docker 镜像的变量， `tags` 定义了构建完成后所使用的 tag 值。

### Secret 配置

&emsp;&emsp;由于我们需要保护我们的 DockerHub  账户和密码的安全，所以需要通过 Secret 的变量来传递给 Github Action。如下图所示，进入 Settings 的 Security 的 Secrets 的 Actions 标签，添加对应的 DOCKERHUB_USERNAME 和 DOCKERHUB_TOKEN 变量。

![变量配置 ENV Setting](https://i.lisz.top/blog/T8UIVu.webp)

### 发布新 tag

&emsp;&emsp;访问 [https://github.com/用户名/项目名/releases/new](https://github.com/用户名/项目名/releases/new) 即可到达发布页面，如下所示。定义一个以 `v` 开头的新的标签并指向想要的分支，依次填写标题、描述后点击 `Public release` 按钮完成发布。

![新标签 New Tag](https://i.lisz.top/blog/y7i8fo.webp)

&emsp;&emsp;发布 tag 后 Github Action 就会自动开始执行上述定义流程，最终成功发布支持不同平台架构的 Docker 镜像到 DockerHub。当然，如果想要发布到其他平台，可以将镜像名和对应的验证方式修改一下即可同样有效。

## 参考资料

- [Linux 容器化技术前世今生（虚拟化、容器化、Docker）](https://developer.aliyun.com/article/761278)
- [GitHub Actions 入门教程](https://www.ruanyifeng.com/blog/2019/09/getting-started-with-github-actions.html)
- [Github Actions 自动构建 Docker 镜像](https://blog.isayme.org/posts/issues-55/)
