//
//  SYGifTextHeader.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifTextHeader.h"

@interface SYGifTextHeader()
@property(nonatomic,strong)NSString *textG;
@property(nonatomic,strong)UILabel *textL;

@end

@implementation SYGifTextHeader

- (UILabel *)textL
{
    if (!_textL) {
        _textL = [[UILabel alloc] init];
        
    }
    return _textL;
}

/**
 初始化方法
 @param  data   图片数据
 @param  isBig  是否是大图
 @param  height 刷新控件高度
 @param  text   显示文字
 @return SYGifHeader
 */
+ (instancetype)textGifheaderWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height text:(NSString*)text callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock
{
    SYGifTextHeader *header = [[SYGifTextHeader alloc] init];
    header.isFooter = NO;
    header.hiddenArrow = YES;
    header.hiddenIndictorView = YES;
    header.sy_height = height;
    header.textG = text;
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:height];
    header.beginBlock = finishRefreshBlock;
    return header;
}

- (void)setTextG:(NSString *)textG
{
    _textG = textG;
    [self addSubview:self.gifItem.imageView];
    [self.titleL bringSubviewToFront:self];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize imgSize = self.gifItem.imageView.image.size;
    self.gifItem.imageView.frame =CGRectMake(CGRectGetMinX(self.titleL.frame)-imgSize.width*0.5, 0, imgSize.width*0.5, imgSize.height*0.5);
    
}


@end
