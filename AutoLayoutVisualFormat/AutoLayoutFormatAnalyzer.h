//
//  AutoLayoutFormatAnalyzer.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** the syntax is as follow. and completely compatible with Apple Visual Format Language

<visualFormat>      :   <visualStatement>(;<visualStatement>)*
<visualStatement>   :   (<orientation>:)?(<superview><connection>)?<view>(<connection><view>)*(<connection><superview>)?(<align>)*
                        "orient init default H, after visualStatement default equal to previous orient. superview default empty"
<orientation>       :   H|V
<superview>         :   |
<view>              :   [<viewIndex>(<predicateList>)?]
<align>             :   [LRTBXYltbWH]
                        "Left,Right,Top,Bottom,CenterX,CenterY,leading,trailing,baseline,Width,Height"
                        "align all connect view in one statement(except superview) according to align flag"
<connection>        :   <empty>|-<predicateList>-|-                             :empty use 0 space, - use default space
<predicateList>     :   <predicate>(,<predicate>)*                              :encapsulate with () is optional
<predicate>         :   (<identifier>:)?(<attr1>)?(<relation>)?(<viewIndex>)?(.?<attr2>)?(*<multiplier>)?(<constant>)?(@<priority>)?
                        "predicate can give a identifier as name."
                        "if give, the generate constraint is added to a weak table"
                        "you can get it from `VFLConstraintForKey` function"

                        "relation default ==, priority default required. multiplier default 1.0, constant default 0"
                        "<viewIndex> can only be used in <view>, default nil."
                        "or if first view attr must need a secondView, it's superview"
                        "if attr2 followed, attr2 need use . to seperate"

                        "if attr1 and attr2 both empty, use default attr, that is:"
                        "when use in connect between super and view, they're both left or right. according to super at front or back"
                        "when use in connect between views, they're left and right"
                        "when use in view predicate, they're both width"
                        "when vertical predicate, change attr from left,right,width to top,bottom,height"

                        "if only set attr1, attr2 is supposed equal to attr1"
                        "if only set attr2, attr1 still set as default value"

                        "so, each predicate will convert to a constraint"
                        "for <connect>, equal to: secondView.attr1 == firstView.attr2 * multiplier + constant"
                        "for <view>, equal to: mainView.attr1 == predicateView.attr2 * multiplier + constant"
<attr>              :   [LRTBXYltbWH]
<relation>          :   ==|<=|>=
<constant>          :   ([+-])?<number>|<metricIndex>
<multiplier>        :   <number>|<metricIndex>
<priority>          :   <number>|<metricIndex>
<viewIndex>         :   $?<identifier> in dict | $<index> in array | `|` as superview
<metricIndex>       :   $?<identifier> in dict | $<index> in array
                        $ for dict index is optional. $ for array index can only omit at the <viewIndex> part of <view>
<number>            :   As parsed by `strtod`
<identifier>        :  [a-zA-Z_][a-zA-Z0-9_]*
<index>             :  non-negative integer
 */

/** create and return a array of constraints
 *
 * @param format: VFL format string
 * @param env:    NSArray or NSDictionary, used as index env
 */
NSArray<NSLayoutConstraint*>* VFLConstraints(NSString* format, id env);

/** create and return a array of constraints. these constraints are active immediately */
NSArray<NSLayoutConstraint*>* VFLInstall(NSString* format, id env);

/** one shot for disable translatesAutoresizingMaskIntoConstraints of view in env, create constraints, and active it */
NSArray<NSLayoutConstraint*>* VFLFullInstall(NSString* format, id env);

/** subset of VFL, only contain <predicateList>, pass in view is firstView.
 * @return generate constraints
 */
NSArray<NSLayoutConstraint*>* VFLViewConstraints(NSString* format, UIView* view, id env);

/** helper func to active NSLayoutConstraint, if not found, return nil */
UIView* findCommonAncestor(UIView* view1, UIView* view2);

/** you can get identifier constraints from this function */
id VFLObjectForKey(NSString* key);
static inline NSLayoutConstraint* VFLConstraintForKey(NSString* key) { return VFLObjectForKey(key); }
void VFLSetObjectForKey(id obj, NSString* key);
