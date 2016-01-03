//  Gihhub: https://github.com/SolaWing/AutoLayoutVisualFormatLanguage
//
//  DetailViewController.h
//  AutoLayoutVisualFormat
//
//  Created by SolaWing on 15/9/19.
//  Copyright (c) 2015年 SW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

