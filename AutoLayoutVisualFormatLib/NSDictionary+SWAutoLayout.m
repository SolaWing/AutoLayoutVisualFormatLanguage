//
//  NSDictionary+SWAutoLayout.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "NSDictionary+SWAutoLayout.h"
#import "AutoLayoutFormatAnalyzer.h"
#import "NSArray+SWAutoLayout.h"

@implementation NSDictionary (SWAutoLayout)

-(NSArray*)constraintsWithVisualFormat:(NSString*)formatString {
    return constraintsWithFormat(formatString, self);
}

- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans {
    [self enumerateKeysAndObjectsUsingBlock:^(__unused id key, UIView* obj, __unused BOOL *stop){
         if ([obj isKindOfClass:[UIView class]]) {
             obj.translatesAutoresizingMaskIntoConstraints = trans;
         }
    }];
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
@end

