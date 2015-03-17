---
layout: post
title: "iOS中的Hit-Testing"
date: 2015-03-17 10:42:55 +0800
comments: true
categories: 
---
译自:[Hit-Testing in iOS](http://smnh.me/hit-testing-in-ios/)

Hit-Testing是判定与一个点（touch-point）相交互的绘制在屏幕上的图像对象（`UIView`）的过程。iOS使用Hit-Testing来决定那个`UIView`是位于手指下面最前面的视图，该视图应该来接收触摸事件。Hit-Testing是通过反向的深度优先搜索算法实现的。

在解释Hit-Testing是如何工作之前，理解Hit-Testing何时执行是很重要的。下面的图片解释了一个简单的触摸事件的过程，从手指触摸到屏幕的一刻起到手指离开屏幕。
![](http://smnh.me/images/hit-test-touch-event-flow.png)
