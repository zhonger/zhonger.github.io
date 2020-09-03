---
layout: post
title: 'ShareLaTeX搭建'
subtitle: '搭建一个属于自己的在线中英文LaTex编辑平台'
date: 2020-08-12 13:51:45 +0800
tags: 
- ShareLaTeX
- LaTex
- Ubuntu
categories: tech
cover: 'https://images.unsplash.com/photo-1569110462378-8bef8f4d9241?w=1600&q=900'
---

# LaTeX和ShareLaTex

LaTex是一种基于TEX的排版系统，在上世纪80年代初由美国计算机学家莱斯利·兰伯特发明。通过这种格式，即使对排版或者程序设计没有了解的人也可以利用TEX，在几天甚至几小时内生成很多具有书籍质量的印刷品。尤其对于有生成复杂表格和数学公式的科研人员来说，LaTex具有得天独厚的优势。因此在生成简单的信件、制作高印刷质量的技术类、学术类文档或书籍等方面，应用都非常广泛。

笔者在研究生初期撰写小论文的时候首次接触到LaTex。那个时候单纯是因为编写公式和生成参考文献比较方便，可以把时间和精力都集中在论文的内容上。刚开始学习LaTex的时候，安装编写环境是非常麻烦的。因为在本地安装的过程中，TEX会一个一个下载CTAN包。数量之大速度之慢，难以忍受。即使用上了国内高校的CTAN镜像源也颇为吃力。后来就接触到了ShareLaTex在线编辑器，只需要使用docker就可以很快部署一个完善的ShareLaTex服务，再也不用在本地安装半天了。正是由于ShareLaTex的优越性，overleaf在线编辑器向ShareLaTex伸出了橄榄枝，二者合二为一，为广大的LaTex用户带来了更好的LaTex在线编辑服务。当然合并之后，ShareLatex仍然在Github上以开源的方式回馈社区。

本文选择ShareLatex来部署在线LaTex编辑平台，还有一个非常重要的原因。就是ShareLaTex支持中日英文在内的多种语言，能很好地满足笔者在中日英三语上的需求。

# 搭建在线LaTex编辑平台


## 构建镜像

ShareLaTex官方提供的docker镜像就已经支持多种语言了，但是字体上比较缺少，毕竟官方镜像只能使用开源字体或者得到授权的字体。为了提供编写所需的字体，需要往官方docker镜像中加入自己需要的字体。编写一个如下的`Dockerfile`文件，用`docker build . -t zhonger/sharelatex`生成新的镜像。（PS：此处使用的字体包是windows本地打包得到，仅为个人学习使用，非为商用或公开提供服务）构建镜像之前可以自行准备好字体压缩包，压缩包内只需含有字体文件即可。


```dockerfile
FROM sharelatex/sharelatex:latest

LABEL maintainer "zhonger <zhonger@live.cn>"

RUN tlmgr option repository https://mirrors.ustc.edu.cn/CTAN/systems/texlive/tlnet && \
    tlmgr update --self --all && \
    tlmgr install scheme-full

RUN apt update && apt-get install xfonts-wqy -y && \
    wget -c https://ftp.dlcloud.info/linuxsoftware/winfonts.zip && \
    unzip winfonts.zip -d winfonts && \
    mv winfonts /usr/share/fonts/ && \
    cd /usr/share/fonts/winfonts && mkfontscale && mkfontdir && \
    fc-cache -fv && fc-list :lang=zh-cn

```

## 启动镜像

使用以下`docker-compose.yml`文件和`docker-compose up -d`命令完成docker镜像的实例启动。

```yaml
version: '2.2'
services:
    sharelatex:
        restart: always
        # Server Pro users:
        # image: quay.io/sharelatex/sharelatex-pro
        image: zhonger/sharelatex
        container_name: sharelatex
        depends_on:
            mongo:
                condition: service_healthy
            redis:
                condition: service_started
        ports:
            - 8070:80
        links:
            - mongo
            - redis
        volumes:
            - ./sharelatex_data:/var/lib/sharelatex
            ########################################################################
            ####  Server Pro: Un-comment the following line to mount the docker ####
            ####             socket, required for Sibling Containers to work    ####
            ########################################################################
            # - /var/run/docker.sock:/var/run/docker.sock
        environment:

            SHARELATEX_APP_NAME: oooooo ShareLaTeX

            SHARELATEX_MONGO_URL: mongodb://mongo/sharelatex

            # Same property, unfortunately with different names in
            # different locations
            SHARELATEX_REDIS_HOST: redis
            REDIS_HOST: redis

            ENABLED_LINKED_FILE_TYPES: 'url,project_file'

            # Enables Thumbnail generation using ImageMagick
            ENABLE_CONVERSIONS: 'true'

            # Disables email confirmation requirement
            EMAIL_CONFIRMATION_DISABLED: 'true'

            # temporary fix for LuaLaTex compiles
            # see https://github.com/overleaf/overleaf/issues/695
            TEXMFVAR: /var/lib/sharelatex/tmp/texmf-var

            ## Set for SSL via nginx-proxy
            #VIRTUAL_HOST: 103.112.212.22

            SHARELATEX_SITE_URL: https://ooooo.ooo
            SHARELATEX_NAV_TITLE: LEP自己的在线latex编辑分享平台
            # SHARELATEX_HEADER_IMAGE_URL: http://somewhere.com/mylogo.png
            SHARELATEX_ADMIN_EMAIL: zhonger@lep.ac.cn

            SHARELATEX_LEFT_FOOTER: '[{"text": "本平台由 <a href=\"https://www.sharelatex.com\">ShareLaTeX</a>强力驱动"} ]'
            SHARELATEX_RIGHT_FOOTER: '[{"text": "版权及最终解释权归oooooo所有"} ]'

            # SHARELATEX_EMAIL_FROM_ADDRESS: "team@sharelatex.com"

            # SHARELATEX_EMAIL_AWS_SES_ACCESS_KEY_ID:
            # SHARELATEX_EMAIL_AWS_SES_SECRET_KEY:

            # SHARELATEX_EMAIL_SMTP_HOST: smtp.mydomain.com
            # SHARELATEX_EMAIL_SMTP_PORT: 587
            # SHARELATEX_EMAIL_SMTP_SECURE: false
            # SHARELATEX_EMAIL_SMTP_USER:
            # SHARELATEX_EMAIL_SMTP_PASS:
            # SHARELATEX_EMAIL_SMTP_TLS_REJECT_UNAUTH: true
            # SHARELATEX_EMAIL_SMTP_IGNORE_TLS: false
            # SHARELATEX_CUSTOM_EMAIL_FOOTER: "<div>This system is run by department x </div>"

            ################
            ## Server Pro ##
            ################

            # SANDBOXED_COMPILES: 'true'

            # SANDBOXED_COMPILES_SIBLING_CONTAINERS: 'true'
            # SANDBOXED_COMPILES_HOST_DIR: '/var/sharelatex_data/data/compiles'
            # SYNCTEX_BIN_HOST_PATH: '/var/sharelatex_data/bin/synctex'

            # DOCKER_RUNNER: 'false'

            ## Works with test LDAP server shown at bottom of docker compose
            # SHARELATEX_LDAP_URL: 'ldap://ldap:389'
            # SHARELATEX_LDAP_SEARCH_BASE: 'ou=people,dc=planetexpress,dc=com'
            # SHARELATEX_LDAP_SEARCH_FILTER: '(uid={{username}})'
            # SHARELATEX_LDAP_BIND_DN: 'cn=admin,dc=planetexpress,dc=com'
            # SHARELATEX_LDAP_BIND_CREDENTIALS: 'GoodNewsEveryone'
            # SHARELATEX_LDAP_EMAIL_ATT: 'mail'
            # SHARELATEX_LDAP_NAME_ATT: 'cn'
            # SHARELATEX_LDAP_LAST_NAME_ATT: 'sn'
            # SHARELATEX_LDAP_UPDATE_USER_DETAILS_ON_LOGIN: 'true'

            # SHARELATEX_TEMPLATES_USER_ID: "578773160210479700917ee5"
            # SHARELATEX_NEW_PROJECT_TEMPLATE_LINKS: '[ {"name":"All Templates","url":"/templates/all"}]'


            # SHARELATEX_PROXY_LEARN: "true"

    mongo:
        restart: always
        image: mongo
        container_name: mongo
        expose:
            - 27017
        volumes:
            - ./mongo_data:/data/db
        healthcheck:
            test: echo 'db.stats().ok' | mongo localhost:27017/test --quiet
            interval: 10s
            timeout: 10s
            retries: 5

    redis:
        restart: always
        image: redis:5
        container_name: redis
        expose:
            - 6379
        volumes:
            - ./redis_data:/data

```

## 初始化平台

浏览器访问`http://服务所在计算机IP地址:8070/launchpad`创建超级管理员用户。创建成功后访问该页面就会被自动跳转到登录页。

至此，ShareLaTex在线编辑平台就搭建成功了。

# 后记

## 关于LaTex模板

要说LaTex模板的话，overleaf几乎涵盖了各式各样的模板，当然也包括中文书籍、中文PPT等优秀模板。欢迎访问[https://www.overleaf.com/latex/templates](https://www.overleaf.com/latex/templates)获取更多模板。访问模板的详细页，可以看到`Source`字样的按钮，点击即可查看模板源代码。如果是比较复杂的书籍等模板，最好是点击`Open as Template`按钮在overleaf上看到更多原始代码文件。

## 其他尝试

在构建镜像初期，笔者尝试了非ShareLaTex官方构建的docker镜像。因为镜像中CTEX没有完全安装，所以使用了以下命令来完善编写文档基础所需的CTAN包。毕竟这些包是有限个，时不时容易报出某个包缺失什么的错误，因而还是推荐大家采用上面的从ShareLaTex官方docker镜像开始做。

```bash
tlmgr option repository https://mirrors.ustc.edu.cn/CTAN/systems/texlive/tlnet
tlmgr update --self --all
tlmgr install etoolbox
tlmgr install setspace
tlmgr install comment
tlmgr install newtxtext
tlmgr install newtx
tlmgr install fontaxes
tlmgr install xkeyval
tlmgr install anyfontsize
tlmgr install xcolor
tlmgr install mwe
tlmgr install enumitem
tlmgr install caption
tlmgr install jknapltx
tlmgr install booktabs
tlmgr install multirow
tlmgr install fancyvrb
tlmgr install makecell
tlmgr install lipsum
tlmgr install hologo
tlmgr install xpatch
tlmgr install pgf
tlmgr install titlesec
tlmgr install apptools
tlmgr install appendix
tlmgr install manfnt
tlmgr install bbding
tlmgr install tcolorbox
tlmgr install environ
tlmgr install trimspaces
tlmgr install adforn
tlmgr install listings
tlmgr install footmisc
tlmgr install csquotes
tlmgr install fontspec
```