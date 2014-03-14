---
layout: post
title: "iOS Dev Tips"
date: 2014-03-12 17:19:01 +0800
comments: true
sharing: true
categories: iOS 
---

## 1.多次autorelease问题

### 例子：
```
NSObject *object = [[NSObject alloc] init];
[[object autorelease] autorelease];
```
### 结果：
会抛出一个malloc异常，`程序不会Crash`。malloc: \*\*\* error for object 0x7594920: pointer being freed was not allocated \*\*\* set a breakpoint in malloc\_error\_break to debug

## 2.Property之atomicity(nonatomic)
指定属性的访问方法是不是原子性的，默认是原子性的，这样多线程访问是安全的，但会消耗一定的资源。所以一般不是多线程的程序最好指定不是原子性的。

## 3.UIView alpha 与 opaque区别
opaque默认为YES，为了系统在绘制界面的时候优化提高性能。尤其是scrollview和做动画的时候。

## 4.Objective-C实现变参函数
```
- (void)method:(NSString *)value,...
{
    //指向变参的指针
    va_list list;
    //使用第一个参数来初使化list指针
    va_start(list, value);
    while (YES)
    {
        //返回可变参数，va_arg第二个参数为可变参数类型，如果有多个可变参数，依次调用可获取各个参数
        NSString *string = va_arg(list, NSString*);
        if (!string) {
            break;
        }
        NSLog(@"%@",string); 
    }
    //结束可变参数的获取
    va_end(list);
}
```
##5.关闭键盘方法 
```
（1）[self.view endEditing:YES];
（2）[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
（3）[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
```
##6.NSString属性标识
```
1.@property(nonatomic,retain)NSString *str;
2.@property(nonatomic,copy)NSString *str;
```
1和2两张写法你习惯使用哪种,为什么？
最好采用第二种方法，`NSMutableString`是NSString的子类，可以作为set方法的参数传递，so，如果是retain的话，指针实际指向的对象是NSMutableString，这将导致该属性有可变的可能
##7.Objective-C BOOL理解
```
BOOL myBool;  (unsigined char)8位中最低位为1就是YES，最低位为0就是NO
myBool = YES;      //True
myBool = TRUE    //True
myBool = 1          //True
myBool = NO      //False
myBool = FALSE  //False
myBool = 0         //False
```
##8.iOS手势UIGestureRecognizer类型
```
1、拍击UITapGestureRecognizer (任意次数的拍击)  
2、向里或向外捏UIPinchGestureRecognizer (用于缩放)  
3、摇动或者拖拽UIPanGestureRecognizer  
4、擦碰UISwipeGestureRecognizer (以任意方向)  
5、旋转UIRotationGestureRecognizer (手指朝相反方向移动)  
6、长按UILongPressGestureRecognizer
```
##9.APP崩溃调试总结
1.问题：崩溃在main.m里面

答案：可以设置全局异常断点（Exception Breakpoint）

2.问题：在异常断点开启的状态下，你也没有得到得到有用的信息。

答案：在这种情况下，多继续几次运行这个app，或者在调试提示后面输入`“po $eax”`命令。“$eax”是cup的一个寄存器。在一个异常的情况下，这个寄存器将会包含一个异常对象的指针。注意：$eax只会在模拟器里面工作，假如你在设备上调试，你将需要使用`”$r0″`寄存器。

3.问题：大多数崩溃的一般原因和一些bug都是在你的xib中或者storyboard中的连接丢失了或者是错误的连接。这些情况不会在编译错误里面显示，因此你一般不知道。

答案：（我不常用xib和storyboard，一般不会遇到这个问题）

4.问题：不要忽略编译警告。假如你有编译警告，就说明你有些东西可能会出错。
      假如你不知道为什么你会到一个编译警告，最好去搞明白它. 这些都是安全的做法!

答案：搞清楚编译警告！

##10.iOS内存管理之Autorelease
原理：
- 1.先建立一个autorelease pool
- 2.对象从这个autorelease pool里面生成。
- 3.对象生成 之后调用autorelease函数，这个函数的作用仅仅是在autorelease pool中做个标记，让pool记得将来release一下这个对象。
- 4.程序结束时，pool本身也需要rerlease,此时pool会把每一个标记为autorelease的对象release一次。如果某个对象此时retain count大于1，这个对象还是没有被销毁。

例子：

```
ClassName *myName = [[[ClassName alloc] init] autorelease];//标记为autorelease
[classA setName:myName]; //retain count == 2
[myName release]; //retain count==1，注意，在ClassA的dealloc中不能release name，否则release pool时会release这个retain count为0的对象，这是不对的。
```
记住：
如果这个对象是你alloc或者new出来的，你就需要调用release。如果使用autorelease，那么仅在发生过retain的时候release一次（让retain count始终为1）。
##11.iOS UIImage 的延迟加载
SDWebImage中图片的加载为啥需要`Decoder`？由于UIImage的imageWithData函数是每次画图的时候才将Data解压成ARGB的图像，所以在每次画图的时候，会有一个解压操作，这样效率很低，但是只有瞬时的内存需求。为了提高效率通过SDWebImageDecoder将包装在Data下的资源解压，然后画在另外一张图片上，这样这张新图片就不再需要重复解压了。这种做法是典型的空间换时间的做法。Decoder代码如下：

```
TODO:Decoder代码
```
参考链接：[Avoiding Image Decompression Sickness](http://www.cocoanetics.com/2011/10/avoiding-image-decompression-sickness/)
##12.NSFileManager创建文件或者NSData写入失败
- 原因：没有当前目录，下面这样没有目录直接存文件是不行的

```
NSString *umdFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/umd"];
NSString *imagePath = [umdFolder stringByAppendingPathComponent:[umd.title md5]];//[umd.title md5]
[[NSFileManager defaultManager] createFileAtPath:imagePath contents:coverImageData attributes:nil];
```
- 解决方案：正确做法是先创建目录，然后再写入文件

```
NSString *umdFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/umd"];
if ([[NSFileManager defaultManager] fileExistsAtPath:umdFolder] == NO)
{
        [[NSFileManager defaultManager] createDirectoryAtPath:umdFolder withIntermediateDirectories:YES attributes:nil error:nil];
}
NSString *imagePath = [umdFolder stringByAppendingPathComponent:[umd.title md5]];//[umd.title md5]
[[NSFileManager defaultManager] createFileAtPath:imagePath contents:coverImageData attributes:nil];
```
##13.定义协议的时候为什么要绑定<NSObject>协议
例如：

```
@protocol MyProtocol <NSObject>
//定义一些方法
@end
id <MyProtocol> foo;
//foo符合<MyProtocol,NSObject>
```
id除了指向了对象外，不包含对象的任何信息。id <MyProtocol>说明了id指向的对象实现了MyProtocol定义的方法，当使用id发送相应消息的时候编译器不会给出警告，但是当我们想要使用id发送NSObject协议定义的消息（retain、release）的时候，如果MyProtocol协议没有绑定NSObject协议的话，编译器会认为id没有实现相关方法，会给出警告。一般我们使用的类都继承于NSObject，NSObject的方法主要定义在NSObject协议内。所以说要想调用NSObject协议的方法，必须要指明id对象包含NSObject协议方法，通过以上方法绑定可以做到。另外两种方法也可以：

```
@protocol MyProtocol
//定义一些方法
@end
id <MyProtocol,NSObject> foo;
//或者
NSObject <MyProtocol> * foo;//要保证foo赋值为NSObject的子类对象。
```
##14.NSNotification对于多线程的理解
##15.@Dynamic与@synthesize区别
@Synthesize 会自动生成属性对应的成员变量和get和set方法。而@Dynamic不会自动生成实例变量和相应的get和set方法。但是我们可以提供自己的实例变量和相应的get和set方法：

```
@interface DynamicTest : NSObject
{
        NSString *_str;
}
@property (nonatomic,strong) NSString *str;
@end
@implementation DynamicTest
@dynamic str;
- (void)setStr:(NSString *)tempStr
{
    if (tempStr != _str)
    {
        _str = tempStr;
    }
}
- (NSString *)str
{
    return  _str;
}
@end
```
@Dynamic主要用于的情况是：当属性的get和set方法是在运行时动态实现的，我们的代码又要使用get和set方法，@Dynamic可以避免编译时的警告。例如CoreDada中的NSManagedObject。

```
@interface Movie : NSManagedObject
{
}
@property (retain) NSString* title;
@end
@implementation Movie
@dynamic title;
@end
```
##16.+initialize和+load
- +initialize会在类的任何其他函数调用前被调用。
- +load方法是在所在类加载到系统的时候被调用，这通常会比+initialized调用的时机要早
 
 如果子类里没有实现+initialized而父类里面实现了+initialized，那么用到子类时，不是说一定要生成对象，+initialize是调用任何方法，包括类方法，例如[SubClass class]，那么`父类的+initialized就会被执行两次`！解决办法也很简单，就像开头的写法if (self == [Manager class])，先判断下是不是当前类的类型。

 如果你在类的实现中实现了+load，但是在这个类的Category中又实现了一个+load，那么这`两个+load都会被调用`。
