//
//  NSLayoutConstraint+SWAutoLayout.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/26.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "NSLayoutConstraint+SWAutoLayout.h"
#import "objc/runtime.h"
#import "AutoLayoutFormatAnalyzer.h"

static void sw_NSLayoutConstraint_setActive(NSLayoutConstraint* self, __unused SEL _cmd, BOOL active) {
    UIView* commonAncestor = findCommonAncestor(
            self.firstItem, self.secondItem);
    if (active) {
        [commonAncestor addConstraint:self];
    } else {
        [commonAncestor removeConstraint:self];
    }
}

static BOOL sw_NSLayoutConstraint_isActive(NSLayoutConstraint* self, __unused SEL _cmd) {
    UIView* commonAncestor = findCommonAncestor(self.firstItem, self.secondItem);
    return [commonAncestor.constraints containsObject:self];
}

static void sw_NSLayoutConstraint_activateConstraints(__unused id cls, __unused SEL _cmd, NSArray* constraints) {
    for (NSLayoutConstraint* constraint in constraints){
        [findCommonAncestor(constraint.firstItem, constraint.secondItem)
            addConstraint:constraint];
    }
}

static void sw_NSLayoutConstraint_deactivateConstraints(__unused id cls, __unused SEL _cmd, NSArray* constraints) {
    for (NSLayoutConstraint* constraint in constraints){
        [findCommonAncestor(constraint.firstItem, constraint.secondItem)
            removeConstraint:constraint];
    }
}


@implementation NSLayoutConstraint (SWAutoLayout)

+ (void)load {
    // if no active property, add it.
    Class cls = [NSLayoutConstraint class];
    if (!class_getInstanceMethod(cls, @selector(setActive:))) {
        class_addMethod(cls, @selector(setActive:),
                (IMP)sw_NSLayoutConstraint_setActive, "v@:c");
        class_addMethod(cls, @selector(isActive),
                (IMP)sw_NSLayoutConstraint_isActive, "c@:");
    }

    cls = object_getClass(cls);
    if (!class_getInstanceMethod(cls, @selector(activateConstraints:))){
        class_addMethod(cls, @selector(activateConstraints:),
            (IMP)sw_NSLayoutConstraint_activateConstraints, "v@:@");
        class_addMethod(cls, @selector(deactivateConstraints:),
            (IMP)sw_NSLayoutConstraint_deactivateConstraints, "v@:@");
    }
}


@end
