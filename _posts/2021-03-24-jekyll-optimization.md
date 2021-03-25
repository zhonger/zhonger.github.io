---
layout: post
title: 'Jekyll 优化合集'
subtitle: '为 Jekyll 添加更多的功能支持'
date: 2021-03-24 10:10:00 +0800
tags: 
- Jekyll
- Plugins
- 优化
- fancybox
- prism
categories: webmaster
cover: 'https://images.unsplash.com/photo-1550408483-bafa35b0a433?w=1600&q=900'
---

## 前言

&emsp;&emsp;Jekyll 是一款采用 Ruby 语言编写的、非常方便简单又功能强大的静态站点生成器，适合于搭建个人博客、静态网站等。我们知道，Github Page 默认支持的也是 Jekyll，而非 Hexo、Hugo等静态站点生成器。Hexo 是用 NodeJS 语言编写的，Hugo 是用 Go 语言编写的，它们三者背后其实都有非常丰富的插件来增强它们自身，从而为用户提供一个可插拔式的个人定制功能。由于本站目前是采用 Jekyll 来搭建的，所以为了提供给读者更加高效的阅读条件，笔者在廖柯杰大佬开发的 [H2O](https://github.com/kaeyleo/jekyll-theme-H2O) 主题的基础上做了一些功能上的增加和优化，接下来就来详细介绍一下。


## 功能需求

- 原有的 Rouge 代码高亮支持的语言种类较少、代码主题有限；
- 由于主题的文章模板限制了文字宽度在适合阅读的 30 字左右，图片尺寸相应也受到了限制，无法放大和集中观看；
- 主题提供的首页是文章卡片，对于学术研究的个人博客来说学术首页显得更加重要；
- 主题不提供简单的文章标题和发表时间的列表页，对于读者来说有些文章可能需要翻好几页才能找到，不是很方便。虽然标签有标签分类，但是因为存在大量重复也不是很方便；
- 如果想要将文章整理成一个系列或者专题，恐怕比较困难，只能通过建立单独的页面和编写代码的方式生成列表。

## 实现

### 代码高亮

&emsp;&emsp;Jekyll 代码高亮可以使用 Pygments、Rouge、Prism、Highlight JS等工具实现，据说大部分的高亮博客中基本上都是使用 Pygments。从 Pygments 的名字也可以看出来，这款工具是 Python 语言编写的，因此编译时是需要 Ruby 和 Python 两种语言环境的。不过除此之外，它的配置还是比较简单的。

#### Pygments

首先在 Gemfile 中配置下面行，以便安装好对应的插件模块。

```bash
gem install pygments.rb
```

然后是修改 _config.yml 配置文件，其中的 highlighter 修改如下：

```yaml
markdown: kramdown
highlighter: pygments
```

之后不要忘记要引入 Pygments 的 CSS 样式，可以直接访问以下地址下载：

```bash
https://pygments.org/_static/pygments.css
```

不过也是可以引入其他主题的 CSS 样式的。

#### Rouge

&emsp;&emsp;Rouge 是 Jekyll 也是 H2O 主题默认的代码高亮工具，支持的语言与其他工具相比都要少一些。因为 Rouge 本身是用 Ruby 语言编写的，所以编译时只需要 Ruby 环境。另外，Rouge 的主题和 Pygments 是完全兼容的，所以如果是从 Pygments 变到 Rouge，只需要在 _config.yml 配置文件做如下修改即可：

```yaml
markdown: kramdown
highlighter: rouge
```

#### Prism

本站所采用的代码高亮就是 Prism，选择 Prism 的原因主要有三点：
- Prism 生成代码比较简洁，没有多余代码，颜色在不同网站主题上都试用；
- 支持的高亮编程语言丰富，虽然在某些地方还是有所瑕疵，但是总体上还是很实用；
- 高亮主题基本上现有的都能用，本站所用的就是 Github 官方同款主题。

&emsp;&emsp;Prism 工具的安装使用相较其他两种稍微复杂一点，需要下载插件 prism.rb 手动安装到 _plugins 文件夹中，然后在文章模板页添加 prism.css 和 prism.js 的引入（下面花括号中间的反斜杆是为了是花括号不被解析而直接显示出来，使用时请删除反斜杠）。

```ruby
# prism.rb

module Jekyll

    class PrismBlock < Liquid::Block
      include Liquid::StandardFilters
  
      OPTIONS_SYNTAX = %r{^([a-zA-Z0-9.+#-]+)((\s+\w+(=[0-9,-]+)?)*)$}
  
      def initialize(tag_name, markup, tokens)
        super
        if markup.strip =~ OPTIONS_SYNTAX
          @lang = $1
          if defined?($2) && $2 != ''
            tmp_options = {}
            $2.split.each do |opt|
              key, value = opt.split('=')
              if value.nil?
                value = true
              end
              tmp_options[key] = value
            end
            @options = tmp_options
          else
            @options = { "linenos" => "" }
          end
        else
          raise SyntaxError.new("Syntax Error in 'prism' - Valid syntax: prism <lang> [linenos(='1-5')]")
        end
      end
  
      def render(context)
        code = h(super).strip
  
        if @options["linenos"] == true
          @options["linenos"] = "1-#{code.lines.count}"
        end
  
        <<-HTML
  <div>
    <pre data-line='#{@options["linenos"]}'><code class='language-#{@lang}'>#{code}</code></pre>
  </div>
        HTML
      end
    end
  
  end
  
  Liquid::Template.register_tag('prism', Jekyll::PrismBlock)
```

```html
<!-- _includes/post-head.html -->
<head>
    ......
    <link href="{\{ site.baseurl }}/assets/css/prism.css" rel="stylesheets" />
</head>

<!-- _layouts/post.html -->
<body>
    ......
    <script src="{\{ site.baseurl }}/assets/js/prism.js"></script>
</body>

<!-- 或者使用 CDN 加载 -->

<!-- _includes/post-head.html -->
<head>
    ......
    <link href="https://cdn.jsdelivr.net/npm/prismjs/themes/prism.css" rel="stylesheets" />
</head>

<!-- _layouts/post.html -->
<body>
    ......
    <script src="https://cdn.jsdelivr.net/npm/prismjs/prism.js"></script>
</body>

```

### 图片放大和图集

&emsp;&emsp;在实际的文章阅读过程中，往往是文字和图掺杂在一起才能做到图文并茂，因此在博客文章中也会出现需要放大查看图看得更清楚的时候，甚至说只浏览图，这就需要有图片放大和图集功能的帮助了。帮助 Jekyll 实现这一点的 JS 工具也有很多，比如 fancybox、lightgallery 等等，本站所采用的是 fancybox。实现步骤主要就是两步，一是添加好 CSS 和 JS 文件引入，二是添加一个声明，如下所示：

```html
<!-- _includes/post-head.html -->
<head>
    ......
    <link href="https://cdn.jsdelivr.net/npm/fancybox/dist/css/jquery.fancybox.css" rel="stylesheets" />
</head>

<!-- _layouts/post.html -->
<body>
    ......
    <script src="https://cdn.jsdelivr.net/npm/jquery/dist/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/fancybox/dist/js/jquery.fancybox.cjs.min.js"></script>
    <script>
        // 给图片添加链接
        $(document).ready(function() {
            $("p img").each(function() {
                var strA = "<a data-fancybox='gallery' ref='gallery1' href='" + this.src + "'></a>";
                $(this).wrapAll(strA);
            });

            $('[data-fancybox="gallery"]').fancybox();
        });
    </script>
</body>
```

这里使用的是默认配置，想要更多定制可以移步 [fancybox 官网](http://fancyapps.com/fancybox/3/docs/#options)。

### 学术首页

&emsp;&emsp;所谓的学术首页功能其实就是将原来的首页移到 blog 子目录下，首页用一个自定义的页面来替代。由于 H2O 主题本身很适合转换成一个页面模板，要实现这一功能比较方便。

#### 移动默认首页

&emsp;&emsp;这里想要移动的子目录可以使用任何与已有文件夹不重名的文件夹名，建议使用 blog，这样语义理解上比较方便。另外值得注意的是，因为原来的文章首页发生了移动，搜索使用的 search.json 配置文件也要复制一份，这样能同时保证不同目录下的搜索功能。

```bash
mkdir blog
mv index.html blog/index.html
cp search.json blog/search.json
```

#### 添加页面模板

&emsp;&emsp;因为页面模板内容在页面上会被翻译导致无法正常显示，这里就使用了 Github 提供的 gist 代码片段服务。如下所示，添加一个页面模板到 _layouts 目录。

<script src="https://gist.github.com/zhonger/7b60d2fcc3b6649131fe389ca1148440.js?filename=page.html"></script>


#### 编写学术首页

&emsp;&emsp;修改 dev/sass/common.scss 文件和 index.md 文件。注意，这里的样式文件需要经过编译才能生效。编译需要在 NodeJS 环境下使用 `npm install & gulp` 命令。为了加快网页访问，学术首页中的图建议使用 webp 格式。（反斜杠请删除）

```css
/* common.scss */

.interest {
    width: auto;
    height: 40px;
    display: inline-block !important;
    margin: 0 20px 0 0 !important;
}
```

```md
<!-- index.md -->

---
layout: page
home-title: Welcome to zhonger's blog!
description: Writing, writing, writing ...
---

# About me

&emsp;&emsp;I'm xxx.

# Interests

<img src="{\{ site.baseurl }}/assets/icons/kvm.webp" alt="KVM" class="interest">

# Educations

- XXX University (China), XXX, Bachelor degree. (20xx/09~20xx/06)

# Publications

1. **S Li**, H Zhang, D Dai, G Ding, X Wei, Y Guo. Study on the factors affecting solid solubility in binary alloys: An exploration by Machine Learning[J]. *Journal of Alloys and Compounds*, 2019, 782: 110-118.[[DOI]](https://doi.org/10.1016/j.jallcom.2018.12.136) 

# Contact

Email: zhonger[at]live.cn (Please replace [at] with @.)


# 关于我

&emsp;&emsp;我是XXX。

# 研究兴趣

<img src="{{ site.baseurl }}/assets/icons/kvm.webp" alt="KVM" class="interest">

# 教育经历

- XX大学（中国），XXXX学院，工学学士（20xx年9月~20xx年6月）

# 论文发表

1. **S Li**, H Zhang, D Dai, G Ding, X Wei, Y Guo. Study on the factors affecting solid solubility in binary alloys: An exploration by Machine Learning[J]. *Journal of Alloys and Compounds*, 2019, 782: 110-118.[[DOI]](https://doi.org/10.1016/j.jallcom.2018.12.136) 
# 联系我

邮箱：xxxx[at]xxx.xx (请使用@替换[at])
```

#### 修复链接

&emsp;&emsp;由于博客原来首页移动到子目录 blog 下，相应的博客分页展示页中的卡片链接、分页链接、标签链接等等都需要做出修改。下面举个例子（反斜杠请删除）：

```html
<!-- 原来是 -->
<a class="post-link" href="{\{ post.url }}" title="{\{ post.title }}"></a>
<!-- 现在修改为 -->
<a class="post-link" href="{\{ post.url | prepend: site.baseurl }}" title="{\{ post.title }}"></a>
```

```yaml
# _config.yml
# 原来是
paginate_path: 'page:num'
# 现在修改为
paginate_path: 'blog/page:num'
```

### 归档页

&emsp;&emsp;归档页其实是在上一个功能的基础上实现的，使用的也是同一个页面模板，只是内容稍有不同。如下所示，创建新文件 archives.html 和修改 dev/sass/common.scss 文件：

<script src="https://gist.github.com/zhonger/72dd3ddde762f8b040f25c53c12c70c7.js?filename=archives.html"></script>

```css
/* common.scss */
.archives-date {
  width: 130px;
  display: inline-block;
}

.archives-title {
  width: 95%;
  display: inline-block;
  margin-bottom: 0!important;
  margin-top: 0!important;
}

@media screen and (max-width: 960px) {
  .archives-date {
    display: none;
  }

  .archives-title {
    width: 290px;
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
    margin-bottom: -8px!important;
  }
}
```

另外，也需要在 _config.yml 文件中在导航栏中添加链接，如下所示。

```yml
_config.yml
nav:
  home: '/'
  blog: '/blog/'
  archives: '/archives.html'
  tags: '/tags.html'
  RSS: '/feed.xml'
```
