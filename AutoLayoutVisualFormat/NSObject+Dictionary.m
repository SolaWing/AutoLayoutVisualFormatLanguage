//
//  NSObject+Dictionary.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/22.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "NSObject+Dictionary.h"
#import "objc/runtime.h"

char associateDictKey;
@implementation NSObject (Dictionary)

- (id)sw_objectForKey:(id)aKey {
    NSDictionary* dict = objc_getAssociatedObject(self, &associateDictKey);
    return [dict objectForKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    return [self sw_objectForKey:key];
}

- (void)sw_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    NSMutableDictionary* dict = objc_getAssociatedObject(self, &associateDictKey);
    if (!dict){
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &associateDictKey, dict,
                OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [dict setObject:anObject forKey:aKey];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey {
    [self sw_setObject:object forKey:aKey];
}

@end
