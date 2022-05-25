---
layout: post
title: 'Jekyll 优化合集'
subtitle: '为 Jekyll 添加更多的功能支持'
date: 2021-03-24 10:10:00 +0800
categories: [tech, webmaster]
author: zhonger
cover: 'https://unsplash.lisz.tk/1550408483-bafa35b0a433.webp'
cover_author: 'Fer Nando'
cover_author_link: 'https://unsplash.com/@fer_nando'
render_with_liquid: false
tags: 
- Jekyll
- Plugins
- 优化
- fancybox
- prism
- LaTex
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

&emsp;&emsp;首先在 Gemfile 中配置下面行，以便安装好对应的插件模块。

```bash
gem install pygments.rb
```

&emsp;&emsp;然后是修改 _config.yml 配置文件，其中的 highlighter 修改如下：

```yaml
markdown: kramdown
highlighter: pygments
```

&emsp;&emsp;之后不要忘记要引入 Pygments 的 CSS 样式，可以直接访问以下地址下载：

```bash
https://pygments.org/_static/pygments.css
```

&emsp;&emsp;不过也是可以引入其他主题的 CSS 样式的。

#### Rouge

&emsp;&emsp;Rouge 是 Jekyll 也是 H2O 主题默认的代码高亮工具，支持的语言与其他工具相比都要少一些。因为 Rouge 本身是用 Ruby 语言编写的，所以编译时只需要 Ruby 环境。另外，Rouge 的主题和 Pygments 是完全兼容的，所以如果是从 Pygments 变到 Rouge，只需要在 _config.yml 配置文件做如下修改即可：

```yaml
markdown: kramdown
highlighter: rouge
```

#### Prism

&emsp;&emsp;本站所采用的代码高亮就是 Prism，选择 Prism 的原因主要有三点：

- Prism 生成代码比较简洁，没有多余代码，颜色在不同网站主题上都适用；
- 支持的高亮编程语言丰富，虽然在某些地方还是有所瑕疵，但是总体上还是很实用；
- 高亮主题基本上现有的都能用，本站所用的就是 Github 官方同款主题。

&emsp;&emsp;Prism 工具的安装使用相较其他两种稍微复杂一点，需要下载插件 prism.rb 手动安装到 _plugins 文件夹中，然后在文章模板页添加 prism.css 和 prism.js 的引入。

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
    <link href="{{ site.baseurl }}/assets/css/prism.css" rel="stylesheets" />
</head>

<!-- _layouts/post.html -->
<body>
    ......
    <script src="{{ site.baseurl }}/assets/js/prism.js"></script>
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

&emsp;&emsp;这里使用的是默认配置，想要更多定制可以移步 [fancybox 官网](http://fancyapps.com/fancybox/3/docs/#options)。

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

```html
<!-- page.html -->

<!DOCTYPE html>
<html lang="zh-cn">
{% include head.html %}
<body>

{% include header.html %}

<div class="g-banner home-banner {{ site.theme-color | prepend: 'banner-theme-' }}" data-theme="{{ site.theme-color }}">
    <h2>{{ page.home-title }}</h2>
    <h3>{{ page.description }}</h3>
    {% if page.header-img %}
    <img class="header-img" src="{{ page.header-img | prepend: site.baseurl }}" alt="">
    {% endif %}
</div>

<main class="g-container home-content">
    <div class="article-list">
        <div class="post-content" style="padding-left: 30px;padding-right: 30px;width: auto;">
            <article class="markdown-body" style="width: auto;">
                {{ content }}
            </article>
        </div>
    </div>

    <aside class="g-sidebar-wrapper">
        <div class="g-sidebar">
            <section class="author-card">
                <div class="avatar">
                    <img src="{{ site.avatar | prepend: site.baseurl }}" alt="">
                </div>
                <div class="author-name" rel="author">{{ site.author }}</div>
                <div class="bio">
                    <p>{{ site.bio }}</p>
                </div>
                {% if site.sns.size > 0 %}
                <ul id="sns-links" class="sns-links">
                    {% for s in site.sns %}
                    <li>
                        <a href="{{ s[1] }}" target="_blank" rel="noreferrer">
                            <i class="iconfont icon-{{ s[0] }}"></i>
                        </a>
                    </li>
                    {% endfor %}
                </ul>
                {% endif %}
            </section>

            {% if site.recommend-tags and site.tags.size>0 %}
            <section class="tags-card">
                {% for tag in site.tags %}
                    {% if forloop.index > site.recommend-condition-size %}
                        {% break %}
                    {% endif %}
                    <a href="{{ "tags.html#" | append: tag[0] | relative_url }}" class="tag">{{ tag[0]}}</a>
                {% endfor %}
            </section>
            {% endif %}

            <section class="tags-card">
                <div class="links" rel="links">Links</div>
                <a href="https://kalasearch.cn" target="_blank" class="tag" rel="noreferrer">Kala Search</a>
            </section>
        </div>

        {% if site.search %}
        <div class="search-card">
            <input id="search_input" type="text" placeholder="Search...">
            <i class="iconfont icon-search"></i>
            <div class="search_result"></div>
        </div>
        {% endif %}

    </aside>

</main>

{% include footer.html %}

<script src="https://cdn.jsdelivr.net/npm/jquery/dist/jquery.min.js"></script>
<script src="{{ site.baseurl }}/assets/js/prism.js"></script>
<script src="{{ site.baseurl }}/assets/js/index.min.js"></script>

</body>
</html>
```

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

<img src="{{ site.baseurl }}/assets/icons/kvm.webp" alt="KVM" class="interest">

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

&emsp;&emsp;由于博客原来首页移动到子目录 blog 下，相应的博客分页展示页中的卡片链接、分页链接、标签链接等等都需要做出修改。下面举个例子：

```html
<!-- 原来是 -->
<a class="post-link" href="{{ post.url }}" title="{{ post.title }}"></a>
<!-- 现在修改为 -->
<a class="post-link" href="{{ post.url | prepend: site.baseurl }}" title="{{ post.title }}"></a>
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

```liquid
<!-- archives.html -->

---
layout: page
home-title: Welcome to zhonger's blog!
description: Writing, writing, writing ...
permalink: /archives.html
cover: https://unsplash.lisz.tk/1465189684280-6a8fa9b19a7a?w=1600&q=900
---

<h2>Archives</h2>

  {% for post in site.posts %}

    {% unless post.next %}
      <h3>{{ post.date | date: '%Y' }}</h3>
    {% else %}
      {% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
      {% capture nyear %}{{ post.next.date | date: '%Y' }}{% endcapture %}
      {% if year != nyear %}
        <h3>{{ post.date | date: '%Y' }}</h3>
      {% endif %}
    {% endunless %}

    <li><p class="archives-title"><span class="archives-date">{{ post.date | date: "%b %-d, %Y" }} </span><a href="{{ post.url | prepend: site.baseurl }}"> {{ post.title }} </a></p></li>

  {% endfor %}
```

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

&emsp;&emsp;另外，也需要在 _config.yml 文件中在导航栏中添加链接，如下所示。

```yaml
_config.yml
nav:
  home: '/'
  blog: '/blog/'
  archives: '/archives.html'
  tags: '/tags.html'
  RSS: '/feed.xml'
```

### 支持 LaTex 数学公式

(本小节更新于 2021年12月20日)

&emsp;&emsp;作为一名研究机器学习的计算机专业科研狗，LaTex 公式在解释机器学习算法基础理论时时不时会被需要。由于 Markdown 语言解析器对 Markdown 标准支持的不同，可能不支持 LaTex 公式，本站所使用的主题原来就尚未对 Markdown 公式或者 LaTex 公式进行支持。这里实现方法是采用 MathJax v3 插件增加对 LaTex 公式的解析支持：只需要在 _layouts/post.html 文件的 body 之前增加以下代码即可。此处，为了原生支持 LaTex 语法中采用**双$符号**来声明公式，同时也相应调整了 MathJax 的配置。于是就可以在基于文章模板的页面中直接使用如下所示的 LaTex 声明即可正确显示数学公式了。当然，如果想要全站所有的页面都有这个功能，可以在_layouts 目录下的所有模板文件的 body 之前都添加以下代码，或者在 _includes 目录下的全局模块文件 head.html 或者 footer.html 文件中添加以下代码。想要了解更多，可以访问参考资料查看详细介绍。

```html
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<script> 
    MathJax = {
      tex: {
        inlineMath: [['$', '$']],
        processEscapes: true
      }
    };
</script>
```

```latex
$$
ax^2 + bx + c = 0
$$
```

$$
ax^2 + bx + c = 0
$$

### 字数统计及阅读时长估算

(本小节更新于 2021年12月20日)

&emsp;&emsp;由于博客上的文章或短或长，对于读者来说不可能马上辨别是否需要多长时间才能阅读完全文，因此最好在文章开头的地方就有一个简单的信息告诉读者。其实在 Jekyll 中要做到这个也不是很难，只需要对整个文章的内容进行字符计数即可。通常来说，英文单词的阅读速度在 350 词/分钟 左右，而中文的阅读速度也差不多，所以可以将字数除以 350 即可得到大概所需的阅读时长。最后将以下代码添加到 _layouts/post.html 相应的位置即可，一般来说在写作时间下面较佳。

```html
<div class="post-meta">
    <span>本文总共 {{ page.content | strip_html | strip_newlines | remove: " " | size }} 字 <b>·</b> 阅读全文大约需要 {{ page.content | strip_html | strip_newlines | remove: " " | size | divided_by: 350 | plus: 1 }} 分钟</span>
</div>
```

&emsp;&emsp;当然可能有的人要问了，这样计算出来的字数是否正确呢？毕竟中英文字符还是有差别的嘛。这个问题在参考资料的博文中做了一些比较深刻的讨论，最后给出来的方案就是这里采用的方案。也可能会有人问如果存在公式、代码、图片等非可计数的内容，那么阅读时长岂不是准确性很差？这个问题其实主要还是在统计上，由于这些非可计数内容不在正常字数统计内，也无法根据它们的数量来评估对应所需的时间，自然也不能加入到阅读时长里。回过头来看，这里的字数统计及阅读时长估算功能本来就是给读者一个信息好做出预判，至于读者阅读是否需要那么长时间或者甚至更长时间，那都没有太大关系。

## 参考资料

- [让 Jekyll 支持 LaTex 数学公式（MathJax v3）](https://hansenz42.github.io/posts/add-latex-support-to-jekyll/)
- [Jekyll 实现文章阅读耗时与字数统计](https://too.pub/Jekyll-count-of-characters)
- [Jekyll 中如何做中文字数统计](https://taoalpha.github.io/blog/2015/05/21/tech-jekyll-count-of-chinese-characters/)
