//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  SwitchLayoutExample.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/8.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "SwitchLayoutExample.h"

@implementation SwitchLayoutExample{
    NSArray* _views;
    NSArray* _constraints;
    int _phase;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];

        NamedViewWithColor(yellowView, CCCC00);
        NamedViewWithColor(blueView, 0000FF);
        NamedViewWithColor(redView, FF0000);
        NamedViewWithColor(whiteView, FFFFFF);
        NamedViewWithColor(blackView, 000000);

        _views = @[yellowView, blueView, redView, whiteView, blackView];
        for (UIView* view in _views){
            [self addSubview:view];
        }
        [_views translatesAutoresizingMaskIntoConstraints:NO];

        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitle:@"Touch Me" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(touchButton) forControlEvents:UIControlEventTouchUpInside];
        [yellowView addSubview:button];
        [button VFLFullInstall:@"X,Y"]; // center button in superview

        [self applyLayout];
    }
    return self;
}

- (void)applyLayout {
    [_constraints deactivateConstraints]; // remove previous constraints

    // yellowView at center, other views rotate according to _phase
    // rearrange views so 0:Yellow 1:rightView 2:bottomView 3:leftView 4:topView
    NSMutableArray* views = [NSMutableArray arrayWithObject:_views[0]];
    _phase %= 8;
    for (int i = _phase/2; i < 4; ++i) {
        [views addObject:_views[i+1]];
    }
    for (int i = 0; i < _phase/2; ++i) {
        [views addObject:_views[i+1]];
    }

    /// hold created constraints for later deactive
    if ( (_phase & 1) == 0 ) {
        _constraints = [views VFLInstall:
            @"|-[$3]-[$0(X,Y)]-[$1]-| WHY;"
            @"V:|-[$4]-[$0]-[$2]-| WHX;"
        ];
    } else {
        _constraints = [views VFLInstall:
            @"|-[$3(Y=$2)]-20-[$0(X,Y)]-20-[$1(Y=$4)]-| WH;"
            @"V:|-[$4(X=$3)]-20-[$0]-20-[$2(X=$1)]-| WH;"
        ];
    }
}

- (void)touchButton {
    ++_phase;
    [self applyLayout];

    [UIView animateWithDuration:0.25 animations:^(void){
        [self layoutIfNeeded];
    }];
}

@end
