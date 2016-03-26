---
layout: post
title: "AutoLayout进阶"
date: 2016-03-26 20:39:59 +0800
comments: true
categories: 
---
####零、参考文档
- [布局过程](http://stackoverflow.com/questions/20609206/setneedslayout-vs-setneedsupdateconstraints-and-layoutifneeded-vs-updateconstra)
- [先进的自动布局工具箱(中文)](http://objccn.io/issue-3-5/)
- [先进的自动布局工具箱(英文)](https://www.objc.io/issues/3-views/advanced-auto-layout-toolbox/)
- [Auto Layout Guide](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/index.html#//apple_ref/doc/uid/TP40010853-CH7-SW1)

####一、布局过程
在AutoLayout下，视图的布局过程：

![](http://i.stack.imgur.com/i9YuN.png)

- `updating constraints:`
这个过程是我们根据一些条件更新、新增、删除视图的约束的地方。这个过程之后所有的视图约束就都创建好了，后续会根据现有的约束计算布局。
- `update layout:`
这个过程真正计算布局的地方，系统根据约束计算好之后我们还可以在`layoutSubviews`内做一些自定义的布局。
 > **`重要事项`**
 >
 > - `setNeedsUpdateConstraints:`是标记视图为需要更新约束，保证调用`updateConstraintsIfNeeded`的时候系统调用`updateConstraints`,或者系统在下一个运行循环（Runloop）的时候调用`updateConstraints`。
 > - `setNeedsLayout:`是标记视图为需要重新布局，保证调用`setNeedLayout`的时候系统调用`layoutSubviews`,或者系统在下一个运行循环管（Runloop）的时候调用`layoutSubviews`。
 > - 任何对视图约束的操作（更新、新增、删除）之后都会自动调用`setNeedLayout`，就会在下一个运行循环（Runloop）或者我们自己调用`layoutIfNeed`的时候调用`layoutSubviews`。
 
####二、固有内容尺寸（Intrinsic Content Size ）
固有内容尺寸是一个视图期望为其显示特定内容得到的大小。`UILabel`会根据字体和内容自己计算一个固有大小，多行文本的时候可以设置`preferredMaxLayoutWidth`来计算多行文本的固有大小。`UIView`没有固有大小，但是我们可以重写`intrinsicContentSize`,根据视图的内容自己计算视图的固有大小。
####三、压缩阻力（Compression Resistance） 吸附阻力（ Content Hugging）
- `contentCompression:`阻止自己被压缩的优先级，如果两个两个视图出现相互挤压的时候，优先级高的不会被压缩，优先级底的被压缩。例如：当两个`UILabel`水平相互压缩的时候，我们可以指定不想压缩的`UILabel`的阻止压缩的优先级高一点。
- `contentHugging:`阻止自己被吸附的优先级，当一个视图的`Frame`改变的时候，可以导致另外一个依赖此视图的视图布局发生改变，设置阻止吸附优先级高一点，可以阻止这个改变。
> **优先级(我们可以自己设定值 eg：500)**
> 
> UILayoutPriorityRequired  = 1000
> UILayoutPriorityDefaultHigh  = 750
> UILayoutPriorityDefaultLow = 250
> UILayoutPriorityFittingSizeLevel = 50

####四、Alignment Rect
`AutoLayout`中的约束都是基于`Alignment Rect`进行后面的布局计算的。一般情况下我们不做任何处理`Alignment Rect`是和`Frame`一样的。`Alignment Rect`是要我们指定视图的要基于的核心元素的大小。
比如，一个自定义 icon 类型的按钮比我们期望点击目标还要小的时候，这将会很难布局。当插图显示在一个更大的 frame 中时，我们将不得不了解它显示的大小，并且相应调整按钮的 frame，这样 icon 才会和其他界面元素排列好。当我们想要在内容的周围绘制像 badges、阴影、倒影的装饰时，也会发生同样的情况。通过重写以下方法可以指定视图的`Alignment Rect`。

- alignmentRectInsets：
- alignmentRectForFrame: 
- frameForAlignmentRect:（`要和alignmentRectForFrame可逆`）

####五、AutoLayout动画
只有在动画过程中触发视图的重新布局`layoutSubviews`才会有动画效果。一般我们先修改视图的约束，系统会自动调用`setNeedLayout`，然后我们要做的就是在动画过程中调用`layoutIfNeed`触发系统调用`layoutSubviews`.

```
self.constraint.offset = 80;
[UIView animateWithDuration:1.0f animations:^{
    [self setNeedsLayout];
}];
```
####六、AutoLayout调试
#####1. 不可满足的约束条件
当因为有不满足约束条件而抛出异常的时候，我们可以打上断点，如果不是很明确是哪个视图导致的问题，你就需要通过内存地址来辨认视图：

```
(lldb) po [[0x7731880 superview] recursiveDescription]
$3 = 0x07117ac0 <UIView: 0x7730fe0; frame = (32 128; 259 604); layer = <CALayer: 0x7731150>>
   | <UIView: 0x7731880; frame = (90 -50; 80 100); layer = <CALayer: 0x7731450>>
   | <UIView: 0x7731aa0; frame = (90 101; 80 100); layer = <CALayer: 0x7731c60>>
```
一个更直观的方法是在控制台修改有问题的视图，这样你可以在屏幕上标注出来。比如，你可以改变它的背景颜色：

```
(lldb) expr ((UIView *)0x7731880).backgroundColor = [UIColor purpleColor]
```
然后从断点处继续执行，就可以看到效果。
你也可以通过改进错误信息本身，来更容易地在 iOS 中弄懂不可满足的约束条件错误到底在哪里。我们可以在一个 category 中重写 NSLayoutConstraint 的描述，并且将视图的 tags 包含进去：

```
@implementation NSLayoutConstraint (AutoLayoutDebugging)
#ifdef DEBUG
- (NSString *)description
{
    NSString *description = super.description;
    NSString *asciiArtDescription = self.asciiArtDescription;
    return [description stringByAppendingFormat:@" %@ (%@, %@)", 
        asciiArtDescription, [self.firstItem tag], [self.secondItem tag]];
}
#endif
@end
```
如果整数的 tag 属性信息不够的话，我们还可以得到更多新奇的东西，并且在视图类中增加我们自己命名的属性，然后可以打印到错误消息中。

```
@interface UIView (AutoLayoutDebugging)
- (void)setAbc_NameTag:(NSString *)nameTag;
- (NSString *)abc_nameTag;
@end
@implementation UIView (AutoLayoutDebugging)
- (void)setAbc_NameTag:(NSString *)nameTag
{
    objc_setAssociatedObject(self, "abc_nameTag", nameTag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)abc_nameTag
{
    return objc_getAssociatedObject(self, "abc_nameTag");
}
@end
@implementation NSLayoutConstraint (AutoLayoutDebugging)
#ifdef DEBUG
- (NSString *)description
{
    NSString *description = super.description;
    NSString *asciiArtDescription = self.asciiArtDescription;
    return [description stringByAppendingFormat:@" %@ (%@, %@)", asciiArtDescription, [self.firstItem abc_nameTag], [self.secondItem abc_nameTag]];
}
#endif
@end
```
另外还有一个打印调试信息的方法：
[issue-3-auto-layout-debugging](https://github.com/objcio/issue-3-auto-layout-debugging/blob/master/NSLayoutConstraint%2BDebugging.m)
#####2. 有歧义的布局
UIView提供了三种方式来查明有歧义的布局：`hasAmbiguousLayout`，`exerciseAmbiguityInLayout`，和私有方法 `_autolayoutTrace`。如果我们不想自己遍历视图层并记录这个值，可以使用私有方法 _autolayoutTrace。这将返回一个描述整个视图树的字符串：类似于 recursiveDescription 的输出（当视图存在有歧义的布局时，这个方法会告诉你）。

```
@implementation UIView (AutoLayoutDebugging)
- (void)printAutoLayoutTrace {
    #ifdef DEBUG
    NSLog(@"%@", [self performSelector:@selector(_autolayoutTrace)]);
    #endif
}
@end
```
另一个标识出有歧义布局更直观的方法就是使用 exerciseAmbiguityInLayout。这将会在有效值之间随机改变视图的 frame。然而，每次调用这个方法只会改变 frame 一次。所以当你启动程序的时候，你根本不会看到改变。创建一个遍历所有视图层级的辅助方法是一个不错的主意，并且让所有包含歧义布局的视图`晃动 `。

```
@implementation UIView (AutoLayoutDebugging)
- (void)exerciseAmiguityInLayoutRepeatedly:(BOOL)recursive {
    #ifdef DEBUG
    if (self.hasAmbiguousLayout) {
        [NSTimer scheduledTimerWithTimeInterval:.5
                                     target:self
                                   selector:@selector(exerciseAmbiguityInLayout)
                                   userInfo:nil
                                    repeats:YES];
    }
    if (recursive) {
        for (UIView *subview in self.subviews) {
            [subview exerciseAmbiguityInLayoutRepeatedly:YES];
        }
    }
    #endif
} 
@end
```
#####3. NSUserDefault选项
有几个有用的 NSUserDefault 选项可以帮助我们调试、测试自动布局：
- `UIViewShowAlignmentRects`: 设置视图可见的`alignment rects`。
- `NSDoubleLocalizedStrings`: 简单的获取并复制每个本地化的字符串。这是一个测试更长语言布局的好方法。
- `AppleTextDirection` 和 `NSForceRightToLeftWritingDirection`: 模拟从右到左的语言

我们可以通过`代码`和`scheme editor `设置。

```
[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSDoubleLocalizedStrings"];
```

![](http://img.objccn.io/issue-3/NSDoubleLocalizedStrings.png)

####七、AutoLayout性能
自动布局是布局过程中额外的一个步骤。它需要一组约束条件，并把这些约束条件转换成 frame。因此这自然会产生一些性能的影响。如果我们对一些复杂的视图的性能要求比较高，就避免通过约束来布局，`直接通过计算视图的frame来布局。`
####八、总结
自动布局是一个帮助我们灵活布局的工具，我们熟悉了以上这些自动布局的知识后，在UI布局层面会给我们很多乐趣。
