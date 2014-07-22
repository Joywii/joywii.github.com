---
layout: post
title: "OSX Use Tips"
date: 2014-03-21 18:58:37 +0800
comments: true
categories: OSX 
---

##1.快速创建HTTP服务器共享文件
在想要分享的目录下输入以下Python命令：
```
python -m SimpleHTTPServer 8888
```
然后在浏览器中访问http://xx.xx.xx.xx:8888 就可以访问我们想要共享的目录了，xx.xx.xx.xx是本机的ip地址，8888是HTTP服务监听的端口号。
##2.显示和隐藏Mac隐藏文件
显示隐藏文件命令：
```
defaults write com.apple.finder AppleShowAllFiles -bool true
```
隐藏隐藏文件命令：
```
defaults write com.apple.finder AppleShowAllFiles -bool false
```
