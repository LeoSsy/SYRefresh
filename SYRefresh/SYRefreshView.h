//
//  SYRefreshView.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**拖拽控件的状态 */
typedef NS_ENUM(NSInteger, SYRefreshViewState) {
    /** 普通闲置状态 */
    SYRefreshViewStateIdle = 1,
    /** 松开就可以进行进行切换的状态 */
    SYRefreshViewPulling,
    /** 正在刷新的状态 */
    SYRefreshViewRefreshing
};
/** 松开切换的回调*/
typedef void (^SYRefreshViewbeginRefreshingCompletionBlock)();

/** 保存每一种状态的相关样式对象*/
@interface SYTitleItem : NSObject
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)UIColor *color;
+ (instancetype)itemWithTitle:(NSString*)title color:(UIColor*)color;
+ (instancetype)itemWithTitle:(NSString*)title hexColor:(long)hexColor;
@end

@interface SYRefreshView : UIView
/**
*  创建刷新控件
*  @param height  刷新控件高度
*  @param isFooter 是否添加到scrollview的尾部
*  @param completionBlock 开始刷新之后的回调
*/
+ (SYRefreshView*)refreshWithHeight:(CGFloat)height isFooter:(BOOL)isFooter completionBlock:(SYRefreshViewbeginRefreshingCompletionBlock)completionBlock;
/**
 *  置控件不同的状态对应的提示文字
 *  @param state  刷新控件状态 对应 SYRefreshViewState
 *  @param item   SYTitleItem对象 保存每一种状态的相关样式
 */
- (void)setHeaderForState:(SYRefreshViewState)state item:(SYTitleItem*)item;
/**开始刷新*/
- (void)beginRefreshing;
/**结束刷新*/
- (void)endRefreshing;
/***标题控件*/
@property(nonatomic,strong)UILabel *titleL;
/***是否添加到底部*/
@property(nonatomic ,assign) BOOL isFooter;
/***箭头和圆圈右边距离标题的间距*/
@property(nonatomic ,assign) CGFloat arrowRightInset;
/***设置控件的高度*/
@property(nonatomic ,assign) CGFloat sy_height;
/***是否隐藏箭头*/
@property(nonatomic ,assign,getter=isHiddenArrow) BOOL hiddenArrow;
/***是否隐藏菊花*/
@property(nonatomic ,assign,getter=isHiddenIndictorView) BOOL hiddenIndictorView;
/***设置头部刷新状态的回调*/
@property(nonatomic ,copy) SYRefreshViewbeginRefreshingCompletionBlock beginBlock;
/***设置尾部刷新状态的回调*/
@property(nonatomic ,copy) SYRefreshViewbeginRefreshingCompletionBlock endBlock;
/**初始化方法*/
- (void)prepare;
/**监听偏移量*/
- (void)scrollViewDidScrollChange;
@end

