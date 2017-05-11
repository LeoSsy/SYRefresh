//
//  FistViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/6.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "FistViewController.h"

@interface FistViewController ()
@property(nonatomic,strong)UIView *titleView;
@end

@implementation FistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
    self.navigationItem.titleView = self.titleView;
}




@end
