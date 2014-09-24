---
layout: post
title: "Objective-C super的理解"
date: 2014-09-12 18:42:19 +0800
comments: true
categories: 
---
####1.Super的理解
先看下面的例子
```
@interface Father : NSObject
@end
@implementation Father
@end

@interface Son : Father
@end
@implementation Son
- (id)init
{
    self = [super init];
    if (self)
    {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    
    return self;
}
@end
```
输出的结果：
```
Son
Son
```
根据`[super class]`表面的意思我们很容易理解输出应该为`Father`。真是的情况是这样的，`super`只是一个`编译器指示符`,当使用`super`和`self`发送消息的时候，消息的接收者都是`self`，本质上通过`self`发送消息会转化成`objc_msgSend`方法的调用，`objc_msgSend`负责从当前类的方法列表开始查询，而通过`super`发送消息会转化成`objc_msgSendSuper`方法的调用，`objc_msgSendSuper`是从当前类的父类的方法列表开始查询方法的。
`objc_msgSend`定义如下：
```
id objc_msgSend(id receiver, SEL op, ...)
```
`self`默认为`objc_msgSend`方法的第一个参数，所以`[self class]`的接收者为`self`，而`class`方法在`NSObject`基类中定义，返回消息接收者`receiver`的。
`objc_msgSendSuper`定义如下：
```
id objc_msgSendSuper(struct objc_super *super, SEL op, ...)
```
第一个参数是个`objc_super`的结构体,定义如下：
```
struct objc_super {
    id receiver; 
    Class superClass;
};
```
可以看到这个结构体包含了两个成员，一个是`receiver`，这个类似上面`objc_msgSend`的第一个参数`receiver`，第二个成员是记录这个类的父类是什么,构建`objc_super`的时候第一个参数赋值为`self`，`superClass`赋值为`self`的父类指针。
最上面的例子中`[super class]`具体执行过程如下：
1.构建`objc_super`的结构体，此时这个结构体的第一个成员变量receiver就是Son的实例，和self相同。而第二个成员变量superClass就是指类Father。
2.调用`objc_msgSendSuper`方法，将`objc_super`结构体和`class`的`sel`传递过去。函数里面在做的事情类似这样：从`objc_super`结构体指向的`superClass`的方法列表开始找`class`的`selector`，找到后再以`objc_super->receiver`去调用这个`selector`，可能也会使用`objc_msgSend`这个函数，不过此时的第一个参数`receiver`就是`objc_super->receiver`，第二个参数是从`objc_super->superClass`中找到的`selector`。