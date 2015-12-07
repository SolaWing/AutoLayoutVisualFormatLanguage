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
    UIView* containerView = [UIScrollView new];
    [self.view addSubview:containerView];
    [containerView VFLFullInstall:@"L,R, B,T=$1", self.topLayoutGuide];

    NSString* name = [_detailItem stringByReplacingOccurrencesOfString:@" " withString:@""];
    UIView* view = [NSClassFromString([name stringByAppendingString:@"Example"]) new];
    [containerView addSubview:view];
    // vertical center if possible, or top align.
    [view VFLFullInstall:@"L=$1,R=$1, Y@999, T>=0", self.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

@end
