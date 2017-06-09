//
//  UIScrollView+SY.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "UIScrollView+SYRefresh.h"
#import "SYRefreshView.h"
#import <objc/runtime.h>

@implementation UIScrollView (SYRefresh)

const char SYRefreshHeaderKey = '\0';
const char SYRefreshFooterKey = '\0';
-(void)setSy_header:(SYRefreshView *)sy_header
{
    if (sy_header != self.sy_header) {
        [self insertSubview:sy_header atIndex:MAXFLOAT];
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
        [self insertSubview:sy_footer atIndex:MAXFLOAT];
        objc_setAssociatedObject(self, &SYRefreshFooterKey, sy_footer, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (SYRefreshView *)sy_footer
{
    return objc_getAssociatedObject(self, &SYRefreshFooterKey);
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.sy_header = nil;
    self.sy_footer = nil;
}

@end
