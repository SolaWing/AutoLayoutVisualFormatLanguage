//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  NSLayoutConstraint+SWAutoLayout.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/26.
//  Copyright © 2015年 SW. All rights reserved.
//

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (SWAutoLayout)

@property(getter=isActive) BOOL active;

+ (void)activateConstraints:(NSArray<NSLayoutConstraint *> * _Nonnull)constraints;
+ (void)deactivateConstraints:(NSArray<NSLayoutConstraint *> * _Nonnull)constraints;

@end

#endif
