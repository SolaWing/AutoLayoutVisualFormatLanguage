//
//  NSDictionary+SWAutoLayout.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SWAutoLayout)

/** return array of NSLayoutConstraint by analyze formatString.
 *  self is infos abount views and metrics.
 *  see `AutoLayoutFormatAnalyzer`*/
-(NSArray*)constraintsWithVisualFormat:(NSString*)formatString;

/** set all view element translatesAutoresizingMaskIntoConstraints property.
 * @return self
 */
- (instancetype)translatesAutoresizingMaskIntoConstraints:(BOOL)trans;

/** one shot for constraintsWithVisualFormat and activeConstrains.
 * @return constraints */
- (NSArray*)installConstraintsWithVisualFormat:(NSString*)formatString;

/** one shot for constraintsWithVisualFormat and activeConstrains.
 *  set translatesAutoresizingMaskIntoConstraints all views in self to NO
 * @return constraints  */
- (NSArray*)installFullConstraintsWithVisualFormat:(NSString*)formatString;

@end
