---
layout: post
title: 'JupyterLab 的搭建与运维'
subtitle: '多实例多用户的 Jupyterhub'
date: 2021-07-25 07:20:00 +0800
tags: 
- JupyterLab
- Docker
- Gitlab
categories: [tech, docker]
cover: 'https://images.unsplash.com/photo-1624258012762-6c0fc69cccf5?w=1600&q=900'
---

## 前言

&emsp;&emsp;[Jupyter](https://jupyter.org/)， 想必大家对这个项目都耳熟能详吧。因为能够实时交互、支持异构计算、部署简单、几乎无运维成本，所以得到了很多人的青睐。笔者的身边也有很多从事科学研究的人选择了 Jupyter 作为编写 Python 的工具，当然也有一部分人选择了 [PyCharm](https://www.jetbrains.com/pycharm/)。不过笔者还是比较喜欢 [VS Code](https://code.visualstudio.com/)，简单的纯文本编辑功能，利用丰富的插件市场来添加各种想要的功能，无缝支持远程开发，简直就是理想中的编辑器了。但是，今天还是要来考虑一下 Jupyter，毕竟 JupyterLab 的服务功能也是非常强大的。

&emsp;&emsp;在 Jupyter 出现之前，也有可以替代 Python 自带的 Python Shell 的 [IPython](https://ipython.org/)。笔者在早期也曾使用过，体验还不错。其实，Jupyter 就是2014 年从 IPython 中衍生出来的，所以从 IPython 过渡到 Jupyter 毫无困难。如果说 IPython 是为了 Python 而量身定制的话，那么 Jupyter 则是为包括 Julia、Python、R 在内的几十种编程语言（[详情连接](https://github.com/jupyter/jupyter/wiki/Jupyter-kernels)）的交互式数据科学和科学计算而生的。

&emsp;&emsp;早期的 Jupyter 只包含 Jupyter Kernels 和 Jupyter Notebook，其中 Jupyter Kernels 是用于支持编程语言的内核，Jupyter Notebook 是基于 Web 的交互式计算环境，前身是 IPython Notebook。现在的 Jupyter 除了这两者以外还有 JupyterHub、JupyterHub API 和 JupyterLab。JupyterHub 是一个用于 Jupyter Notebook 的多用户服务器。它通过生成、管理和代理许多单一的 Jupyter Notebook 服务器来支持多用户。JupyterHub API 是以 REST 风格向开发者们提供的 API 接口，可以完成一系列对 Jupyter 的操作，比如生成用户环境、配置环境等。JupyterLab 号称是 Jupyter 项目的下一代用户界面，它以一个灵活且强大的用户界面向用户提供经典的 Jupyter Notebook、终端、编辑器、文件浏览器、丰富输出等模块，俨然像是朝着现代化的理想编辑器的目标进发的。

&emsp;&emsp;无论之前的 Jupyter 是什么样子，现在的 JupyterLab 已经是和曾经的 Cloud9 （一款先进的在线代码编辑器，现已被 AWS 收购）一样的支持多用户多实例的代码运行平台。对于从事科学研究的团队来说，使用 JupyterLab 搭建一个内部科学计算平台成为了可能。当然，个人用户还是可以选择使用 Anaconda 或者 PIP 来安装单用户版本。

## 搭建

&emsp;&emsp;说到搭建平台自然而然想到了使用 Docker，既可以保证用户对自己所需的软件或环境可以修改，又保证不同用户之间互不干扰、宿主机与 Jupyter 之间互不干扰。虽说 Jupyter 官方提供了一个使用 Docker 来部署 Jupyter 各个产品的 [文档网站](https://jupyter-docker-stacks.readthedocs.io/)，但不得不说即使看了这个文档也很难搞清楚到底怎么部署一套 JupyterLab。可能唯一有用的就是 Jupyter 官方提供的镜像构建 [Dockerfile 集合](https://github.com/jupyter/docker-stacks) 吧。

&emsp;&emsp;JupyterLab 提供两种方式启动多用户多实例：

- **DockerSpawner 方式**：每个用户独享一个 Docker 实例，能有效隔离用户。
- **SystemSpawner 方式**：共享同一个 Docker 实例，以系统用户身份运行。

&emsp;&emsp;事实上，既然我们选择了用 Docker 来部署，自然而然应该选择 DockerSpawner 方式了。JupyterLab 中主要实现多用户多实例功能的是 JupyterHub 模块（如下图）。JupyterHub 模块为整个 JupyterLab 对外提供了一个共同的 HTTP 接口，并可以进行用户鉴权和为通过鉴权的用户创建一个新的 Docker 实例。笔者在这里主要是使用 Gitlab 方式鉴权登录，图中涉及到 Admin 以及数据库这里不作探讨。

![架构图 JupyterHub Design](https://i.lisz.top/blog/Uibi3q.webp)

&emsp;&emsp;以下为搭建所需的文件的列表：

![文件列表 Files](https://i.lisz.top/blog/tU3EqP.webp)

### 构建 Jupyter Notebook 实例镜像

#### 基础镜像 base-notebook

&emsp;&emsp;这里的基础镜像可以根据需要自行选择，与 [jupyter/docker-stacks](https://github.com/jupyter/docker-stacks/tree/master/base-notebook) 相比镜像构建 Dockerfile 有些内容做了修改，本目录下其他文件和 [base-notebook 目录](https://github.com/jupyter/docker-stacks/tree/master/base-notebook) 一致。

```dockerfile
# Dockerfile
ARG ROOT_CONTAINER=nvidia/cuda:10.2-devel-ubuntu18.04

ARG BASE_CONTAINER=$ROOT_CONTAINER
FROM $BASE_CONTAINER

ARG NB_USER="ubuntu"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -yq --no-install-recommends wget htop vim bzip2 ca-certificates sudo locales fonts-liberation run-one \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Copy a script that we will use to correct permissions after running certain commands
COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER wtih name ubuntu user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su \
    && sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers \
    && sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers \
    && useradd -m -s /bin/bash -N -u $NB_UID $NB_USER -g $NB_GID \
    && mkdir -p $CONDA_DIR \
    # && chown $NB_USER:$NB_GID  \
    && chmod g+w /etc/passwd \
    && fix-permissions $HOME \
    && fix-permissions $CONDA_DIR \
    && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD : ALL" | tee /etc/sudoers.d/nopasswd4sudo

USER $NB_UID
WORKDIR $HOME
ARG PYTHON_VERSION=default

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

# Install conda as ubuntu and check the md5 sum provided on the download site
ENV MINICONDA_VERSION=4.9.2 \
    MINICONDA_MD5=122c8c9beb51e124ab32a0fa6426c656 \
    CONDA_VERSION=4.9.2

WORKDIR /tmp
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh  \
    && echo "${MINICONDA_MD5} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c -  \
    && /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR \
    && rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh \
    && echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && conda config --system --set channel_priority strict \
    && if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi \
    && conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned \
    && conda install --quiet --yes conda \
    && conda install --quiet --yes pip \
    && conda update --all --quiet --yes \
    && conda clean --all -f -y \
    && rm -rf /home/$NB_USER/.cache/yarn \
    && fix-permissions $CONDA_DIR \
    && fix-permissions /home/$NB_USER

# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' \
    && conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned \
    && conda clean --all -f -y \
    && fix-permissions $CONDA_DIR \
    && fix-permissions /home/$NB_USER

# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN conda install --quiet --yes \
    'notebook=6.4.0' \
    'jupyterhub=1.4.2' \
    'jupyterlab=3.0.16' \
    && conda clean --all -f -y \
    && npm install -g npm@7.20.0 \
    && npm cache clean --force \
    && jupyter notebook --generate-config \
    && rm -rf $CONDA_DIR/share/jupyter/lab/staging \
    && rm -rf /home/$NB_USER/.cache/yarn \
    && fix-permissions $CONDA_DIR \
    && fix-permissions /home/$NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/
RUN chmod +x /usr/local/bin/start-notebook.sh /usr/local/bin/start-singleuser.sh /usr/local/bin/start.sh

# Switch back to ubuntu to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME
```

```bash
docker build -t base-notebook:latest .
```

#### 单用户镜像 singleuser

```yaml
# Dockerfile
ARG BASE_IMAGE=base-notebook:latest
FROM $BASE_IMAGE

ADD install_jupyterhub /tmp/install_jupyterhub
ARG JUPYTERHUB_VERSION=master
# install pinned jupyterhub and ensure notebook is installed
RUN true && \
    python3 -m pip install notebook jupyterhub
```

&emsp;&emsp;install_jupyterhub 脚本文件

```python
#!/usr/bin/env python
import os
from subprocess import check_call
import sys

V = os.environ['JUPYTERHUB_VERSION']

pip_install = [
    sys.executable, '-m', 'pip', 'install', '--no-cache', '--upgrade',
    '--upgrade-strategy', 'only-if-needed',
]
if V == 'master':
    req = 'https://github.com/jupyterhub/jupyterhub/archive/master.tar.gz'
else:
    version_info = [ int(part) for part in V.split('.') ]
    version_info[-1] += 1
    upper_bound = '.'.join(map(str, version_info))
    vs = '>=%s,<%s' % (V, upper_bound)
    req = 'jupyterhub%s' % vs

check_call(pip_install + [req])
```

```bash
docker build -t singleuser:latest .
```

#### JupyterLab 单用户镜像 jupyter_lab_singleuser

```dockerfile
ARG BASE_IMAGE=singleuser:latest
FROM ${BASE_IMAGE}

# Install jupyterlab
RUN conda update -n base conda \
    && conda install -c conda-forge jupyterlab
RUN jupyter serverextension enable --py jupyterlab --sys-prefix
USER root
RUN chpasswd <<< "ubuntu:ubuntu" \
    && sed -i 's/http:\/\/archive.ubuntu.com/https:\/\/mirrors.sjtug.sjtu.edu.cn/g' /etc/apt/sources.list \
    && apt update \
    && apt install -y git zsh vim \
    && usermod -s /bin/zsh ubuntu \
    && echo 'chown -R ubuntu:users /home/ubuntu/work' >> /usr/local/bin/start-notebook.sh

# Add supports for zsh and zh-CN language
USER ubuntu
RUN git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh \
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && sed -i "s/robbyrussell/bira/" ~/.zshrc \
    && wget -c https://jfds-1252952517.cos.ap-chengdu.myqcloud.com/jupyterhub/jupyterlab_language_pack_zh_CN-0.0.1.dev0-py2.py3-none-any.whl \
    && pip install jupyterlab_language_pack_zh_CN-0.0.1.dev0-py2.py3-none-any.whl \
    && rm jupyterlab_language_pack_zh_CN-0.0.1.dev0-py2.py3-none-any.whl
```

```bash
docker build -t jupyter_lab_single:latest .
```

### 构建 JupyterHub 镜像

```dockerfile
# Dockerfile

ARG BASE_IMAGE=jupyterhub/jupyterhub:latest
FROM ${BASE_IMAGE}

RUN pip install --no-cache --upgrade jupyter \
    && pip install --no-cache dockerspawner \
    && pip install --no-cache oauthenticator
EXPOSE 8000
```

&emsp;&emsp;这里配置挂载的本地目录为根据用户名而区分的目录，当 Gitlab 用户名中包含 `-` 时，`-` 会被转义为 `2d`。另外，这里的本地目录需要预先建立好，否则由于 Docker 自身的安全性而新建立的目录的所有者会是 root 用户，这样就不能够正常使用该目录。以下配置文件需放置在 docker-compose.yml 的同层目录 data 里面。

```python
# jupyterhub_config.py

import os
from oauthenticator.gitlab import GitLabOAuthenticator
c.JupyterHub.authenticator_class = GitLabOAuthenticator
c.GitLabOAuthenticator.oauth_callback_url = os.getenv("GITLAB_OAUTH_CALLBACK")
c.GitLabOAuthenticator.client_id = os.getenv("GITLAB_API_CLIENT")
c.GitLabOAuthenticator.client_secret = os.getenv("GITLAB_API_KEY")

c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.DockerSpawner.image = 'jupyter_lab_singleuser:latest'
c.DockerSpawner.environment = {
  'GRANT_SUDO': '1',
  'UID': '0',
}
c.DockerSpawner.extra_create_kwargs = {'user': 'ubuntu'}
c.DockerSpawner.extra_create_kwargs.update({ 'command': "start-singleuser.sh --SingleUserNotebookApp.default_url=/lab" })
# Mount the real user's Docker volume on the host to the notebook user's
# notebook directory in the container
notebook_dir = '/home/ubuntu/work'
c.DockerSpawner.notebook_dir = notebook_dir
c.DockerSpawner.volumes = { '/home/data/jupyterhub/user-data-{username}': notebook_dir }
c.DockerSpawner.args = ['--allow-root']
c.DockerSpawner.remove_containers = True

#network
network_name = 'jupyterhub_network'
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name
# Pass the network name as argument to spawned containers
c.DockerSpawner.extra_host_config = { 'network_mode': network_name }

# IP Configurations
c.JupyterHub.hub_ip  = '172.18.0.2'
#c.JupyterHub.port = 8000
```

```yaml
version: '2'
services:
    jupyterhub:
        container_name: jupyterlab
        restart: always
        build: ./
        image: jupyterhub:latest
        ports:
            - "8000:8000"
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - ./data/jupyterhub_config.py:/srv/jupyterhub/jupyterhub_config.py
        networks:
            network:
                ipv4_address: 172.18.0.2
        environment:
            - GITLAB_HOST=https://{Gitlab Domain}
            - GITLAB_API_CLIENT=xxxxxx
            - GITLAB_API_KEY=xxxxxx
            - GITLAB_OAUTH_CALLBACK=https://{JupyterHub Domain}/hub/oauth_callback
networks:
    network:
        driver: bridge
        ipam:
            driver: default
            config:
                - subnet: 172.18.0.0/24
                  gateway: 172.18.0.1
```

```bash
docker-compose up -d
```

## 测试

&emsp;&emsp;访问 `https://{JupyterHub Domain}/` 即可，点击登录按钮后跳转到 Gitlab 登录页，如果 Gitlab 已登录会自动跳回。

## 参考资料

- [Jupyter - 维基百科](https://zh.wikipedia.org/wiki/Jupyter)
- [JupyterLab 3.0 正式发布，同时解决中文语言包下载不成功，汉化不成功的问题，jupyterlab-language-pack-zh-CN 安装失败解决方案](http://zsduo.com/archives/244.html)
- [Jupyterlab 安装中文语言包失败](https://cyfeng.science/2021/01/15/jupyterlab-error-when-install-chinses-language-pack/)
- [使用JupyterHub向多用户提供jupyter服务的思路](https://zhuanlan.zhihu.com/p/258724435)
- [dockerspawner, 在 Docker 容器中，生成JupyterHub单用户服务器](https://www.kaifa99.com/GitHub/article_117797)
