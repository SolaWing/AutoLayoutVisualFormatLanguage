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

- (NSArray<NSLayoutConstraint*>*)constraintsAlignAllViews:(NSLayoutAttribute)attr {
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

- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans {
    for (UIView* element in self){
        if ([element isKindOfClass:[UIView class]]){
            element.translatesAutoresizingMaskIntoConstraints = trans;
        }
    }
    return self;
}

-(NSArray*)VFLConstraints:(NSString*)format {
    return VFLConstraints(format, self);
}

- (NSArray*)VFLInstall:(NSString*)format {
    NSArray* ret = VFLConstraints(format, self);
    [ret activateConstraints];
    return ret;
}

- (NSArray*)VFLFullInstall:(NSString*)format {
    [self translatesAutoresizingMaskIntoConstraints:NO];
    NSArray* ret = VFLConstraints(format, self);
    [ret activateConstraints];
    return ret;
}

- (void)activateConstraints {
    [NSLayoutConstraint activateConstraints:self];
}

- (void)deactivateConstraints {
    [NSLayoutConstraint deactivateConstraints:self];
}

@end
