---
layout: post
title: "每个Mac OS X 命令行用户应当知道的八个终端工具"
date: 2014-05-16 10:07:03 +0800
comments: true
categories: 
---
OS X的终端开启了一个强大的UNIX实用工具和脚本的世界。如果你是从Linux迁移过来的，你会发现许多熟悉的命令，工作方式和你所期望的方式一样。但是大部分用户不知道OS X自带了一些其他操作系统没有的基于文本的工具。学习这些Mac上独有应用，可以让你在命令行上更高效，帮助你跨越OS X和UNIX之间的鸿沟。
##1.open   
`open`打开文件、目录和应用。很令人兴奋是不是，其实open真正有用的是作为命令行的双击命令，例如输入：

```
$ open /Applications/Safari.app/
```
Safari就会打开，就像你在Finder中双击了Safari图标一样。

如果我们用`open`打开一个文件，终端就会尝试用相应的GUI程序加载文件，`open screenspot.png`会在Preview中打开图片。我们可以通过`-a`来指定打开的应用，或者`-e`来打开TextEdit编辑文件。

`open`一个目录将直接在Finder窗口中打开相应的目录，特别打开当前目录`open .`命令是非常有用的。

请记住，Finder和终端是双向的，我们直接从Finder中拖拽一个文件到命令行，该文件的完整地址就会粘贴到命令行。

##2.pbcopy and pbpaste
我们可以用这两个命令在命令行里粘贴和复制，当然我们也可以使用鼠标做到这些，但是pbcopy和pbpaste真正的强大之处在于，他们来自于UNIX命令，可以充分利用管道、重定向和能够在脚本中与其他命令相结合的能力。例如：

```
$ ls ~ | pbcopy
```
这条命令会拷贝home目录下的所有文件列表到OS X的剪贴板中。我们也可以很简单的获取文件中的内容：

```
$ pbcopy < blogpost.txt
```
或者疯狂一点的，通过抓取脚本抓取Google涂鸦的连接然后拷贝到剪贴板。

```
$ curl http://www.google.com/doodles#oodles/archive | grep -A5 'latest-doodle on' | grep 'img src' | sed s/.*'<img src="\/\/'/''/ | sed s/'" alt=".*'/''/ | pbcopy
```
通过pbcopy来获取其他命令的输出是一个非常棒的方法，省去了我们滚动屏幕小心翼翼的选择文本啦。这个命令让我们很容易的分享诊断信息。pbcopy和pbpaste还可以用于自动或加速某些类型的任务。举例来说，如果你想的电子邮件的主题行保存到任务列表中，你可以从Mail.app赋值主题然后运行下面的命令：

```
$ pbpaste >> tasklist.txt
```
##3.mdfind

##4.screencapture

##5.launchctl

##6.say

##7.diskutil

##8.brew


[Eight Terminal Utilities Every OS X Command Line User Should Know](http://www.mitchchn.me/2014/os-x-terminal/)


