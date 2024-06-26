---
layout: post
title: '命令行工具开发指南——入门篇'
subtitle: '如何从零开始开发一款命令行工具'
date: 2024-05-29 17:15:00 +0900
categories: [tech, cli]
author: zhonger
cover: 'https://i.lisz.top/blog/ikfJSG.webp'
cover_author: 'Wolfgang Hasselmann'
cover_author_link: 'https://unsplash.com/@wolfgang_hasselmann'
tags: 
- command line
- 命令行
- develop
- 开发
- tool
- 工具
---

## 前言

&emsp;&emsp;**命令行工具**（Command Line，Cli）作为我们日常开发常用的辅助性工具，几乎遍布于各种操作中。根据**使用目的**的不同大致可以分为以下几类：

- **从模板中生成项目**：比如使用 `npm init` 从空模版创建一个新的 NodeJS 项目，使用 `composer create-project laravel/laravel example-app` 创建一个全新的 Laravel 项目（PHP 项目）等。
- **启用开发者服务模式**：比如使用 `python -m http.server 8000` 在 8000 端口开启一个临时 HTTP 服务器，使用 `bundle exec jekyll s` 在 4000 端口开启一个临时 Jekyll 服务器等。
- **特定功能交互**：比如流行的 IP 信息查询工具 [nali](https://github.com/zu1k/nali)、磁盘空间利用率和空余空间查询工具 [duf](https://github.com/muesli/duf)、快速磁盘使用分析工具 [gdu](https://github.com/dundee/gdu) 等。

&emsp;&emsp;其实任何编程语言都可以用来开发命令行工具，无论是常见的 Golang、Python、NodeJS、PHP、Java，还是 Rust、Ruby、C++、C 或者是古老的 Fortran 等。只是取决于所要实现的功能和具体的使用场景，开发者会采用合适的编程语言开发命令行工具。比如说，Linux 系统中包含了大量的命令行工具，基本上都是用 C 语言编写的，主要是因为 C 语言在 Linux 系统中的执行效率相对更高。对于一般高级编程语言，自带的包管理工具也是由自身高级编程语言编写的命令行工具。类似 Rust、Fortran 等编译型语言则需要通过编译生成**二进制可执行文件**后才能执行相应的任务。

> info "二进制可执行文件与源文件有何不同？"
> &emsp;&emsp; 二进制可执行文件是指源代码通过编译器编译成计算机可以直接识别的二进制码文件。二进制码文件是无法使用任何源码编辑器打开的，只能由操作系统调用执行或特别的二进制码查看器打开。一般来说，二进制可执行文件是很难跨越操作系统的，即针对不同的操作系统需要分别编译生成对应的二进制可执行文件。<u>尤其是当有其他静态库或者动态链接库依赖时，二进制可执行文件甚至无法跨主机运行</u>。 而源文件是可以在任何操作系统用源码编辑器打开的。大多时候商业公司为了保证源代码的商业版权，只会为用户提供应用的二进制可执行文件。（当然一般可能是包含图形用户界面的。）

## 为何命令行而非图形界面

&emsp;&emsp;命令行可以说是操作系统应用和编程语言编写应用最基本的形式，图形（用户）界面（Graphic User Interface，GUI）则是在源代码的基础上提供可视化的交互方式、通过键鼠操作来降低用户使用的门槛。这也是为什么 Windows 操作系统比 Linux 操作系统更加流行的原因之一。**但是有的时候，界面也有可能会成为用户学习和使用的累赘。**

### 简单界面 vs 复杂界面

&emsp;&emsp;就拿代码编辑器来说，我们所熟知的“宇宙第一编辑器” Visual Studio 几乎支持所有编程语言，尤其是对于构建 C# 项目来说可以**半代码半可视化修改**。尽管这在很大程度上降低了开发者使用成本，但是学习 Visual Studio 编辑器本身的成本却很高。（说句老实话，笔者从大学本科开始接触 Visual Studio 到现在都没怎么学会使用，😂只会最基本的功能而已。）而且，在普通笔记本电脑上使用 Visual Studio 编辑器运行大型项目时，CPU 和内存资源极大可能会被大量占用，打开一个浏览器页面可能也很艰难。

&emsp;&emsp;相比而言，同样由微软推出的 Visual Studio Code 则是简单界面的优秀代表。化繁为简，Visual Studio Code 本身仅支持最简单的功能：文件目录区、编辑区、终端区三部分布局，基本的代码高亮功能，插件功能，主题功能等。无论是 Python 开发者，还是 Golang 开发者，都能一打开直接上手，只是需要根据编程语言不同安装一些插件来提升开发效率而已。在系统占用资源方面，Visual Studio Code 比 Visual Studio 显著降低，尽管可能也会受安装插件的少量影响。当然有得也有舍，Visual Studio Code 中支持更多文件定义配置或命令行配置，对于没有学过 Linux 的用户可能会有点学习难度。

> info "Linux 哲学"
> &emsp;&emsp;“一切皆文件”。任何系统、项目、工具都是由一系列的文件组成的，通过配置文件可以实现直接管理。
>
> &emsp;&emsp;虽然这是 Linux 系统设计的哲学思想，但其实是所有操作系统设计的哲学思想，只是顶层封装的程度有所不同。Windows 系统也是“一切皆文件”的，不然那些编辑器的配置都存在哪里了呢。相比 Linux 和 MacOS 系统而言，Windows 系统的顶层封装程度最高，用户对于底层文件的直接管理非常少，尤其是对系统级别的配置管理只能通过图形界面交互完成。MacOS 系统则是介于两者之间，顶层封装程度虽然高但也提供对大部分系统级别配置的直接管理，即可以通过修改文件来实现管理。尽管依旧存在有些系统级别配置难以直接修改，比如说操作系统启动项。

### 更简单的命令行

&emsp;&emsp;界面在执行系列任务时一般需要多步操作，一顿点点点之后才能完成。当然如果图形界面和功能设计的比较合理的话，可能也只需要一步操作。当我们需要进行批量操作时，即使图形界面只需要一步操作，依旧需要一顿点点点。命令行则没有这种问题，只需要简单写个有循环的脚本即可循环调用命令行工具批量执行。

&emsp;&emsp;另外，命令行工具仅在执行时会占用系统资源，一旦完成即可完全释放。图形界面应用一般需要常驻后台，虽然优化得好的时候所占用的系统资源也可忽略不计，但是还是会有后台进程的。

&emsp;&emsp;尽管命令行工具极少会有显式的界面交互，但是也可以在终端提供非常丰富的命令行交互、功能解释、自动补全、自动建议等。用户使用起来一般没有太大问题，只需要调用子命令和参数即可实现操作。

## 命令行工具开发

### 设计标准和规范

&emsp;&emsp;命令行工具开发通常依据两个标准和规范进行：POSIX (Protable Operating System Interface，可移植操作系统接口) 标准和 GNU (GNU's Not Unix) 项目。POSIX 标准是 IEEE 为维护操作系统间适配性而制定的一系列标准，其中一个标准定义了命令行程序的语法和语义。GNU 旨在创建与 Unix 兼容的自由软件，其中一个子项目 [GNU Coreutils](https://www.gnu.org/software/coreutils/) 提供了很多常用的命令行程序，比如 `ls`、`cp` 和 `mv` 等。据此为命令行程序建立了以下的设计标准和规范：

- 单字母标志 (single-letter flag) 以一个短横线 `-` 开始，且可以合并使用：比如 `-d` (全称 `--debug`) 和 `-v` (全称 `--version`) 合并使用 `-dv` 来以调试模式输出命令行版本号。
- 长标志 (long flag) 以两个短横线 `--` 开始，但无法合并使用：比如 `--debug` 或 `--version` 可以被命令行正常解析，但 `--debugversion` 无法被正常解析。
- 选项 (Options) 跟在单字母标志后没有分隔符，但跟在长标志后使用等号 `=` 来分隔标志和选项值：比如 `-n example` 和 `--name=example` 分别为单字母标志和长标志的选项用法，二者完全等价。
- 参数 (Args) 跟在标志或选项之后时没有任何分隔符，仅有空格：比如 `curl -o out.html https://www.google.com` 中的 `https://www.google.com` 是参数，一般用法类似 `curl [Options] <Arg>`。
- 子命令 (Sub command) 与主命令之间没有分隔符，仅有空格：比如 `git commit` 中 `git` 是主命令、`commit` 是子命令。
- 单独的两个短横线 `--`（后不接标志）表示标志或选项的结束和参数的开始：比如 `rm -- -f` 中的 `-f` 表示的是要删除的文件 `-f`，而不是强制删除文件的选项。

> info "提示"
> &emsp;&emsp;按照以上设计标准和规范开发的命令行工具使用体验会与常用的命令保持一致，对于用户来说非常容易上手，这也是制定设计标准和规范的主要原因。

### 功能设计

&emsp;&emsp;核心功能设计主要是指命令行工具所支持的子命令、参数、选项设计。其中，子命令表示功能集合，参数表示输入输出变量，选项表示功能的微调。如下所示为笔者开发的命令行工具 [pictl](../../../tech/project/pictl.html) （基于 Python 语言开发）的帮助信息。目前提供四个子命令：`config`（配置基本信息），`compress`（压缩任意图片为 `webp` 格式）,`upload`（上传图片）和 `cup`（压缩并上传图片）。全局只支持 `-h`（`--help`）打印帮助信息和 `-V`（`--version`）打印版本信息两个选项。

```bash
╰─$ pictl
Usage: pictl [OPTIONS] COMMAND [ARGS]...

  A command line tool for image processing and uploading (ex. S3-type).

  Now it supports:
    - transformation from other image types to `webp` image as well as
      image compression.
    - image file uploading to AWS S3 or Cloudflare R2.

Options:
  -V, --version  Show the pictl version.
  -h, --help     Show this message and exit.

Commands:
  compress  Compress any image into `webp` image.
  config    Operations for the config file `~/.pictlrc`.
  cup       Compress image and upload to remote storage (compress and...
  upload    Upload the file to remote storage.
```

#### 子命令

&emsp;&emsp;**子命令是否越少越好或者越多越好？亦或是不多不少比较好？**其实，根据实际功能需求的不同子命令的数量会有很大的差异。比如上面提到的 pictl 目前所支持的子命令只有 4 个，curl 不支持子命令但支持选项超过 20 个，git 支持的常用子命令多达 22 个（如下所示，实际子命令可能接近 100 个），docker 支持的子命令超过 30 个。子命令实际上是可以多层迭代调用的，即可以存在多层级。但是在功能设计时，一般将对同一对象操作的功能归类到同一子命令下面，形成多层级子命令。当然为了简化子命令的层级调用，最多的实践方式就是类似于 git 中的**用选项来代替多层的子命令**。比如 `git branch` 子命令是对分支（branch）的列举（`git branch -l`）、创建（`git branch <name>`）和删除（`git branch -d <name>`）的功能集合。

```bash
╰─$ git -h
usage: git [-v | --version] [-h | --help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           [--super-prefix=<path>] [--config-env=<name>=<envvar>]
           <command> [<args>]

These are common Git commands used in various situations:

start a working area (see also: git help tutorial)
   clone     Clone a repository into a new directory
   init      Create an empty Git repository or reinitialize an existing one

work on the current change (see also: git help everyday)
   add       Add file contents to the index
   mv        Move or rename a file, a directory, or a symlink
   restore   Restore working tree files
   rm        Remove files from the working tree and from the index

examine the history and state (see also: git help revisions)
   bisect    Use binary search to find the commit that introduced a bug
   diff      Show changes between commits, commit and working tree, etc
   grep      Print lines matching a pattern
   log       Show commit logs
   show      Show various types of objects
   status    Show the working tree status

grow, mark and tweak your common history
   branch    List, create, or delete branches
   commit    Record changes to the repository
   merge     Join two or more development histories together
   rebase    Reapply commits on top of another base tip
   reset     Reset current HEAD to the specified state
   switch    Switch branches
   tag       Create, list, delete or verify a tag object signed with GPG

collaborate (see also: git help workflows)
   fetch     Download objects and refs from another repository
   pull      Fetch from and integrate with another repository or a local branch
   push      Update remote refs along with associated objects

'git help -a' and 'git help -g' list available subcommands and some
concept guides. See 'git help <command>' or 'git help <concept>'
to read about a specific subcommand or concept.
See 'git help git' for an overview of the system.
```

&emsp;&emsp;功能设计中对子命令的设计是由核心功能驱动的。在条件允许的情况下，尽可能压缩子命令列表是有利于用户上手使用的。为了命令行工具使用时命令不会过长，建议提供比较常用的默认选项值从而减少用户自定义的可能性。当然，对全部选项的单字母标志支持也是有效缩短命令长度的方法之一。除此之外，提供配置文件也是非常可取的方法。`git`、`curl`、`wget`、`docker` 等都提供对应的配置文件 `.gitconfig`、`.curlrc`、`.wgetrc` 和 `.dockerrc` 进行全局配置定义，当然 `pictl` 也提供 `.pictlrc` 配置文件。

#### 代码架构

&emsp;&emsp;尽管不同编程语言因为自身原因（编译型或解析型语言，面向对象或面向过程等），可能会有不同的代码架构偏好，我们可能依然可以采用一个宽泛且可行的通用代码架构思路------**面向功能开发**。这里的功能可以是一个操作或者一个对象，比如说压缩图片这样一个功能，主要是将输入图片转换成想要的图片格式输出。除此之外，可能还可以提供压缩质量控制、尺寸控制、自动重命名、自动加水印等微调功能。这些微调功能虽然实际上可以完全独立，但由于是压缩图片功能的附属功能，最好采用选项调用的方式来实现。代码架构上，子命令调用对应的函数会成为**顶级函数**。其他微调功能虽然是独立函数或对象，<u>但仅在子命令函数中被调用</u>。实际开发过程中，微调功能并非一开始就包括所有，大部分会作为一些特性逐步增加到主代码中。这意味着，对用户来说新增一个微调功能仅仅多了一个子命令下的选项支持，不需要重新学习和适应。

&emsp;&emsp;如果压缩图片功能的基础（图片转换）需要自行编写代码，那么可能需要考虑到很多种图片格式的相互转换，这在具体代码实践中是非常麻烦的。比较可行的方法之一是，可以采用一种图片格式作为中间标准格式，每次新增一种图片格式的支持只需要增加与中间标准格式的相互转换即可。当然这里采用的中间标准格式可能是需要高保真的（或者高分辨率的），避免在用了中间标准格式转换之后图片质量自动下降。

### 错误处理和自动建议

&emsp;&emsp;当我们打算开发一款命令行工具时，除了核心功能是必不可少的，错误处理和自动建议也是需要考虑在内的。了解这点最简单的办法就是从实例中学习。如下所示，是将 git 提交修改（commit）的命令 `git commit` 故意打成为 `git commi` 的输出结果。

```bash
╰─$ git commi
git: 'commi' is not a git command. See 'git --help'.

The most similar commands are
 commit
 column
 config
```

&emsp;&emsp;当命令行工具接收到用户输入时，首先需要做的就是对输入的合法性进行验证：一方面，是否存在不可用的子命令或非法使用（比如错误迭代调用）；另一方面，尝试解析参数并验证完整性。这两部分的验证会尽可能地将错误的原因和可能有用的建议提示给用户。类似上面，命令行工具会提示用户使用的子命令不存在，请使用 `git --help` 了解更多。另外，会将输入的子命令字符串与所有合法的子命令字符串进行对比，根据相似性大小排列向用户自动建议。至于对选项的解析相对来说可以比较宽容一点，即直接忽略不合法的选项声明、仅读取合法的选项声明，因此可以不返回相关错误提醒及帮助。

&emsp;&emsp;当子命令、参数、选项均通过验证之后，命令行工具的功能代码执行时也会发生错误。如下所示，在一个非 git 项目文件夹内执行 `git commit` 时，命令行工具会将具体的错误直接提示：当前目录或任何父目录不是一个 git 项目，不存在 `.git` 文件夹。这里需要注意的是，通常我们可能对错误或异常的处理会直接使用编程语言本身提供的方式，比如 Python 语言中的 `raise ValueError("'element' parameter is not defined.")`。当然这种错误处理本身没有任何问题，只不过同时还会输出错误发生的代码位置等其他与用户使用无关的信息，尽管这种信息在开发过程中有利于开发者调试代码。出于为用户考虑，错误处理信息默认应该以简单可读的方式打印出来、且仅限于提示关键信息。如果用户或者开发者想要了解更多，可以通过 `-v` 或者 `--verbose` 选项来打印更多调试信息。

```bash
╰─$ git commit
fatal: not a git repository (or any of the parent directories): .git
```

> info "-v 和 -V"
> &emsp;&emsp;通常来说，`-v`（`--verbose`）和`-V`（`--version`）会被认为是不同的选项，分别用于开启调试模式和打印版本信息。当用户发现命令行工具使用出现不可预知的问题（错误提示与实际原因不符或其他不在开发者知晓范围内的问题）时，需要开启调试模式来排除本地环境的问题，同时也可能在向开发者反馈问题时提供足够的信息来帮助定位问题的原因。版本信息通常也是提交反馈问题时所需的必要信息。

### 技术选型

&emsp;&emsp;技术选型指的是**用哪种编程语言以及哪种框架来实现命令行工具**。**第一种**是从开发者自身熟悉和掌握的编程语言出发，尽可能降低编程语言上的学习成本。不过对于已经掌握一门或多门编程语言的开发者来说，学习新编程语言可能也不是件难事。**第二种**是从应用场景出发：如果是开发为机器学习应用的前置或后置步骤的数据准备、数据处理、可视化等功能的命令行工具，采用 Python 语言可能会更加方便有效；如果是开发包含与操作系统交互的网络分析、磁盘分析等功能的命令行工具，采用 Rust 或者 Golang 语言可能会比较得心应手；如果是开发与平台接口交互（如 Web API 调用）的命令行工具，采用 NodeJS 语言可能适配性更佳。详细请查看参考资料 [1-5]。

## 结语

&emsp;&emsp;诚然，命令行工具并非是所有用户的喜爱，但的确是最小化操作步骤、提升效率的方式之一。以上所述的命令行工具开发指南入门篇大部分是在理论层面上的，至于在不同编程语言上的实践后续也计划展开：

- 《命令行工具开发指南 —— Python 实践篇》
- 《命令行工具开发指南 —— Rust 实践篇》
- 《命令行工具开发指南 —— Golang 实践篇》
- 《命令行工具开发指南 —— NodeJS 实践篇》

&emsp;&emsp;有关于命令行工具开发进阶的依赖管理、编译构建、信号和日志处理、用户输入验证、自动补全（Auto Completion）、文档、测试和发布等也将在实践篇中分别具体阐述。

## 参考资料

1. [快手数平前端团队 -- 掌握 Node CLI 工具开发，为团队研发提效！](https://juejin.cn/post/7178666619135066170)
2. [阮一峰的网络日志 -- Node.js 命令行程序开发教程](https://www.ruanyifeng.com/blog/2015/05/command-line-with-node.html)
3. [Rust 中的命令行应用](https://suibianxiedianer.github.io/rust-cli-book-zh_CN/README_zh.html)
4. [命令行应用 - Python 最佳实践指南](https://pythonguidecn.readthedocs.io/zh/latest/scenarios/cli.html)
5. [Tony Bai -- Go 开发命令行程序指南](https://tonybai.com/2023/03/25/the-guide-of-developing-cli-program-in-go/)
6. [Wikipedia -- POSIX](https://en.wikipedia.org/wiki/POSIX)
