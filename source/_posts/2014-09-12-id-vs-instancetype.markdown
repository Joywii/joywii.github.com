---
layout: post
title: "id vs instancetype"
date: 2014-09-12 18:38:16 +0800
comments: true
categories: 
---
###id存在的问题
根据Cocoa的命名惯例，Objective-C中init, alloc这类开头的方法，如果以id作为返回类型，会返回消息接收类的实例对象。这些方法有一个`相关返回类型`，LLVM会进行静态的类型安全检查，但是不是按照这类命名规则命名的方法如果也要返回id，LLVM就不会进行类型安全检查，我们在编译的时候不会发现，而在运行的时候很可能出错，我们现在定义一个类：
```
@interface Person : NSObject
- (id)initWithName:(NSString *)name;
+ (id)personName:(NSString *)name;
@end
@implementation Person
- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self){
    }
    return self;
}
+ (id)personName:(NSString *)name
{
    Person *person = [[Person alloc] init];
    return person;
}
@end
```
由于`personName`返回id类型，LLVM不会进行类型安全检查，这样我们就有可能写出错误代码而在编译阶段却发现不了，例如：
```
[[[Person alloc] initWithName:@"sss"] count];
[[Person personName:@"sss"] count];
```
第一行代码就会给出`count`方法找不到的错误，而第二行不会，由于`count`不是Person的方法，而`personName`返回的是id类型，编译器是不会发现问题，只有当运行的时候才会报错。但是`initWithName`是按照内存管理命名规则定义的方法，同样是返回id，但是该方法就会进行`类型安全检查`,在编译的时候就会发现问题。
###instancetype的出现
`instancetype`只能用作返回类型，使用`instancetype`,编译器会进行类型安全检查，就会解决以上问题。
```
- (instancetype)initWithName:(NSString *)name;
+ (instancetype)persionName:(NSString *)name;
```
如果方法的返回类型不是该消息接收类的实例，编译器同样会报错。
```
+ (instancetype)personName:(NSString *)name
{
    UIView *view = [UIView alloc] init];
    return person;
}
```
如果`personName`方法的返回类型使用`id`，编译器是认为该代码是没有问题的，而实际上我们想要的是`Person`的实例。所以，返回类型实例的方法的返回类型尽量用`instancetype`,以便尽早的在代码的编译阶段发现问题。
