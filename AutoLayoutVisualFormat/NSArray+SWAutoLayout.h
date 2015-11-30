//
//  NSArray+SWAutoLayout.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VFLConstraintsWithParams(format, ...) [@[ __VA_ARGS__ ] VFLConstraints:format]
#define VFLInstallWithParams(format, ...) [@[__VA_ARGS__] VFLInstall:format]
#define VFLFullInstallWithParams(format, ...) [@[__VA_ARGS__] VFLFullInstall:format]

/** Convenience category for use VFL, @see `AutoLayoutFormatAnalyzer.h` */
@interface NSArray (SWAutoLayout)

/** set all view element translatesAutoresizingMaskIntoConstraints property.
 * @return self
 */
- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans;

/** return array of NSLayoutConstraint by align all views in self */
- (NSArray<NSLayoutConstraint*>*)constraintsAlignAllViews:(NSLayoutAttribute)attr;

- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format;
- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format;
- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format;

/** active array of NSLayoutConstraint */
- (void)activateConstraints;
- (void)deactivateConstraints;

@end
