//
//  DetailViewController.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "DetailViewController.h"
#import <objc/runtime.h>
#import "../AutoLayoutVisualFormat/NSArray+SWAutoLayout.h"
#import "../AutoLayoutVisualFormat/NSDictionary+SWAutoLayout.h"

#define RGB(num) [UIColor colorWithRed:((num>>16)&0xff)/255.0 green:((num>>8)&0xff)/255.0 blue:(num&0xff)/255.0 alpha:1];
#define RGBHEX(hex) RGB(0x##hex)

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        self.navigationItem.title = _detailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    NSString* name = [_detailItem stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    SEL sel = sel_getUid(name.UTF8String);
    IMP imp = [[self class] instanceMethodForSelector:sel];
    if (imp){
        ((void(*)(id,SEL))imp)(self, sel);
    }
}

#define NamedViewWithColor(name, color)                             \
    UIView* name = [UIView new];                                    \
    name.layer.borderWidth = 1.0;                                   \
    name.layer.borderColor = [UIColor lightGrayColor].CGColor;      \
    name.backgroundColor = RGBHEX(color);                           \

#define LabelWithName_Title_Color(name,title,color)                 \
    UILabel* name = [UILabel new];                                  \
    name.text = title;                                              \
    name.textColor = RGBHEX(color);                                 \
    name.textAlignment = NSTextAlignmentCenter;                     \
    ShowBorder(name)                                                \

#define ShowBorder(name)                                            \
    name.layer.borderWidth = 1;                                     \
    name.layer.borderColor = [UIColor lightGrayColor].CGColor;      \

//#define ShowBorder(...)

- (void)System_Visual_Layout {
    UIScrollView* sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:sv];

    VFLFullInstallWithParams(@"|[0]|; V:[1][0]|", sv, self.topLayoutGuide);

    LabelWithName_Title_Color(l1, @"System Visual Layout", 0);
    [sv addSubview:l1];

    UIView* v1 = [UIView new];
    ShowBorder(v1);

    [sv addSubview:v1];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 5;
    [btn setBackgroundColor:[UIColor blueColor]];
    // [btn setTitle:@"button" forState:UIControlStateNormal];
    UITextField* tf = [UITextField new];
    tf.borderStyle = UITextBorderStyleBezel;
    [v1 addSubview:btn];
    [v1 addSubview:tf];

    // Standard Space
    [NSDictionaryOfVariableBindings(btn,tf) VFLFullInstall:@"[btn]-[tf]"];
    // Width Constraint
    [NSDictionaryOfVariableBindings(btn) VFLInstall:@"[btn(>=100)]"];
    // Connection to SuperView, vertically
    [NSDictionaryOfVariableBindings(btn) VFLInstall:@"V:|-10-[btn]-10-|"];
    // add lack constraint
    [@[v1,l1,btn,tf] VFLFullInstall:@"V:|[1(X|)]-[0] X; H:|-[2(Y$3)];[3(>=100)]-|"];

    UIView *v2 = [UIView new];
    ShowBorder(v2);
    [sv addSubview:v2];

    NamedViewWithColor(greenView, 00FF00);
    NamedViewWithColor(blueView, 0000FF);
    [v2 addSubview:greenView];
    [v2 addSubview:blueView];
    // FlushView
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLFullInstall:@"[greenView][blueView]"];
    // EqualWidth And Priority
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLInstall:@"[greenView(==blueView@20)]"];
    // Multiplier Predicates And With different Priority
    [NSDictionaryOfVariableBindings(greenView,blueView) VFLFullInstall:@"[greenView(>=70,<=100@999,>=120@30)]"];
    // add lack constraint
    [@[v1,v2,greenView,blueView] VFLFullInstall:@"V:[0]-[1] X; |[2(30,==$3,T$3)]|; H:|[2]; [3]|"];

    // a complete Line
    LabelWithName_Title_Color(l2, @"Complete Line", 0);
    UIView* v3 = [UIView new];
    ShowBorder(v3);
    [sv addSubview:l2];
    [sv addSubview:v3];

    UIButton* b1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b1 setTitle:@"Find" forState:UIControlStateNormal];
    UIButton* b2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [b2 setTitle:@"Find Next" forState:UIControlStateNormal];
    UITextField *t1 = [UITextField new];
    t1.borderStyle = UITextBorderStyleBezel;
    [v3 addSubview:b1];
    [v3 addSubview:b2];
    [v3 addSubview:t1];
    // full line
    [NSDictionaryOfVariableBindings(b1,b2,t1) VFLFullInstall:
        @"|-[b1]-[b2]-[t1(>=50)]-| b"];
    [@[v2, l2, v3, b1,b2,t1] VFLFullInstall:
        @"V:[0]-[1]-[2] X; H:|-[3]; [5]-|; V:|-[3]-|"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
