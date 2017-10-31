AutoLayout Visual Format Language [中文介绍](#中文介绍)
==========================================
[![Support](https://img.shields.io/badge/ObjectiveC-iOS%206%2B-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Support](https://img.shields.io/badge/Swift-iOS%208%2B-blue.svg?style=flat)](https://www.apple.com/nl/ios/)

this is a superset of [Apple AutoLayout Visual Format][0]. it's compatible with Apple's,
and extend the syntax to make it powerful and convenient to use.

Feature
=======

* Compatible with [Apple's AutoLayout Visual Format Language][0].
* Super easy to use.
* Can create all needed constraints in one API call.
* Support create each view's constraints individually.
* Syntax is readable and intuitive.
* Support using array index, not limited to dictionary.
* Swift support string interpolation in format string.

Setup
=====

For Objective-C project, just drag **AutoLayoutVisualFormat** folder into your
project, and import "AutoLayoutVisualFormatLib.h"

For Swift project, there have a **VFL framework** target, you can add target
dependency to it, and import VFL module.

Or if you use carthage, you can add `github "SolaWing/AutoLayoutVisualFormatLanguage" "master"` to Carthage, and execute `carthage update`

How to use
==========

First, this project is **compatible** with [Apple's AutoLayout Visual Format Language][0].
if you used to use Apple's VFL, just change the API, and you can still use your familiar format string syntax.

**Apple's API:**

Objective-C:

```objc
NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:opts metrics:metrics views:views];
```

Swift:

```Swift
let constraints = NSLayoutConstraint.constraintsWithVisualFormat(formatString, options:opts, metrics:metrics, views:views)
```

**New VFL EQUIVALENT API:**

env, which can be a **array** or **dict** container, contains **metrics** and **views**. **options** integrated into **formatString**.

Objective-C

```objc
NSArray* constraints = VFLConstraints(formatString, env);
```

Swift

```Swift
let constraints = VFLConstraints(formatString, env);
```

</br>
</br>
**for convenience, VFL mainly have three kind of API:**

* API like `VFLConstraints`, create a array of constraints, and return it. this
  is the basic api
* API like `VFLInstall`, like `VFLConstraints`, but activate these constraints
  immediately.
* API like `VFLFullInstall`, will set `translatesAutoresizingMaskIntoConstraints` to NO for all views in Array or Dict, or the view self if use View's API.

and for Objective-C, there have macros to support **variadic** params like format string:

* API has `WithParams` suffix like `VFLConstraintsWithParams`, is Array Macro.
* API has `WithEnv` suffix like `VFLConstraintsWithEnv`, is Dict Macro. it use `NSDictionaryOfVariableBindings` at inner
* View category API use c variable argument list and can only use Array index syntax. **Note** $0 is view self.

for swift, it's not support macro and c variable argument list. but it support
    **string interpolation**. So it is recommended over use Array or Dict API.

### Example

To build 3 buttons in a view, centered and all have same space, width, height. as Follow:
![](https://raw.githubusercontent.com/SolaWing/Assets/VFL/FlowBtns.png)

Objective-C

```objc
VFLFullInstallWithEnv(@"|-space-[red(Y)]-space-[green]-space-[blue]-space-| WHY", red, green, blue, space);
```

Swift

```swift
VFL.fullInstall("|-\(space)-[\(red)(Y)]-\(space)-[\(green)]-\(space)-[\(blue)]-\(space)-| WHY")
```
</br>
</br>
To build a cell, which have a image, title, detail, and action button, as Follow:
![](https://raw.githubusercontent.com/SolaWing/Assets/VFL/Cell.png)

Objective-C

```objc
VFLFullInstallWithEnv(@"|-20-[image(Y, Top=10, Width=image.Height)]-[title(Top=image)]-(>=0)-[action(Y)]-20-|; V:[title]-(>=0)-[detail(Bottom=image)] L", image, title, detail, action);
```

Swift

```swift
VFL.fullInstall("|-20-[\(image)(Y, Top=10, Width=\(image).Height)]-[\(title)(Top=\(image))]-(>=0)-[\(action)(Y)]-20-|; V:[\(title)]-(>=0)-[\(detail)(Bottom=\(image))] L")
```

Or if you like to build constraints of each view individually, you can use:

Objective-C

```objc
[image VFLFullInstall:@"Left=20, Y, Top=10, Width=$0.Height"];
[title VFLFullInstall:@"Left=$1.Right+8, Top=$1", image];
[action VFLFullInstall:@"Left>=$1.Right, Y, Right=|-20", title];
[detail VFLFullInstall:@"Left=$1, Bottom=$2", title, image];
```

Swift

```swift
image.VFLFullInstall("Left=20, Y, Top=10, Width=\(image).Height")
title.VFLFullInstall("Left=$1.Right+8, Top=\(image)")
action.VFLFullInstall("Left>=\(title).Right, Y, Right=|-20")
detail.VFLFullInstall("Left=\(title), Bottom=\(image)")
```

more examples please see project.

Syntax
======

for [Apple's Syntax][0], you can see it [here][0].

for dict env, you can ref view or metric by key directly.  
for array env, ref the index by $0, $1...  
for swift, you can use string interpolation directly.  

##### Connect between views. (same as [Apple's Syntax][0])

* Connect two view with standard space:  
  `[button]-[textField]`

* Connect two view without space, as flush view:  
  `[view1][view2]`

* Connect two view with specified space:  
  `[button]-20-[textField]`

* Connect two view with variable space:  
  `[button]-spaceMetric-[textField]`

* Connect two view with inequal relation:  
  `[button]-(>=0, <=20)-[textField]`

* Priority:  
  `[button]-(>=0, <=20, 10@999)-[textField]`

* Connect to superview:  
  `|-20-[view]-20-|`

* Vertical Layout:  
  `V:[topField]-[bottomField]`

* A Complete Line of Layout and specifiy baseline alignment and same height for all connected views:(merge Apple's API `options` args into format string)  
  `|-[find]-[findNext]-[findField(>=20)]-| bH`

##### Specifiy individual views constraints
VFL recognize first letter as attribute, after is ignoring and can write word completely for readability

* Width Constraint:  
`[button(>=50)]`  
`[button(==button2)]`  
`[button(W=100)]`  
`[button(Width=100)]`  

* Height Constraint:  
`V:[button(30)]`  
`[button(H=30)]`  
`[button(Height=30)]`  
`[view(Height= | * 0.5)]`  

* Full Fill Super View: (use | token to represent superview)  
`[view(L, R, T, B)]`  
`[view(Left, Right, Top, Bottom)]`  
`[view(Left, Right, Top, Bottom)]`  
`[view(Left=|, Right=|, Top=|, Bottom=|)]`  
`[view(X,Y, Width=|, Height=|)]`  

* Position View:  
`[view(Left=10, Top=10)]`  
`[view(Left=view2, Top=view3)]`  
`[view(Left=view2.Right+8, Top=view3.Bottom+10)]`  
`[view(X, Y=-10)]`  
`[view(Right=-10, Bottom=-10)]`  
`[view(Right=|-10, Bottom=|-10)]`  

* A full complete constraint example:(as `attr1 == view2.attr2 * multiplier + constant @priority`, each part is optional and have default value)  
`[view(Left==|.Left * 1.0 + 0 @1000, Top==|.Top * 1.0 + 0 @1000)]`

full detail syntax you can see in `AutoLayoutFormatAnalyzer.h`

More
====

if you like it, please support me and star it.

if you find any bugs or have any ideas, please contact me.

PR is also welcome.

<br/><br/>
- - -

中文介绍
==========================================

本项目是[苹果AutoLayout Visual Format][0]的语言的扩展, 使得该语言更强大而且便于使用

特点
=======

* 和[苹果的AutoLayout Visual Format Language][0]兼容.
* 容易使用.
* 一次API调用, 创建所有的约束.
* 支持对个别视图约束进行单独设置.
* 良好的可读性.
* 支持数组索引, 不仅限于字典Key索引.
* Swift支持字符串插值.

集成
=====

若是Objective-C的项目, 直接把**AutoLayoutVisualFormat**文件夹拖进项目里, 导入"AutoLayoutVisualFormatLib.h"头文件即可使用

若是Swift项目, 可以使用**VFL framework**, 添加依赖, 导入VFL模块即可使用

如何使用
==========

首先, 本项目语法是和[苹果AutoLayout Visual Format Language][0]兼容的,
所以你完全可以像使用官方VFL一样使用本项目

**Apple's API:**

Objective-C

```objc
NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:opts metrics:metrics views:views];
```

Swift

```Swift
let constraints = NSLayoutConstraint.constraintsWithVisualFormat(formatString, options:opts, metrics:metrics, views:views)
```

**New VFL EQUIVALENT API:**

metrics和views都放入env中, options集成到字符串里了

Objective-C

```objc
NSArray* constraints = VFLConstraints(formatString, env);
```

Swift

```Swift
let constraints = VFLConstraints(formatString, env);
```
</br>
</br>
**本项目主要有三种类型的API:**

* 类似`VFLConstraints`的API, 创建一组约束并返回. 这是最基本的API.
  is the basic api
* 类似`VFLInstall`的API, 除创建约束并返回外, 还会自动生效
  immediately.
* 类似`VFLFullInstall`的API, 除自动生效外, 会将相应视图`translatesAutoresizingMaskIntoConstraints`属性设为NO. (数组字典中的View, 使用View扩展类中的API则为View自身)

对于Objective-C项目, 有支持**可变参数**的方便使用的宏.
对于Swift项目, 支持**字符串插值**格式的字符串.

具体API请看源文件.

### Example

创建3个等宽等高等间距的button, 并居中:
![](https://raw.githubusercontent.com/SolaWing/Assets/VFL/FlowBtns.png)

Objective-C

```objc
VFLFullInstallWithEnv(@"|-space-[red(Y)]-space-[green]-space-[blue]-space-| WHY", red, green, blue, space);
```

Swift

```swift
VFL.fullInstall("|-\(space)-[\(red)(Y)]-\(space)-[\(green)]-\(space)-[\(blue)]-\(space)-| WHY")
```

</br>
</br>



创建包含image, title, detail, 和action button的Cell:
![](https://raw.githubusercontent.com/SolaWing/Assets/VFL/Cell.png)

Objective-C

```objc
VFLFullInstallWithEnv(@"|-20-[image(Y, Top=10, Width=image.Height)]-[title(Top=image)]-(>=0)-[action(Y)]-20-|; V:[title]-(>=0)-[detail(Bottom=image)] L", image, title, detail, action);
```

Swift

```swift
VFL.fullInstall("|-20-[\(image)(Y, Top=10, Width=\(image).Height)]-[\(title)(Top=\(image))]-(>=0)-[\(action)(Y)]-20-|; V:[\(title)]-(>=0)-[\(detail)(Bottom=\(image))] L")
```

如果你喜欢一个个view的指定约束, 可以这样写:

Objective-C

```objc
[image VFLFullInstall:@"Left=20, Y, Top=10, Width=$0.Height"];
[title VFLFullInstall:@"Left=$1.Right+8, Top=$1", image];
[action VFLFullInstall:@"Left>=$1.Right, Y, Right=|-20", title];
[detail VFLFullInstall:@"Left=$1, Bottom=$2", title, image];
```

Swift

```swift
image.VFLFullInstall("Left=20, Y, Top=10, Width=\(image).Height")
title.VFLFullInstall("Left=$1.Right+8, Top=\(image)")
action.VFLFullInstall("Left>=\(title).Right, Y, Right=|-20")
detail.VFLFullInstall("Left=\(title), Bottom=\(image)")
```

更多例子请看项目示例

语法
====

对于使用Dict相关API, 你可以直接通过Key Identifier引用对应元素.
对于使用Array相关API, 你可以使用$0,$1...类似的索引.
对于swift项目, 除手动创建字典, 数组外, 支持字符串插值形式调用.

##### 连接视图. (和[苹果语法][0]一样)

* 标准间距  
  `[button]-[textField]`

* 无间距  
  `[view1][view2]`

* 指定间距  
  `[button]-20-[textField]`

* 支持引用变量参数, 来动态指定间距  
  `[button]-spaceMetric-[textField]`

* 不等式约束  
  `[button]-(>=0, <=20)-[textField]`

* 优先级  
  `[button]-(>=0, <=20, 10@999)-[textField]`

* 连接SuperView  
  `|-20-[view]-20-|`

* 垂直布局  
  `V:[topField]-[bottomField]`

* 完整一行, 并通过语句末尾指定对齐baseline, 所有视图高度相等的约束(集成苹果options参数)  
  `|-[find]-[findNext]-[findField(>=20)]-| bH`


##### 给每个视图单独指定约束

VFL使用首字母来区分指定的属性, 后面的字母忽略, 所以可以写全来加强可读性

* 宽度约束:  
`[button(>=50)]`  
`[button(==button2)]`  
`[button(W=100)]`  
`[button(Width=100)]`  

* 高度约束:  
`V:[button(30)]`  
`[button(H=30)]`  
`[button(Height=30)]`  
`[view(Height= | * 0.5)]`  

* 完全填满SuperView: (使用 `|` 符号来代表superview)  
`[view(L, R, T, B)]`  
`[view(Left, Right, Top, Bottom)]`  
`[view(Left, Right, Top, Bottom)]`  
`[view(Left=|, Right=|, Top=|, Bottom=|)]`  
`[view(X,Y, Width=|, Height=|)]`  

* 定位:  
`[view(Left=10, Top=10)]`  
`[view(Left=view2, Top=view3)]`  
`[view(Left=view2.Right+8, Top=view3.Bottom+10)]`  
`[view(X, Y=-10)]`  
`[view(Right=-10, Bottom=-10)]`  
`[view(Right=|-10, Bottom=|-10)]`  

* 完整的约束语法:(`attr1 == view2.attr2 * multiplier + constant @priority`,
  每一部分都有相应的默认值且可省略)  
`[view(Left==|.Left * 1.0 + 0 @1000, Top==|.Top * 1.0 + 0 @1000)]`

完整语法解释请看`AutoLayoutFormatAnalyzer.h`

更多
====

如果你喜欢本项目, 请支持我点个星.
如果你发现任何BUG, 或有任何好想法, 请联系我.  
如果有PR, 就更加感激啦.

[0]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html#//apple_ref/doc/uid/TP40010853-CH27-SW1
