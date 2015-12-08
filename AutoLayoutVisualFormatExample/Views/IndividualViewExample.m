//
//  IndividualViewExample.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/8.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "IndividualViewExample.h"

@implementation IndividualViewExample

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView* lastView = self;
        CGFloat totalWidth = 0, totalHeight = 0;
        id margin = @(2);

        while (totalWidth < 320 && totalHeight < 320) {
            UIView* view = [UIView new];
            int randomColor =  arc4random()%0x1000000 ;
            view.backgroundColor = RGB(randomColor);
            view.layer.borderWidth = 1.0;
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [self addSubview:view];

            CGFloat width = arc4random()%20 + 10;
            CGFloat height = arc4random()%20 + 10;
            totalWidth += width; totalHeight += height;

            // put view in the inner of lastView
            //
            // speicify each margin, you can write fullname, or first char for simple. eg: Left => L
            // NSNumber also can used as param and ref it in predicate.
            // attr2 default equal to attr1, you may omit it if it's same.
            [view VFLFullInstall:@"Left>=$1+$4, Right<=$1-$4, Top>=$1+$4, Bottom<=$1-$4,"
                "Width=$1.Width-$2@999, Height=$1-$3@999, X@1, Y@1",
                lastView, @(width), @(height), margin];

            lastView = view;
        }

        // use x, y key to ref last view origin
        [lastView VFLInstall:@"x: X@999, y: Y@999"];
    }
    return self;
}

- (void)updateCenterFor:(CGPoint)p {
    [VFLConstraintForKey(@"x") setConstant:p.x];
    [VFLConstraintForKey(@"y") setConstant:p.y];
}

- (void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGPoint offsetCenter = [touches.anyObject locationInView:self];
    offsetCenter.x -= self.bounds.size.width/2;
    offsetCenter.y -= self.bounds.size.height/2;
    [self updateCenterFor:offsetCenter];
}

- (void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    CGPoint offsetCenter = [touches.anyObject locationInView:self];
    offsetCenter.x -= self.bounds.size.width/2;
    offsetCenter.y -= self.bounds.size.height/2;
    [self updateCenterFor:offsetCenter];
}

@end
