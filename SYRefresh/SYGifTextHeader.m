//
//  SYGifTextHeader.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "SYGifTextHeader.h"
#import "SYSYRefreshConst.h"
@interface SYGifTextHeader()
@property(nonatomic,strong)NSString *textG;
@end

@implementation SYGifTextHeader

- (void)prepare
{
    [super prepare];
    self.titleL.font = [UIFont systemFontOfSize:12];
    self.titleL.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.gifItem.imageView];
    [self.titleL bringSubviewToFront:self];
}

- (void)setHideAllSubviews:(BOOL)hideAllSubviews
{
    [super setHideAllSubviews:hideAllSubviews];
    self.titleL.hidden = NO; //显示标题
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *gifView = [self getGifView];
    CGSize imgSize = [self imageSize];
    gifView.frame =CGRectMake(CGRectGetMinX(self.titleL.frame)-imgSize.width*0.5, 0, imgSize.width*0.5, imgSize.height*0.5);
    if ([self refreshOriIsLeftOrRight]) { //水平刷新的时候才需要调整位置和尺寸
        gifView.centerY = self.centerY;
        gifView.left = 0;
        PerformWithoutAnimation(self.titleL.width = self.width;
                                self.titleL.height = SYVerticalOroTitleW;
                                self.titleL.top = CGRectGetMaxY(gifView.frame)+SYArrowRightMargin;
                                self.titleL.centerX = gifView.centerX;)
    }    
}

- (UIImageView*)getGifView
{
    if (self.isLoadedGif) {
        return self.gifItem.imageView;
    }else{
        return self.gifImageView;
    }
}

@end
