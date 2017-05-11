//
//  SYGifTextHeader.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifHeader.h"

@interface SYGifTextHeader : SYGifHeader
/**
 初始化方法
 @param  data   图片数据
 @param  isBig  是否是大图
 @param  height 刷新控件高度
 @param  text   显示文字
 @return SYGifHeader
 */
+ (instancetype)textGifheaderWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height text:(NSString*)text callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;

@end
