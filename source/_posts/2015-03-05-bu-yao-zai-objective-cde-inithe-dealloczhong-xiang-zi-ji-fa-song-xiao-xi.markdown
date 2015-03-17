---
layout: post
title: "不要在Objective-C的init和dealloc中向自己发送消息"
date: 2015-03-05 16:06:10 +0800
comments: true
categories: 
---
译自:[Don’t Message self in Objective-C init (or dealloc)](http://qualitycoding.org/objective-c-init/)

在Objective-C的init和dealloc方法中向自己发送消息是有危险的，如下两个地方：

```
- (id)initWithFoo:(id)foo
{
    self = [super init];
    if (self)
        self.something = foo;
    return self;
}

- (void)dealloc
{
    self.something = nil;
    [super dealloc];
}
```
##什么时候不应该向自己发送消息
通常情况下向自己发送消息都是OK的。但是在以下两个地方应该避免：

- 在对象的创建过程中
- 在对象的销毁过程中

在这两个阶段，对象处于一个中间状态。缺乏完整性。在这两个阶段调用属性方法是不合适的。因为每个方法维护着和对象相关的变量。下面是一个对象构建过程经过的流程：

1. 开始：假设对象是一致的。
2. 过程中：对象状态是变动的。
3. 结束：重新存储变量，对象是一致的。

苹果已经有文档[Practical Memory Management](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html)有一张标题 “不要在初始化方法和dealloc中调用访问方法”
##Objective-C init/dealloc：解决方法
解决方案非常简单：在init/dealloc方法内，通过直接访问实例变量来代替通过属性方法。在非ARC下，根据属性的`attributes`是`retain`还是`assign`来写匹配代码。例如如果`something`是一个`retain`属性默认有一个`_something`实例变量，实现代码如下：

```
- (id)initWithFoo:(id)foo
{
    self = [super init];
    if (self)
        _something = [foo retain];
    return self;
}

- (void)dealloc
{
    [_something release];
    [super dealloc];
}
```
在ARC下：

```
- (id)initWithFoo:(id)foo
{
    self = [super init];
    if (self)
        _something = foo;
    return self;
}

- (void)dealloc
{
    [_something release];
}
```
##什么时候在init/dealloc中向自己发送消息是OK的
虽然已经建议“避免在init/dealloc向自己发送消息”，但是有两个地方史OK的：

- init结束的地方
- dealloc开始的地方

因为在这两个地方对象是一致的。在init里所有的变量已经初始化，在dealloc还没有变量被销毁。
#####但是我们一定谨慎和知道对象处于生命周期的什么阶段。简单的创建一个对象不应该以繁重的任务开始。保持构建和销毁方法的简洁。