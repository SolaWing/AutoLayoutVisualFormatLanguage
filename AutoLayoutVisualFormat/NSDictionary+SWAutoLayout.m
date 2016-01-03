//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
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

- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans {
    [self enumerateKeysAndObjectsUsingBlock:^(__unused id key, UIView* obj, __unused BOOL *stop){
         if ([obj isKindOfClass:[UIView class]]) {
             obj.translatesAutoresizingMaskIntoConstraints = trans;
         }
    }];
    return self;
}

-(NSArray<NSLayoutConstraint*>*) VFLConstraints:(NSString*)format {
    return VFLConstraints(format, self);
}

- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format {
    NSArray* ret = VFLConstraints(format, self);
    [ret activateConstraints];
    return ret;
}

- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format {
    [self translatesAutoresizingMaskIntoConstraints:NO];
    NSArray* ret = VFLConstraints(format, self);
    [ret activateConstraints];
    return ret;
}
@end

