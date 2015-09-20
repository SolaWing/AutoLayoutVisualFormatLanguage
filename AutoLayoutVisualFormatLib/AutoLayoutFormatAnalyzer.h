//
//  AutoLayoutFormatAnalyzer.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
<visualFormat>      :   <visualStatement>(;<visualStatement>)*
<visualStatement>   :   (<orientation>:)?(<superview><connection>)?<view>(<connection><view>)*(<connection><superview>)?(<align>)*
                        "orient def H, superview def empty"
<orientation>       :   H|V
<superview>         :   |
<view>              :   [<viewIndex>(predicateList)?]
<align>             :   [LRTBXYltbWH]
                        "Left,Right,Top,Bottom,CenterX,CenterY,leading,trailing,baseline,Width,Height"
                        "align all connect view in one statement(except superview) according to align flag"
<connection>        :   <empty>|-<predicateList>-|-                             :empty use 0 space, - use default space
<predicateList>     :   <predicate>(,<predicate>)*                              :encapsulate with () is optional
<predicate>         :   (<attr1>)?(<relation>)?(<viewIndex>)?(.?<attr2>)?(*<multiplier>)?(<constant>)?(@<priority>)?
                        "relation default ==, priority default required. multiplier default 1.0, constant default 0"
                        "<viewIndex> can only be used in <view>, if attr2 followed, attr2 need use . to seperate"

                        "if attr1 and attr2 both empty, use default attr, that is:"
                        "when use in connect between super and view, they're both left or right. according to super at front or back"
                        "when use in connect between views, they're right and left"
                        "when use in view predicate, they're both width"
                        "when vertical predicate, change attr from left,right,width to top,bottom,height"

                        "if only set attr1, attr2 is supposed equal to attr1"
                        "if only set attr2, attr1 still set as default value"
<attr>              :   [LRTBXYltbWH]
<relation>          :   ==|<=|>=
<constant>          :   ([+-])?<number>|<metricIndex>
<multiplier>        :   <number>|<metricIndex>
<priority>          :   <number>|<metricIndex>
<viewIndex>         :   $?<identifier> in dict | $<index> in array | `|` as superview
<metricIndex>       :   $?<identifier> in dict | $<index> in array
                        $ for dict index is optional. $ for array index can only omit at the <viewIndex> part of <view>
<number>            :   As parsed by `strtod`
 */
NSArray* constraintsWithFormat(NSString* format, id env);

/** helper func to active NSLayoutConstraint, if not found, return nil */
UIView* findCommonAncestor(UIView* view1, UIView* view2);
