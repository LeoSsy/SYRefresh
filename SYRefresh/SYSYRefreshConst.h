//
//  SYConst.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#ifndef SYConst_h
#define SYConst_h

// 标题的文字大小
#define SYRefreshViewTitleFontSize 14
#define SYRefreshViewTitleFont [UIFont systemFontOfSize:SYRefreshViewTitleFontSize]

// rgb颜色转换（16进制->10进制）
#define SYColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString *const SYKeyPathContentOffset = @"contentOffset";
static NSString *const SYKeyPathContentSize = @"contentSize";

static NSString *const SYRefreshViewStateIdleTitle =  @"下拉加载最新数据";
static NSString *const SYRefreshViewPullingTitle =    @"释放回到商品详情";
static NSString *const SYRefreshViewRefreshingTitle = @"正在刷新中...";

static const CGFloat SYHeaderHeight = 54.0; //头部控件默认高度
static const CGFloat SYFooterHeight = 44.0; //尾部控件默认高度
static const CGFloat SYAnimationDuration = 0.25;//动画时间
static const CGFloat SYArrowRightMargin = 8;//箭头与标题之间的间距
static const CGFloat SYVerticalOroTitleW = SYRefreshViewTitleFontSize;//左右刷新状态下 标题的宽度 最好和字体一样的大小
static const CGFloat SYNavHeight = 64;//导航栏的高度

#endif /* SYConst_h */
