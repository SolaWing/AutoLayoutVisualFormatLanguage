//
//  SystemVisualLayoutExample.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/12/7.
//  Copyright © 2015年 SW. All rights reserved.
//

#import "SystemVisualLayoutExample.h"

@implementation SystemVisualLayoutExample

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:scrollView];

        UIView* containerView = [UIView new];
        [scrollView addSubview:containerView];
        // if content View not fill Height, center it.
        [containerView VFLFullInstall:@"L,R, W=|,Y@500, T>=0, B", self];

        LabelWithName_Title_Color(titleLabel, @"System Visual Layout\nPlease see code", 0);
        [containerView addSubview:titleLabel];

        /** First View */
        UIView* v1 = [self firstExampleView];
        ShowBorder(v1);
        [containerView addSubview:v1];
        // add lack constraint:
        [@[titleLabel,v1] VFLFullInstall:@"V:|-[0(X)]-[1] X;"];


        /** Second View */
        UIView *v2 = [self secondExampleView];
        ShowBorder(v2);
        [containerView addSubview:v2];
        // add lack constraint
        [@[v1,v2] VFLFullInstall:@"V:[0]-[1] X;"];


        /** third complete Line View */
        LabelWithName_Title_Color(completeLineLabel, @"Complete Line", 0);
        UIView* v3 = [self completeLineView];
        ShowBorder(v3);
        [containerView addSubview:completeLineLabel];
        [containerView addSubview:v3];
        // add lack constraints for containters
        [@[v2, completeLineLabel, v3] VFLFullInstall: @"V:[0]-20-[1]-[2]-| X;"];
    }
    return self;
}

- (UIView*)firstExampleView {
    UIView* view = [UIView new];

    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 5;
    [button setBackgroundColor:[UIColor blueColor]];

    UITextField* textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleBezel;
    [view addSubview:button];
    [view addSubview:textField];

    /// Standard Space
    [NSDictionaryOfVariableBindings(button,textField) VFLFullInstall:@"[button]-[textField]"];
    /// Width Constraint
    [NSDictionaryOfVariableBindings(button) VFLInstall:@"[button(>=100)]"];
    /// Connection to SuperView, vertically
    [NSDictionaryOfVariableBindings(button) VFLInstall:@"V:|-10-[button]-10-|"];

    // add lack constraint
    [@[button, textField] VFLInstall:@"|-[$0]; [$1 (>=100, Y=$0)]-|"];

    return view;
}

- (UIView*)secondExampleView {
    UIView* view = [UIView new];
    NamedViewWithColor(greenView, 00FF00);
    NamedViewWithColor(blueView, 0000FF);
    [view addSubview:greenView];
    [view addSubview:blueView];

    /// FlushView
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLFullInstall:@"[greenView][blueView]"];
    /// EqualWidth And Priority set to 20
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLInstall:@"[greenView(==blueView@20)]"];
    /// Multiplier Predicates And With different Priority
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLFullInstall:@"[greenView(>=70,<=100@999,>=120@30)]"];

    // add lack constraint
    [@[greenView, blueView] VFLInstall:@"H:|[0]; [1]|; V:|[0(30, ==$1, Top=$1)]|;"];

    return view;
}

- (UIView*)completeLineView {
    UIView* view = [UIView new];
    UIButton* find = [UIButton buttonWithType:UIButtonTypeSystem];
    [find setTitle:@"Find" forState:UIControlStateNormal];
    UIButton* findNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [findNext setTitle:@"Find Next" forState:UIControlStateNormal];
    UITextField* textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleBezel;
    [view addSubview:find];
    [view addSubview:findNext];
    [view addSubview:textField];

    /// a complete Line
    [NSDictionaryOfVariableBindings(find,findNext,textField) VFLFullInstall:
        @"|-[find]-[findNext]-[textField(>=50)]-| b; V:|-[find]-|"];

    return view;
}

@end

