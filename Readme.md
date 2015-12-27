AutoLayout Visual Format Language
=================================

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

For Objective-C project, just drag *AutoLayoutVisualFormat* folder into your
project, and import "AutoLayoutVisualFormatLib.h"

For Swift project, there have a VFL framework target, you can add target
dependency to it, and import VFL module.

Requirement
===========

**objective-C** : >= iOS 6.0

**swift** : >= iOS 8.0

How to use
==========

First, this project is **compatible** with [Apple's AutoLayout Visual Format Language][0].
if you used to use Apple's, just change the API, and format string don't need to change.

**Apple's API:**

```objc
NSArray* constraints = [NSLayoutConstraint constraintsWithVisualFormat:formatString options:opts metrics:metrics views:views];
```

```Swift
let constraints = NSLayoutConstraint.constraintsWithVisualFormat(formatString, options:opts, metrics:metrics, views:views)
```

**New VFL API:**
env contains metrics and views. options integrated into formatString.

```objc
NSArray* constraints = VFLConstraints(formatString, env);
```

```Swift
let constraints = VFLConstraints(formatString, env);
```

for convenience, VFL mainly have three kind of API:

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

### Syntax
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

##### Complete Examples

Suppose I need a cell which have left ImageView, a Title text, a Detail text, and rihgt have a action button.
I can write all constraints as follow: (use ; to seperator statement and change default horzontal layout to vertical layout)

    |-[Image(Y)]-[Title(Top=Image)]-(>=0)-[button(Y)]-|; V:[Title]-(>=0)-[Detail(Bottom=Image)] L;

If I want to have a video play control bar, from left to right is:
play button, play time label, progress bar, total time label, fullscreen btn.
I can write as:

    |-[play(Y)]-[playTime]-[progress]-[total]-[fullscreen]-| Y;

more examples please see project.

full detail syntax you can see in `AutoLayoutFormatAnalyzer.h`

More
====

if you find any bugs or have any ideas, please contact me.

PR is welcome.

[0]: https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html#//apple_ref/doc/uid/TP40010853-CH27-SW1
