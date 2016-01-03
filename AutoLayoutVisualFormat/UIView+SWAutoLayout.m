//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  UIView+SWAutoLayout.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/24.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "UIView+SWAutoLayout.h"
#import "NSArray+SWAutoLayout.h"
#import "AutoLayoutFormatAnalyzer.h"

static NSUInteger getMaxIndexValueInFormat(NSString* format) {
    const char* it = format.UTF8String;
    unsigned long maxIndex = 0;
    unsigned long n;
    while ((it = strchr(it, '$'))) {
        ++it;
        n = strtoul(it, (char**)&it, 10);
        if (n > maxIndex) maxIndex = n;
    }
    return maxIndex;
}

@implementation UIView (SWAutoLayout)

- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format andVarArg:(va_list*)ap {
    NSMutableArray* env = [NSMutableArray arrayWithObject:self];
    NSUInteger count = getMaxIndexValueInFormat(format) + 1;
    NSUInteger i = 1;
    while ( i++<count ){
        [env addObject: va_arg(*ap, id)];
    }
    return VFLViewConstraints(format, self, env);
}

- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format, ... {
    va_list ap; va_start(ap, format);
    NSArray* constraints = [self VFLConstraints:format andVarArg:&ap];
    va_end(ap);

    return constraints;
}

- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format, ... {
    va_list ap; va_start(ap, format);
    NSArray* constraints = [self VFLConstraints:format andVarArg:&ap];
    va_end(ap);
    [constraints activateConstraints];
    return constraints;
}

- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format, ... {
    va_list ap; va_start(ap, format);
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray* constraints = [self VFLConstraints:format andVarArg:&ap];
    va_end(ap);
    [constraints activateConstraints];
    return constraints;
}

@end
