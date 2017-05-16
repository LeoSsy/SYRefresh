//
//  SYGifTextHeader.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "SYGifHeader.h"

@interface SYGifTextHeader : SYGifHeader
/**
 初始化方法
 @param  data   图片数据
 @param  isBig 是否是大图 如果是小图片的话 建议设置此参数为NO
 @param  height 刷新控件高度
 @return SYGifTextHeader
 */
+ (instancetype)textGifheaderWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;

/**
 初始化方法
 @param  data 图片数据
 @param  orientation 刷新控件的方向
 @param  isBig 是否是大图 如果是小图片的话 建议设置此参数为NO
 @param  width 刷新控件宽度
 @return SYGifTextHeader
 */
+ (instancetype)textGifheaderWithData:(NSData*)data orientation:(SYRefreshViewOrientation)orientation isBig:(BOOL)isBig width:(CGFloat)width callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;


@end
