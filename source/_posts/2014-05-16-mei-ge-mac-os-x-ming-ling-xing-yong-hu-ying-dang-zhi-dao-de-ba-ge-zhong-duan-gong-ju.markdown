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
许多Linux用户尝试在Mac上使用`lacate`来搜索文件，然后发现这个命令不好使。虽然有一个`find`命令可以用，但是OSX有一个自己的好用的文件搜索工具`Spotlight`。所以为什么不把它放到命令行里使用呢？`mdfind`就是这样的命令。任何`Spotlight`可以查找的，`mdfind`都可以查找，包括查找文件和元数据。`mdfind`有几个方便之处区别于`Spotlight`。例如`-onlyin`参数可以严格搜索一个简单的目录：

```
$ mdfind -onlyin ~/Documents essay
```
`mdfind`的数据库总是在后台保持最新，但是我们也可以通过`mdutil`来重构。如果Spotlight出了问题，`mdutil -E`可以删除所有索引然后重头重构。我们也可以通过`mdutil`完全的关闭索引。

##4.screencapture
`screencapture`可以获取不同类型的截图，功能类似于`Grab.app`和快捷键`cmd`+`shift`+`3`和`cmd`+`shift`+`4`，但是更灵活。下面展示几种`screencapture`不同的用法。

1.捕捉屏幕上的内容，包括光标，然后生成的图像（命名为“image.png”）并附加到新的邮件：

```
$ screencapture -C -M image.png
```
2.用鼠标选中一个窗口，获取窗口内容不包括阴影，然后拷贝到剪切板：

```
$ screencapture -c -W
```
3.10秒后获取屏幕截图，然后在`Preview`中打开：

```
$ screencapture -T 10 -P image.png
```
用鼠标选择屏幕的一个区域，然后截图，保存图片为`PDF`：

```
$ screencapture -s -t pdf image.pdf
```
更过选项请查看`screencapture --help`
##5.launchctl
`launchctl`可以让我们和OS X的初始化脚本系统`launch`进行交互。随着启动保护进程和启动代理，当我们启动电脑的时候控制要开启的服务。我们甚至可以启动一个脚本定期执行或者一定时间间隔后在后台执行，类似于`Linux`上的`cron`。例如你想要在开启电脑的时候自动开启`Apache Web Server`，你可以这样：

```
$ sudo launchctl load -w 
/System/Library/LaunchDaemons/org.apache.httpd.plist
```
运行`launchctl list`我们可以看到当前系统加载的启动脚本。`sudo launchctl unload [path/to/script]`命令可以停止或者卸载启动脚本，加入`-W`标志将从启动序列中永久删除这些脚本。我们可以用这个命令关掉`Adobe`和`Microsoft Office`的自动更新。启动脚本存储在以下目录下：

```
~/Library/LaunchAgents    
/Library/LaunchAgents          
/Library/LaunchDaemons
/System/Library/LaunchAgents
/System/Library/LaunchDaemons
```
如果你自己想写启动脚本，Apple在开发者网站上提供了帮助文档。如果你想完全避免命令行来操作的话可以使用Lingon应用。
##6.say
这是一个有趣的命令：`say`可以把文本转化成语音，使用和OS X系统VoiceOver相同的TTS引擎，没有任何选项，就是简单的把文本转化为语音说出来。

```
$ say "Never trust a computer you can't lift."
```
我们也可以简单的用`say`的`-f`标志来说一个文本内容，然后使用`-o`存储最后的音频文件：

```
$ say -f mynovel.txt -o myaudiobook.aiff
```
`say`命令非常有用可以用来替代脚本里面的打印日志和警告音。例如，你可以设置一个Automator的或Hazel脚本做文件批处理，然后在任务完成的时候通过`say`宣布。但是对于`say`最有趣的功能是：如果你可以使用ssh登录朋友的或者同事的机器，你可以默默的登录他们的机器然后通过命令行打扰他们。给他们一个惊喜。我们也可以改变`say`命令默认的语言，通过`System Preferences`的`Dictation & Speech`面板。
##7.diskutil
`diskutil`是OS X自带磁盘工具对应的命令行工具，它不仅可以做到界面工具可以做到的任何功能，也有一些额外的功能-例如用零或者随机数据填充一个磁盘。输入`diskutil list`就可以看到计算机相关的可移动介质和磁盘的路径。然后可以查看你操作的磁盘的容量，但是使用`diskutil`一定要小心，它可能会破坏数据。

##8.brew
技术上来说`brew`不是一个原生的命令，但是没有一个Mac高级用户不用[Homebrew](http://brew.sh/),官网生成这是OS X缺少的包管理工具，如果你在Linux上使用过apt-get，那么Homebrew就是这样的工具。
`brew`可以帮助你轻松的访问开源社区上千的开源库和免费工具，举个例子：`brew install imagemagick`会帮助你安装[ImageMagick](http://www.imagemagick.org/)工具，一个非常有用的工具，可以把GIF图像转换成几十张不同类型的图像。`brew install node`就会安装[NodeJS](http://nodejs.org/),一个非常热门的JavaScript服务端开发的工具。你也可以用`brew`做一些有趣的事情：`brew install archey` 安装**Archey**，一个很cool的工具用来展示Mac描述，包含一个彩色的Apple的Logo。Homebrew的定制是非常灵活的，因为它是非常容易的创建[formulas](https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook),新包会一直被加进来。
![](http://img.itc.cn/photo/jZcv9irp8EW)
但是Homebrew最好的部分是：它总是把所有的文件保存在一个简单的目录下：`/usr/local/`.这意味着你可以系统软件的最新版本，例如`python`和`mysql`，不用被环境变量干扰。如果你不想用Homebrew安装，删除是很简单的。

###原文链接
[Eight Terminal Utilities Every OS X Command Line User Should Know](http://www.mitchchn.me/2014/os-x-terminal/)


