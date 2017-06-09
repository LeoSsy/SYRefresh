//
//  UIScrollView+SY.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import <UIKit/UIKit.h>
#import "SYRefreshView.h"
#import "SYGifHeaderFooter.h"

@interface UIScrollView (SYRefresh)
@property(nonatomic,strong)SYRefreshView *sy_header;
@property(nonatomic,strong)SYRefreshView *sy_footer;
@end
