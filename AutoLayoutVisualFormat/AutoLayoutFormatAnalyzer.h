//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  AutoLayoutFormatAnalyzer.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VFLVersion 1.01

NS_ASSUME_NONNULL_BEGIN

extern bool VFLEnableAssert;

/** the syntax is as follow. and completely compatible with Apple Visual Format Language

<visualFormat>      :   <visualStatement>(;<visualStatement>)*
<visualStatement>   :   (<orientation>:)?(<layoutEdge><connection>)?<view>(<connection><view>)*(<connection><layoutEdge>)? (<align>)*
                        orient init default H, after visualStatement default equal to previous orient
<orientation>       :   H|V|F
                        H: horizontal, connect from left to right
                        V: verticle, connect from top to bottom
                        F: flow, connect from leading to trailing.
                           this is same as Apple VFL's H. but I think left to right is more practical.
                           and in RTL context, leading to trailing may be hard to guarantee work in both direction.
<layoutEdge>        :   |[msr]?
                        | means superview
                        |m means superview's margin guide
                        |s means superview's safeAreaLayoutGuide
                        |r means superview's readableContentGuide
<view>              :   [<viewIndex>(<predicateList>)?]
<align>             :   [LRTBXYltbWH]
                        Left,Right,Top,Bottom,CenterX,CenterY,leading,trailing,baseline,Width,Height
                        align all connect view in one statement(except superview) according to align flag
                        generate align constraints will connect adjacent views
<connection>        :   <empty>|-<predicateList>-|-
                        empty use 0 space, - use default space(if connect to superview, will connect to layout margin guide)
<predicateList>     :   <predicate>(,<predicate>)*                              :can optional encapsulate with ()
<predicate>         :   (<identifier>:)?(<attr1>)?(<relation>)?(<viewIndex>)?(.?<attr2>)?(*<multiplier>)?([+-]?<constant>)?(@<priority>)?
                        predicate can give a identifier as name.
                        if given, the generate constraint is added to a weak table
                        you can get it from `VFLConstraintForKey` function

                        relation default ==, priority default required. multiplier default 1.0, constant default 0
                        <viewIndex> can only be used in <view>, default nil.
                        or if first view attr must need a secondView, it's superview
                        |, |m, etc. is a valid view token.
                        if attr2 followed, attr2 need use . to seperate

                        if attr1 and attr2 both empty, use default attr, that is:
                        when use in connect between super and view, they're both left(leading in F) or right(trailing in F). according to super at front or back
                        when use in connect between views, they're left(leading in F) and right(trailing in F)
                        when use in view predicate, they're both width
                        when vertical predicate, change attr from left(leading in F),right(trailing in F),width to top,bottom,height

                        if only set attr1, attr2 is supposed equal to attr1
                        if only set attr2, attr1 still set as default value

                        so, each predicate will convert to a constraint
                        for <connect>, equal to: secondView.attr1 == firstView.attr2 * multiplier + constant
                        for <view>, equal to: mainView.attr1 == predicateView.attr2 * multiplier + constant
<attr>              :   [LRTBXYltbWH]
                        same as align attr, but the attr can spell full, like Left,baseline, etc.
<relation>          :   ==|<=|>=
<constant>          :   <number>|<metricIndex>
<multiplier>        :   <number>|<metricIndex>
<priority>          :   <number>|<metricIndex>
<viewIndex>         :   $?<identifier> in dict | $<index> in array | `|` as superview
<metricIndex>       :   $?<identifier> in dict | $<index> in array
                        $ for dict index is optional. $ for array index can only omit at the <viewIndex> part of <view>
<number>            :   As parsed by `strtod`
<identifier>        :   [a-zA-Z_][a-zA-Z0-9_]*
<index>             :   non-negative integer
 */

/** create and return a array of constraints
 *
 * @param format VFL format string
 * @param env    NSArray or NSDictionary, used as index env
 */
NSArray<NSLayoutConstraint*>* VFLConstraints(NSString* format, id env);

/** create and return a array of constraints. these constraints are active immediately */
NSArray<NSLayoutConstraint*>* VFLInstall(NSString* format, id env);

/** one shot for disable translatesAutoresizingMaskIntoConstraints of view in env, create constraints, and active it */
NSArray<NSLayoutConstraint*>* VFLFullInstall(NSString* format, id env);

/** subset of VFL, only contain <predicateList>, pass in view is firstView.
 * @param view view or guide
 * @return generate constraints
 */
NSArray<NSLayoutConstraint*>* VFLViewConstraints(NSString* format, id view, id env);

/** helper func to active NSLayoutConstraint, if not found, return nil */
 UIView* _Nullable findCommonAncestor(UIView* _Nullable view1, UIView* _Nullable view2);

/** you can get identifier constraints from this function */
_Nullable id VFLObjectForKey(NSString* key);
static inline NSLayoutConstraint* _Nullable VFLConstraintForKey(NSString* key) { return VFLObjectForKey(key); }
void VFLSetObjectForKey(id _Nullable obj, NSString* key);

NS_ASSUME_NONNULL_END
