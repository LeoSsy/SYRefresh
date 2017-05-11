//
//  UIScrollView+SY.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "UIScrollView+SYRefresh.h"
#import "SYRefreshView.h"
#import <objc/runtime.h>

@implementation UIScrollView (SYRefresh)

static const char SYRefreshHeaderKey = '\0';
static const char SYRefreshFooterKey = '\0';

-(void)setSy_header:(SYRefreshView *)sy_header
{
    if (sy_header != self.sy_header) {
        [self.sy_header removeFromSuperview];
        [self insertSubview:sy_header atIndex:0];
        objc_setAssociatedObject(self, &SYRefreshHeaderKey, sy_header, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (SYRefreshView*)sy_header
{
    SYRefreshView *header = objc_getAssociatedObject(self, &SYRefreshHeaderKey);
    return header;
}

-(void)setSy_footer:(SYRefreshView *)sy_footer
{
    if (sy_footer != self.sy_footer) {
        [self.sy_footer removeFromSuperview];
        [self insertSubview:sy_footer atIndex:0];
        objc_setAssociatedObject(self, &SYRefreshFooterKey, sy_footer, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (SYRefreshView *)sy_footer
{
    return objc_getAssociatedObject(self, &SYRefreshFooterKey);
}

@end
