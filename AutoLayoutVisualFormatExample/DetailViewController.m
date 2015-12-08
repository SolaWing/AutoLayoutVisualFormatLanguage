//
//  DetailViewController.m
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import "DetailViewController.h"
#import <objc/runtime.h>


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
    NSString* name = [_detailItem stringByReplacingOccurrencesOfString:@" " withString:@""];
    UIView* view = [NSClassFromString([name stringByAppendingString:@"Example"]) new];
    [self.view addSubview:view];
    [view VFLFullInstall:@"Left,Right, Bottom,Top=$1.Bottom", self.topLayoutGuide];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

@end
