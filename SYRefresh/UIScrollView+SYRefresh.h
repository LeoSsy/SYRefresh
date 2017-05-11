//
//  UIScrollView+SY.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYRefreshView.h"
#import "SYGifHeader.h"

@interface UIScrollView (SYRefresh)
@property(nonatomic,strong)SYRefreshView *sy_header;
@property(nonatomic,strong)SYRefreshView *sy_footer;
@end
