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

+ (instancetype)textGifheaderWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock
{
    SYGifTextHeader *header = [[SYGifTextHeader alloc] init];
    header.isFooter = NO;
    header.hiddenArrow = YES;
    header.hiddenIndictorView = YES;
    header.sy_height = height;
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:height];
    header.beginBlock = finishRefreshBlock;
    return header;
}

+ (instancetype)textGifheaderWithData:(NSData*)data orientation:(SYRefreshViewOrientation)orientation isBig:(BOOL)isBig width:(CGFloat)width  callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock
{
    SYGifTextHeader *header = [[SYGifTextHeader alloc] init];
    header.orientation = orientation;
    BOOL isFooter = NO;
    if(orientation==SYRefreshViewOrientationBottom|| orientation==SYRefreshViewOrientationRight){
        isFooter = YES;
    }
    header.sy_height = width;
    header.isFooter = isFooter;
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:width];
    header.beginBlock = finishRefreshBlock;
    return header;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.hiddenArrow = YES;
        self.hiddenIndictorView = YES;
        self.titleL.font = [UIFont systemFontOfSize:12];
        self.titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.gifItem.imageView];
        [self.titleL bringSubviewToFront:self];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize imgSize = self.gifItem.imageView.image.size;
    self.gifItem.imageView.frame =CGRectMake(CGRectGetMinX(self.titleL.frame)-imgSize.width*0.5, 0, imgSize.width*0.5, imgSize.height*0.5);
    
    if ([self refreshOriIsLeftOrRight]) { //水平刷新的时候才需要调整位置和尺寸
        self.gifItem.imageView.centerY = self.centerY;
        self.gifItem.imageView.left = 0;
        self.titleL.width = self.width;
        self.titleL.height = SYVerticalOroTitleW;
        self.titleL.top = CGRectGetMaxY(self.gifItem.imageView.frame)+SYArrowRightMargin;
        self.titleL.centerX = self.gifItem.imageView.centerX;
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.gifItem = nil;
}


@end
