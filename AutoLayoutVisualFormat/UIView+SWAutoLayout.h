//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  UIView+SWAutoLayout.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/24.
//  Copyright © 2015年 SW. All rights reserved.
//

#import <UIKit/UIKit.h>

/** category for add single view related constraints. @see `AutoLayoutFormatAnalyzer` */
@interface UIView (SWAutoLayout)

/** create constraint based on format, format is <predictList>.
 * index use array index, and self is $0
 * @warning index in format must not beyond provide args count!
 */
- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format, ...;

/** create constraint and active it, format is <predictList> */
- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format, ...;

/** disable self translatesAutoresizingMaskIntoConstraints, create constraint and active it
 *  Notice this only disable self autoresizing, not the view in var-list*/
- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format, ...;

#pragma mark - array version
- (NSArray<NSLayoutConstraint*>*)VFLConstraints:(NSString*)format withArgs:(NSArray*)args;
- (NSArray<NSLayoutConstraint*>*)VFLInstall:(NSString*)format withArgs:(NSArray*)args;
- (NSArray<NSLayoutConstraint*>*)VFLFullInstall:(NSString*)format withArgs:(NSArray*)args;

@end

@interface UILayoutGuide(SWAutoLayout)

- (UIView*)superview; /// compatible with view, to work with superview

@end
