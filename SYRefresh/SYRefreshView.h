//
//  SYRefreshView.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import <UIKit/UIKit.h>

/**刷新控件的状态 */
typedef NS_ENUM(NSInteger, SYRefreshViewState) {
    /** 普通闲置状态 */
    SYRefreshViewStateIdle = 1,
    /** 松开就可以进行进行切换的状态 */
    SYRefreshViewPulling,
    /** 正在刷新的状态 */
    SYRefreshViewRefreshing
};

/**刷新控件的方向 可以为指定的方向添加刷新控件*/
typedef NS_ENUM(NSInteger, SYRefreshViewOrientation) {
    /** 顶部 */
    SYRefreshViewOrientationTop = 1,
    /** 底部 */
    SYRefreshViewOrientationBottom,
    /** 左边 */
    SYRefreshViewOrientationLeft,
    /** 右边 */
    SYRefreshViewOrientationRight
};

/** 松开切换的回调*/
typedef void (^SYRefreshViewbeginRefreshingCompletionBlock)();

/** 保存每一种状态的相关样式对象*/
@interface SYTitleItem : NSObject
@property(nonatomic,copy)NSString *title; //提示标题
@property(nonatomic,copy)UIColor *color; //标题颜色
@property(nonatomic,copy)UIFont *font; //标题字体
@property(nonatomic,copy)UIImage *image;//刷新状态对应的图片
+ (instancetype)itemWithTitle:(NSString*)title color:(UIColor*)color font:(CGFloat)fontSize imageName:(NSString*)imageName;
+ (instancetype)itemWithTitle:(NSString*)title hexColor:(long)hexColor font:(CGFloat)fontSize imageName:(NSString*)imageName;
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
 *  创建刷新控件
 *  @param orientation 为指定的方向添加刷新控件
 *  @param width       刷新控件宽度
 *  @param completionBlock 开始刷新之后的回调
 */
+ (SYRefreshView*)refreshWithOrientation:(SYRefreshViewOrientation)orientation width:(CGFloat)width completionBlock:(SYRefreshViewbeginRefreshingCompletionBlock)completionBlock;

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
/***记录用户设置刷新控件的方向*/
@property(nonatomic ,assign) SYRefreshViewOrientation orientation;
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
/**是否需要隐藏全部子控件*/
@property(nonatomic ,assign,getter=isHideAllSubviews) BOOL hideAllSubviews;
/**是否需要旋转箭头*/
@property(nonatomic ,assign,getter=isArrowRotation) BOOL arrowRotation;
/***设置头部刷新状态的回调*/
@property(nonatomic ,copy) SYRefreshViewbeginRefreshingCompletionBlock beginBlock;
/***设置尾部刷新状态的回调*/
@property(nonatomic ,copy) SYRefreshViewbeginRefreshingCompletionBlock endBlock;
/**初始化方法*/
- (void)prepare;
/**监听偏移量*/
- (void)scrollViewDidScrollChange;
/**判断当前的控件方向是否是左右刷新 是返回yes 否返回no*/
- (BOOL)refreshOriIsLeftOrRight;
@end

@interface UIView(SY)
@property(nonatomic ,assign) CGFloat left;
@property(nonatomic ,assign) CGFloat top;
@property(nonatomic ,assign) CGFloat width;
@property(nonatomic ,assign) CGFloat height;
@property(nonatomic ,assign,readonly) CGFloat right;
@property(nonatomic ,assign,readonly) CGFloat bottom;
@property(nonatomic ,assign) CGPoint center;
@property(nonatomic ,assign) CGFloat centerX;
@property(nonatomic ,assign) CGFloat centerY;
@property(nonatomic ,assign) CGSize size;
@end

