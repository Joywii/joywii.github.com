---
layout: post
title: "每个Mac OS X 命令行用户应当知道的八个终端工具"
date: 2014-05-16 10:07:03 +0800
comments: true
categories: 
---
OS X的终端开启了一个强大的UNIX实用工具和脚本的世界。如果你是从Linux迁移过来的，你会发现许多熟悉的命令，工作方式和你所期望的方式一样。但是大部分用户不知道OS X自带了一些其他操作系统没有的基于文本的工具。学习这些Mac上独有应用，可以让你在命令行上更高效，帮助你跨越OS X和UNIX之间的鸿沟。
##1.open akak
`open`打开文件、目录和应用。很令人兴奋是不是，其实open真正有用的是作为命令行的双击命令，例如输入：

```
$ open /Applications/Safari.app/
```
Safari就会打开，就像你在Finder中双击了Safari图标一样。

如果我们用`open`打开一个文件，终端就会尝试用相应的GUI程序加载文件，`open screenspot.png`会在Preview中打开图片。我们可以通过`-a`来指定打开的应用，或者`-e`来打开TextEdit编辑文件。

`open`一个目录将直接在Finder窗口中打开相应的目录，特别打开当前目录`open .`命令是非常有用的。

请记住，Finder和终端是双向的，我们直接从Finder中拖拽一个文件到命令行，该文件的完整地址就会粘贴到命令行。

##2.pbcopy and pbpaste

##3.mdfind

##4.screencapture

##5.launchctl

##6.say

##7.diskutil

##8.brew


[Eight Terminal Utilities Every OS X Command Line User Should Know](http://www.mitchchn.me/2014/os-x-terminal/)


