//
//  SYGifHeader.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "SYRefreshView.h"

@interface SYGifHeaderFooter : SYRefreshView
/**是否是加在的本地的gif图片*/
- (BOOL)isLoadedGif;
/**返回当前显示的gif视图控件*/
- (UIImageView*)getGifView;
/**获取图片的尺寸*/
- (CGSize)imageSize;
/**动画图片距离底部的间距*/
@property(nonatomic,assign)CGFloat animtaionImageBottomMargin;

/**
 *  创建刷新控件 这样创建出来的刷新控件后 需要设置对应状态的图片数组 参考方法：- (void)setImages:(NSArray *)images forState:(SYRefreshViewState)state;
 @param  height 刷新控件高度
 @param  orientation 刷新控件的方向
 @return SYGifHeader
 */
+ (instancetype)headerWithHeight:(CGFloat)height orientation:(SYRefreshViewOrientation)orientation  callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;

/**
 *  创建刷新控件
 @param  data 图片数据 直接加在本地的gif图片
 @param  orientation 刷新控件的方向
 @param  isBig 是否是大图 如果是小图片的话 建议设置此参数为NO
 @param  height 如果是水平刷新就表示刷新控件宽度 垂直刷新就表示刷新控件的高度
 @return SYGifHeader
 */
+ (instancetype)headerWithData:(NSData*)data orientation:(SYRefreshViewOrientation)orientation isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;

/** 设置对应刷新状态下的动画图片数组和动画持续时间*/
- (void)setImages:(NSArray *)images duration:(double)duration forState:(SYRefreshViewState)state;
- (void)setImages:(NSArray *)images forState:(SYRefreshViewState)state;

@end
