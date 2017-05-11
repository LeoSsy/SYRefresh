//
//  SecondViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/6.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"商品评论页面";
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"contentoffset ======%@",NSStringFromCGRect(self.view.frame));

}

@end
