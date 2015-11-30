//
//  NSDictionary+SWAutoLayout.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSLayoutConstraint;

#define VFLConstraintsWithEnv(format, ...) [NSDictionaryOfVariableBindings(__VA_ARGS__) VFLConstraints:format]
#define VFLInstallWithEnv(format, ...) [NSDictionaryOfVariableBindings(__VA_ARGS__) VFLInstall:format]
#define VFLFullInstallWithEnv(format, ...) [NSDictionaryOfVariableBindings(__VA_ARGS__) VFLFullInstall:format]

/** Convenience category for use VFL, @see `AutoLayoutFormatAnalyzer.h` */
@interface NSDictionary (SWAutoLayout)

/** set all view element translatesAutoresizingMaskIntoConstraints property.
 * @return self
 */
- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans;

- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format;
- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format;
- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format;

@end
