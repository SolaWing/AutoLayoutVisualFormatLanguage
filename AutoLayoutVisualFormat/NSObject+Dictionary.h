//
//  NSObject+Dictionary.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/22.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Dictionary)

- (id)sw_objectForKey:(id)aKey;
/** this method is not thread-safe */
- (void)sw_setObject:(id)anObject forKey:(id<NSCopying>)aKey;

/** function for [] syntax sugar. you may prefer use your self imp */
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)aKey;

@end
