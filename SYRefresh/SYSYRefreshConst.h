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

UIKIT_EXTERN NSString *const SYKeyPathContentOffset;
UIKIT_EXTERN NSString *const SYKeyPathContentSize;

UIKIT_EXTERN NSString *const SYRefreshViewStateIdleTitle;
UIKIT_EXTERN NSString *const SYRefreshViewPullingTitle;
UIKIT_EXTERN NSString *const SYRefreshViewRefreshingTitle;
UIKIT_EXTERN NSString *const SYRefreshViewNoMoreDataTitle;

UIKIT_EXTERN const CGFloat SYHeaderHeight; //头部控件默认高度
UIKIT_EXTERN const CGFloat SYFooterHeight; //尾部控件默认高度
UIKIT_EXTERN const CGFloat SYAnimationDuration;//动画时间
UIKIT_EXTERN const CGFloat SYArrowRightMargin;//箭头与标题之间的间距
UIKIT_EXTERN const CGFloat SYVerticalOroTitleW;//左右刷新状态下 标题的宽度 最好和字体一样的大小
UIKIT_EXTERN const CGFloat SYNavHeight;//导航栏的高度
UIKIT_EXTERN const CGFloat autoRefreshProgress;//自动刷新的拖拽比例

//去除collectionview的隐式动画
#define PerformWithoutAnimation(code)\
[UIView performWithoutAnimation:^{\
code\
}];

#endif /* SYConst_h */
