//
//  BasicFlowLayoutExample.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/7.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "BasicFlowLayoutExample.h"

@implementation BasicFlowLayoutExample

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NamedViewWithColor(leftView, 00FF00);
        NamedViewWithColor(centerView, FF0000);
        NamedViewWithColor(rightView, 00FF00);
        [self addSubview:leftView];
        [self addSubview:centerView];
        [self addSubview:rightView];

        UIButton* minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [minusButton setTitle:@"-" forState:UIControlStateNormal];
        [minusButton setTitleColor:RGBHEX(0000FF) forState:UIControlStateNormal];
        [minusButton setBackgroundColor:[UIColor whiteColor]];
        [minusButton addTarget:self action:@selector(clickMinusButton) forControlEvents:UIControlEventTouchUpInside];
        [leftView addSubview:minusButton];

        UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [plusButton setTitle:@"+" forState:UIControlStateNormal];
        [plusButton setTitleColor:RGBHEX(0000FF) forState:UIControlStateNormal];
        [plusButton setBackgroundColor:[UIColor whiteColor]];
        [plusButton addTarget:self action:@selector(clickPlusButton) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:plusButton];

        // create flow layout from left to right. all equal width, equal height, equal centerY
        // save space in global weak table to ref later
        VFLFullInstallWithEnv(@"|-(space0:0)-[leftView]-(space1:0)-[centerView]-(space2:0)-[rightView]-(space3:0)-| WHY;"
                @"V:|-[centerView]-|;", leftView, rightView, centerView);

        // pos button at superview center
        [minusButton VFLFullInstall:@"X,Y"];
        [plusButton VFLFullInstall:@"X,Y"];
    }
    return self;
}

- (void)clickMinusButton {
    // add space to minus width
    NSInteger space = VFLConstraintForKey(@"space0").constant;
    if (space > 60) return;
    space += 10;
    for (int i = 0; i < 4; ++i) {
        VFLConstraintForKey([NSString stringWithFormat:@"space%d", i]).constant = space;
    }

    [UIView animateWithDuration:0.25 animations:^(void){
        [self layoutIfNeeded];
    }];
}

- (void)clickPlusButton {
    // minus space to add width
    NSInteger space = VFLConstraintForKey(@"space0").constant;
    if (space == 0) return;
    space -= 10;
    if (space < 0) space = 0;
    for (int i = 0; i < 4; ++i) {
        VFLConstraintForKey([NSString stringWithFormat:@"space%d", i]).constant = space;
    }

    [UIView animateWithDuration:0.25 animations:^(void){
        [self layoutIfNeeded];
    }];
}

@end
