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
正如上图解释的一样，Hit-Testing是在每次手指触摸时执行的。并且是在任何视图或者手势收到`UIEvent`（代表触摸属于的事件）之前。

```
注意：不知道什么原因，Hit-Testing会执行多次，但是确定的`hit-test`视图是一样的
```
在Hit-Testing完成和在触摸点下最前端的视图确认下来之后，`hit-test`会被关联所有触摸事件各个阶段（`begin`,`moved`,`ended`,`canceled`）的`UITouch`对象。除了`hit-test`视图，绑定到该视图的任何手势识别器和他的祖先视图都会关联到`UITouch`对象。然后，`hit-test`视图开始接收触摸事件的序列。

一个需要注意的重要的事情是即使手指移动出了`hit-test`视图的边界到了另外一个视图,`hit-test`视图任然继续接收所有的触摸事件直到触摸事件结束。

> “触摸对象在整个生命周期内都关联他的`hit-test`视图，即使触摸移动到了这个视图的外面”  [Event Handling Guide for iOS, iOS Developer Library](https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/event_delivery_responder_chain/event_delivery_responder_chain.html#//apple_ref/doc/uid/TP40009541-CH4-SW4)

正如前面提到的Hit-Testing采用深度优先的反序访问迭代算法（先访问根节点然后从高到低访问低节点）。这种遍历方法可以减少遍历迭代的次数，一旦找到最深的包含触摸点的后裔视图就停止遍历。这是可能的因为子视图总是渲染在父视图的前面和兄弟节点中在数组中靠后的视图渲染在靠前的视图前面。所以当多个视图包含指定的点的时候，最右边子树的最深视图就是最前面的视图。
> 可见的是子视图的内容模糊了所有父视图的内容。每一个父视图存储他的子视图于一个有序的数组中，在数组中的顺序会影响子视图的显示。如果两个兄弟视图相互覆盖，后加入的视图（存储在子视图数组的后面）出现在另一个的上面。 [View Programming Guide for iOS, iOS Developer Library](https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html#//apple_ref/doc/uid/TP40009503-CH2-SW24)

下图显示了一个视图层次树的例子和对应的绘制在屏幕上的UI。树的叶节点从左到右反映出子视图数组的排序。

![](http://smnh.me/images/hit-test-view-hierarchy.png)

正如看到的，“View A”和“View B”和他们的子视图，“View A.2”和“View B.1”是重叠的。由于“View B”比“View A”有一个较高的子视图索引，所以“View B”和他的子视图被渲染在“View A”和他的子视图上面。因此，“View B.1”应该被`hit-testing`返回当用户的手指触摸在"View B.1"和“View A.2”的重叠区域。

通过深度优先的反向遍历允许一旦找到第一个最深的后裔包含触摸点的视图就停止遍历：

![](http://smnh.me/images/hit-test-depth-first-traversal.png)

遍历算法以向`UIWindow`（视图层次结构的根视图）发送`hitTest:withEvent:`消息开始。这个方法返回的值就是包含触摸点的最前面的视图。

下面流程图说明了`hit-test`逻辑。

![](http://smnh.me/images/hit-test-flowchart.png)

下面的代码显示了原生的`hitTest:withEvent:`方法的可能实现方式：

```
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}
```
`hitTest:withEvent:`方法首先检查视图是否允许接收触摸事件。视图允许接收触摸事件的条件是：

- 视图不是隐藏的:  `self.hidden == NO`
- 视图是允许交互的:  `self.userInteractionEnabled == YES`
- 视图透明度大于0.01:  `self.alpha > 0.01`
- 视图包含这个点:  `pointInside:withEvent: == YES`

然后，如果视图允许接收触摸事件，这个方法通过从后往前发送`hitTest:withEvent:`消息给每一个子视图来穿过接收者的子树，直到子视图中的一个返回`nil`。这些子视图中的第一个返回的非`nil`就是在触摸点下面的最前面的视图，被接收者返回。如果所有的子视图都返回`nil`或者接收者没有子视图返回接收者自己。

否则，如果视图不允许接收触摸事件，这个方法返回`nil`而根本不会传递到接收者的子树。因此，`hit-test`可能不会访问所有的视图体系结构中的视图。
###覆盖hitTest:withEvent:的一些用途
`hitTest:withEvent:`可以被覆盖，当所有触摸事件阶段的所有阶段的触摸事件想要被一个视图处理重定向到另外一个视图。
> 因为`hit-test`仅仅在触摸事件顺序的第一次触摸事件发送给他的接收者之前（有`UITouchPhaseBegan`阶段的触摸事件），覆盖`hitTest:withEvent:`来重定向事件将要重定向所有的触摸事件。

####1.增加视图的触摸区域
覆盖`hitTest:withEvent:`方法的一个用途就是，当一个视图的触摸区域应该大于他的边界的时候。例如下面的插图显示了一个大小为20*20的视图。这个大小对于处理附近的触摸来说太小了。因此，他的触摸区域可以通过覆盖`hitTest:withEvent:`在每个方向增加10。

![](http://smnh.me/images/hit-test-increase-touch-area.png)

```
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    CGRect touchRect = CGRectInset(self.bounds, -10, -10);
    if (CGRectContainsPoint(touchRect, point)) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}
```
```
注意：为了能够正确的调用`hit-test`，父视图的边界应该包含子视图希望触摸的区域，或者他的`hitTest:withEvent:`方法也应该被覆盖来包含期望的触摸区域。
```
####2.传递触摸事件给下面的视图
有的时候对于一个视图忽略触摸事件并传递给下面的视图是很重要的。例如，假设一个透明的视图覆盖在应用内所有视图的最上面。覆盖层有子视图应该相应触摸事件的一些控件和按钮。但是触摸覆盖层的其他区域应该传递给覆盖层下面的视图。为了完成这个行为，覆盖层需要覆盖`hitTest:withEvent:`方法来返回包含触摸点的子视图中的一个，然后其他情况返回`nil`，包括覆盖层包含触摸点的情况：

```
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self) {
        hitTestView = nil;
    }
    return hitTestView;
}
```
####2.传递触摸事件给子视图
一个不同的使用场景可能需要父视图重定向所有的触摸事件给他唯一的子视图。这个行为是有必要的当子视图部分占据他的父视图，但是子视图应该响应所有的触摸事件包括发生在父视图上的。例如，假设一个由一个父视图和一个`pagingEnabled`设置为`YES`和`clipsToBounds`设置为`NO`（为了实现传动带的效果）的`UIScrollView`组成的图片浏览器：

![](http://smnh.me/images/hit-test-pass-touches-to-subviews.png)

为了使`UIScrollView`响应不发生在自己边界内但是在父视图的边界内的触摸事件，父视图的`hitTest:withEvent:`方法应该像下面这样重写：

```
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView) {
        hitTestView = self.scrollView;
    }
    return hitTestView;
}
```