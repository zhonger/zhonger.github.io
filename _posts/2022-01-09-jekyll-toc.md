---
layout: post
title: 'Jekyll 文章侧边索引导航'
subtitle: '让你的 Jekyll 文章页阅读体验更好'
date: 2022-01-09 22:00:00 +0900
categories: [tech, webmaster]
author: zhonger
cover: 'https://unsplash.lisz.tk/1615339236992-e4c1c175faef.webp'
cover_author: 'Xianyu hao'
cover_author_link: 'https://unsplash.com/@xianyuhao'
tags: 
- Jekyll
- 主题
- theme
- 侧边索引
- TOC
render_with_liquid: false
---

* TOC
{:toc}

## 前言

&emsp;&emsp;Jekyll 与 Hexo 不同之处有很多，其中一处是在文章页面中不支持原生 [TOC] Markdown 语法来自动生成目录。而在 Hexo 中，即使主题不支持侧边悬浮的优化目录导航，也可以通过最简单的方式在文章的开始位置生成目录。虽然这种目录永远固定在文章开始的地方，但是总算是能够通过大小标题来给读者一个大概的思路。

### Jekyll 生成目录的方案

&emsp;&emsp;如参考资料 1 中所提到的，如果想要在 Jekyll 中实现文章目录，有三种不同的方案可供选择：

#### 第一种方案

&emsp;&emsp;利用完整的标签来生成静态目录，可以看到在本文的开头就是这样的一个实例。这种方法的好处是不需要修改什么复杂的模板或者添加什么样式，Github Pages 也默认支持这种方式。不好的地方是与标准的 Markdown 语法略有不同，而且每次都得在文章内容页面开头加上以下代码。如果你使用带有 markdownlint 插件的编辑器编辑文章时，可能会有一堆告警。当然，如果不想折腾的人，这种方法不失为一种最简单方便的解决方案。

```markdown
* TOC
{:toc}
```

#### 第二种方案

&emsp;&emsp;利用第三方插件 [jekyll-toc](https://github.com/toshimaru/jekyll-toc)。这种方式在实现上比上一种要更加优雅一些，不需要自己修改或编写代码，只需要执行以下步骤即可。缺点在于 Github Pages 不支持这类自定义插件，你可能需要使用自定义的 workflow.yml 文件来指导 Github Action 来编译生成静态文件。如果不怎么了解 Github Action，恐怕这种方式部署在 Github Pages 上也不是很省心。

```ruby
# gemfile

gem "jekyll-toc"

# 添加后需执行 bundle install 安装插件
```

```yaml
# _config.yml

# 在全局配置文件中启用 jekyll-toc 插件
plugins: ["jekyll-toc"]

# 默认为所有文章启用 toc
defaults:
  - scope:
      path: ""
    values:
      toc: true
```

#### 第三种方案

&emsp;&emsp;采用新增 jekyll 模板的方式来支持自动生成目录。这种方式也可以直接运行在 Github Pages 下。主要的步骤是：

- 将 [toc.html](https://github.com/allejo/jekyll-toc/releases/download/v1.2.0/toc.html) 文件下载到 _includes 目录下；
- 在 _layouts 需要使用 toc 功能的页面模板的 content 前面加上 `% include toc.html html=content %`。

## 实践

&emsp;&emsp;从上述三种方案综合来看，第三种方案能够同时支持自动生成目录和 Github Pages，比较适合预期的需求。另外，采用模板的方式还有一个好处，可以在全局配置文件 _config.yml 中一键设置“开启”或“关闭”，配置上比较简单。但如果仅仅照搬上述的第三种方案，还是不能完全满足实际的需求。因为第三种方案的结果是自动生成目录的内容，并不涉及到具体的布局，也就是说只能放在某一个固定的位置。总结的来说，实际的目标起码需要满足以下两点：

- **目标一**：目录位于正文右侧（或左侧），且当内容滑动时目录位置固定不变。
- **目标二**：目录在宽屏时自动显示，在窄屏或移动端分辨率不足时自动隐藏。

### 布局

&emsp;&emsp;从目标一来看，其实在大部分的静态博客主题中都是有这样的功能的（PS：可能 Jekyll 是个例外，原生只支持静态目录）。我们可以先来看两个例子 [hexo-theme-even](https://github.com/ahonn/hexo-theme-even) 和 [markdownguide](https://www.markdownguide.org/getting-started/)。前面的例子是 Hexo 主题，其中采用的是 js 控制 toc 的 div 层在 `position: absolute` 和 `position: fixed` 之间变换：当页面初始时，处于 absolute 位置；当页面在向下滑动时，处于 fixed 位置。这种方式需要有 js 代码的介入，增加了运算的成本（虽然其实很小）和维护成本（占比更大）。后面的例子是采用了 Bootstrap 框架中的 toc js 插件，能够满足目标一，且能跟踪内容位置来切换显示的二级目录，相对来说功能更加强大。唯一的缺点是，拖着 Bootstrap 这个大拖油瓶，如果本身的主题是基于 Bootstrap 框架的，那么就非常合适了。

&emsp;&emsp;这里我们想要实践的是在未使用 Bootstrap 框架的 Jekyll 主题中增加目标一的功能，因此这两个例子的做法都不是很合适。实际上，从需要维护的代码量来说，第一个例子的做法所需的 js 代码应该是算少的，但是不是存在完全不使用 js 代码也能实现这样的功能的方案呢？实际上是存在的。据我们所知，现在已有的页面布局的方法大致有三种：**Table 布局**、**Div 布局**和 **Flex 布局**。Table 布局算是最原始的布局方式了，主要利用 Table 的横列来组织页面中的各个元素的位置，特点是容易上手且不易出问题。缺点也比较明显，不大符合语义化 HTML 的规范，即 HTML 标签只做与它含义相同的事情。Table 标签作为表格布局标签，应该专注于展示表格数据，而非为整个页面布局操心。于是，Div 布局开始流行起来。Div 层的概念和布局的含义完全吻合，也容易理解。Div 布局比较让人头疼的地方是，页面中有很多浮动元素出现时，可能会出现各种各样想象不到的问题，某些布局之后被迫要清除浮动。Flex 布局的出现为 Div 布局提出了改善，使得页面布局不再被浮动元素和 Div 层浮动时内容大小为零所困恼。

&emsp;&emsp;由于想要目录内容块随着内容滑动而改变 position，我们可以采用 sticky 的 position 方案。这可能是 css 的一大进步，通过定义 sticky 的 position 可以让元素根据相邻元素的滑动而改变 position。其实，sticky 就等于 absolute 加上 fixed。只是这种等价只在某些条件成立时才能生效。我们可以通过参考资料 2~4 来了解更多详情。

### 目录生成

&emsp;&emsp;目录生成这里直接采用的是上述的第三种方案。具体在 post 模板页使用 toc 模块的代码如最后所示。

### 自适应

&emsp;&emsp;为了实现目标二，这里采用了最简单的 CSS 媒体查询，即在平常 PC 端宽屏时采用如下 common.sass 中的样式。显示目录时，正文内容宽度为 720 px，目录宽度为 280 px。同时为了将目录与正文拉大间距以及更好区分，这里增加了 margin-left （30 px）、border-left（2px）和 padding（10px）。总计为，720+280+30+10*2=1050 px（这里忽略了 2px 的边界）。不显示目录时，让正文占据所有宽度，并设置目录块为 `display: none`，即隐藏该元素。具体实现如最终代码 common.sass 和 layout.sass 所示。在没有 sass 编译环境下，此处的 sass 代码可以取出转换为 css 使用。

### 最终代码

```liquid
<!-- post.html -->

{% if site.toc %}
  <div class="container">  
    <div class="contents">
      <article class="markdown-body">
        {{ page.content }}
      </article>
    </div>   
    <div class="table-of-contents">
      <h2>Contents</h2>
      {% include toc.html html=content %}
    </div>
  </div>
{% else %}
  <article class="markdown-body">
    {{ page.content }}
  </article>
{% endif %}
```

```sass
<!-- common.sass -->

.container {
    width: 1050px;
    margin: 0 auto;
    display: flex;
    flex-direction: row;
    .contents{
        width: 720px;
    }
    .table-of-contents{
        padding: 10px;
        border-left: 2px solid #efefef;
        width: 280px;
        position: -webkit-sticky;
        position: sticky;
        top: 80px;
        margin-bottom: 80px;
        height: fit-content;
        margin-left: 30px;
        h2 {
            font-family: fantasy;
            color: #e32e00;
        }
        ul{
            margin-left: 20px;
            list-style-type: revert;
            font-size: 14px;
            line-height: 24px;
            color: #005b81;
            a{
                color: #005b81;
                &:hover{
                    color: #e32e00;
                    text-decoration: underline;
                }
            }
        }
    }
}
```

```sass
<!-- layout.sass -->

@media screen and (max-width: 1050px) {
    .post-content {
        .container {
            width: 100%;
            .contents {
                width: 100%;
                float: none;
                margin: 0 auto;
            }
            .table-of-contents {
                display: none;
            }
        }
    }
}
```

## 参考资料

- [jekyll自动生成目录的几种方案](https://plutotree.me/jekyll/2019/01/30/jekyll-toc-solution.html)
- [Runoob - CSS Position 定位](https://www.runoob.com/css/css-positioning.html)
- [position:sticky 粘性定位的几种巧妙应用](https://segmentfault.com/a/1190000039858711)
- [css3 sticky不生效怎么办](https://www.php.cn/css-tutorial-466057.html)
