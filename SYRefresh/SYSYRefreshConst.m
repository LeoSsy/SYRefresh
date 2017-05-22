//
//  SYSYRefreshConst.m
//  SYRefreshExample
//
//  Created by shusy on 2017/5/22.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const SYKeyPathContentOffset = @"contentOffset";
NSString *const SYKeyPathContentSize = @"contentSize";

NSString *const SYRefreshViewStateIdleTitle =  @"下拉加载最新数据";
NSString *const SYRefreshViewPullingTitle =    @"释放回到商品详情";
NSString *const SYRefreshViewRefreshingTitle = @"正在刷新中...";
NSString *const SYRefreshViewNoMoreDataTitle = @"没有更多数据了";

 const CGFloat SYHeaderHeight = 54.0; //头部控件默认高度
 const CGFloat SYFooterHeight = 44.0; //尾部控件默认高度
 const CGFloat SYAnimationDuration = 0.25;//动画时间
 const CGFloat SYArrowRightMargin = 8;//箭头与标题之间的间距
 const CGFloat SYVerticalOroTitleW = 14;//左右刷新状态下 标题的宽度 最好和字体一样的大小
 const CGFloat SYNavHeight = 64;//导航栏的高度
 const CGFloat autoRefreshProgress = 0.8;//自动刷新的拖拽比例
