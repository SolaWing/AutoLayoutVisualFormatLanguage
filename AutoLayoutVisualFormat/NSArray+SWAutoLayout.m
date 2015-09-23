//
//  NSArray+SWAutoLayout.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "NSArray+SWAutoLayout.h"
#import "AutoLayoutFormatAnalyzer.h"

@implementation NSArray (SWAutoLayout)

-(NSArray*)constraintsAlignAllViews:(NSLayoutAttribute)attr {
    NSUInteger count = self.count;
    if (count < 2) return nil;

    NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:count - 1];
    UIView* first = self[0];
    for (NSUInteger i = 1; i < count; ++i) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:first
             attribute:attr relatedBy:NSLayoutRelationEqual
                toItem:self[i] attribute:attr multiplier:1.0 constant:0]];
    }
    return constraints;
}

-(NSArray*)constraintsWithVisualFormat:(NSString*)formatString {
    return constraintsWithFormat(formatString, self);
}

- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans {
    for (UIView* element in self){
        if ([element isKindOfClass:[UIView class]]){
            element.translatesAutoresizingMaskIntoConstraints = trans;
        }
    }
    return self;
}

- (NSArray*)installConstraintsWithVisualFormat:(NSString*)formatString {
    NSArray* ret = constraintsWithFormat(formatString, self);
    [ret activeConstrains];
    return ret;
}

- (NSArray*)installFullConstraintsWithVisualFormat:(NSString*)formatString {
    [self translatesAutoresizingMaskIntoConstraints:NO];
    NSArray* ret = constraintsWithFormat(formatString, self);
    [ret activeConstrains];
    return ret;
}

- (void)activeConstrains {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    for (NSLayoutConstraint* constraint in self){
        [constraint setActive:YES];
    }
#else
    
    if ([NSLayoutConstraint instancesRespondToSelector:@selector(setActive:)]) {
        for (NSLayoutConstraint* constraint in self){
            [constraint setActive:YES];
        }
    } else {
        for (NSLayoutConstraint* constraint in self){
            [findCommonAncestor(constraint.firstItem, constraint.secondItem)
                addConstraint:constraint];
        }
    }
#endif
}

@end
