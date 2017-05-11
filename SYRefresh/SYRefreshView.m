//
//  SYRefreshView.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYRefreshView.h"
#import "SYSYRefreshConst.h"
#import <objc/runtime.h>

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

@implementation SYTitleItem
+ (instancetype)itemWithTitle:(NSString*)title color:(UIColor*)color
{
    SYTitleItem *item = [[SYTitleItem alloc] init];
    item.title = title;
    item.color = color;
    return item;
}
+ (instancetype)itemWithTitle:(NSString*)title hexColor:(long)hexColor
{
    SYTitleItem *item = [[SYTitleItem alloc] init];
    item.title = title;
    item.color = SYColorFromRGB(hexColor);
    return item;
}
@end

@interface SYRefreshView()
/***菊花控件*/
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;
/***箭头控件*/
@property(nonatomic,strong)UIImageView *arrowView;
/***添加到的scrollview*/
@property(nonatomic,strong)UIScrollView *scrollview;
/***控件当前的状态*/
@property(nonatomic ,assign) SYRefreshViewState state;
/***记录上一次控件的状态*/
@property(nonatomic ,assign) SYRefreshViewState lastState;
/***记录控件不同的状态的样式*/
@property(nonatomic ,strong) SYTitleItem *headerNormalItem;
@property(nonatomic ,strong) SYTitleItem *headerPullingItem;
@property(nonatomic ,strong) SYTitleItem *headerRefreshingItem;
@end

@implementation SYRefreshView

- (UILabel *)titleL
{
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.text = SYRefreshViewStateIdleTitle;
        _titleL.font = SYRefreshViewTitleFont;
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.hidden = NO;
        [self addSubview:_titleL];
    }
    return _titleL;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UIImageView *)arrowView
{
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.backgroundColor = [UIColor clearColor];
        NSString *imgSrc = [[NSBundle bundleForClass:[self class]] pathForResource:@"SYRefresh" ofType:@"bundle"];
        _arrowView.image = [UIImage imageWithContentsOfFile:[imgSrc stringByAppendingPathComponent:@"arrow@2x.png"]];
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

+ (SYRefreshView*)refreshWithHeight:(CGFloat)height isFooter:(BOOL)isFooter completionBlock:(SYRefreshViewbeginRefreshingCompletionBlock)completionBlock;
{
    SYRefreshView *view = [[SYRefreshView alloc] init];
    view.isFooter = isFooter;
    if (!view.isFooter) {
        view.beginBlock = completionBlock;
    }else{
        view.endBlock = completionBlock;
    }
    view.sy_height = height;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self prepare];
    }
    return self;
}

- (void)prepare
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
    self.state = SYRefreshViewStateIdle;
    self.alpha = 0.f;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    self.height = self.sy_height;
    self.left = 0;
    if (!self.isFooter) {
        self.top = -self.sy_height;
    }else{
        self.top = CGRectGetMaxY(newSuperview.frame);
    }
    self.width = newSuperview.width;
    self.scrollview = (UIScrollView*)newSuperview;
    self.scrollview.alwaysBounceVertical = YES;
    [self removeObservers];
    [self addObservers];
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    UIViewController *currentVc = [self currentViewController];
    if (currentVc.automaticallyAdjustsScrollViewInsets) {
        if ([currentVc.parentViewController isKindOfClass:[UINavigationController class]]) {
            UIEdgeInsets oldInsets = self.scrollview.contentInset;
            oldInsets.top = SYNavHeight;
            self.scrollview.contentInset = oldInsets;
        }
    }
}

- (void)setArrowRightInset:(CGFloat)arrowRightInset
{
    if (arrowRightInset>0) {
        [self setNeedsLayout];
    }
}
- (void)setHiddenArrow:(BOOL)hiddenArrow
{
    _hiddenArrow = hiddenArrow;
    if (hiddenArrow) {
        self.arrowView.hidden = YES;
    }else{
        self.arrowView.hidden = NO;
    }
}

- (void)setHiddenIndictorView:(BOOL)hiddenIndictorView
{
    _hiddenIndictorView = hiddenIndictorView;
    if (hiddenIndictorView) {
        self.indicatorView.hidden = YES;
    }else{
        self.indicatorView.hidden = NO;
    }
}

- (void)setSy_height:(CGFloat)sy_height
{
    if (sy_height>0) {
        _sy_height = sy_height;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleL.width = [self titleWidth];
    self.titleL.top = 0;
    self.titleL.left = (self.width-self.titleL.width)*0.5;
    self.titleL.height = self.height;
    
    self.arrowView.height = self.arrowView.image.size.height;
    self.arrowView.width = self.arrowView.image.size.width;
    self.arrowView.left = CGRectGetMinX(self.titleL.frame)-self.arrowView.width-(self.arrowRightInset>0?self.arrowRightInset:SYArrowRightMargin);
    self.arrowView.centerY = self.centerY;

    self.indicatorView.frame = self.arrowView.frame;
    self.indicatorView.centerY = self.centerY;
}

- (CGFloat)titleWidth
{
    if (self.titleL.text.length<=0) return 0;
    return [self.titleL.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleL.font} context:nil].size.width;
}

- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    [self.scrollview addObserver:self forKeyPath:SYKeyPathContentOffset options:options context:nil];
}

- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:SYKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (!self.userInteractionEnabled) return;
    if (self.hidden)  return;
    if ([keyPath isEqualToString:SYKeyPathContentOffset]) {
        [self scrollViewDidScrollChange];
    }
}

- (void)scrollViewDidScrollChange
{
        // 正在刷新状态
        if (self.state == SYRefreshViewRefreshing) return;
        // 当前的contentOffset
        CGFloat offsetY = self.scrollview.contentOffset.y;
        if (self.scrollview.isDragging) {
            self.alpha = 1.0;
            if (!self.isFooter) {
                // 头部控件特殊处理 如：有导航栏遮挡问题处理
                CGFloat justOffsetY = - self.scrollview.contentInset.top;
                CGFloat pullingOffsetY = justOffsetY - self.height;
                CGFloat dragingProgress = (justOffsetY - offsetY) / self.height;
                self.alpha = dragingProgress;
                if (self.state == SYRefreshViewStateIdle&&offsetY<pullingOffsetY) { //负数 往下拉
                    self.state = SYRefreshViewPulling;
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                    }];
                }else if (self.state == SYRefreshViewPulling&&offsetY>pullingOffsetY){//负数 往回弹
                    self.state = SYRefreshViewStateIdle;
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformIdentity;
                    }];
                }
            }else{
                if (self.state == SYRefreshViewStateIdle&&offsetY>self.height) { //正数 往上拉
                    self.state = SYRefreshViewPulling;
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                    }];
                }else if (self.state == SYRefreshViewPulling&&offsetY<self.height*0.82){//负数 往下弹
                    self.state = SYRefreshViewStateIdle;
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformIdentity;
                    }];
                }
            }
        }else if (self.state == SYRefreshViewPulling){
            [self beginRefreshing];
        }
}


- (void)setHeaderForState:(SYRefreshViewState)state item:(SYTitleItem*)item;
{
    if (state == SYRefreshViewStateIdle) {
        self.headerNormalItem = item;
        self.titleL.text = item.title;
        self.titleL.textColor = item.color;
    }else if (state == SYRefreshViewPulling){
        self.headerPullingItem = item;
    }else if (state == SYRefreshViewRefreshing){
        self.headerRefreshingItem = item;
    }
}

- (void)setState:(SYRefreshViewState)state
{
    if (state == self.lastState) return;
    _state = state;
    self.lastState = state;
    UIColor *normalColor = [UIColor blackColor];
    if (state == SYRefreshViewStateIdle) {
        self.titleL.text = self.headerNormalItem.title?self.headerNormalItem.title:SYRefreshViewStateIdleTitle;
        self.titleL.textColor = self.headerNormalItem.color?self.headerNormalItem.color:normalColor;
    }else if (state == SYRefreshViewPulling){
        self.titleL.text = self.headerPullingItem.title?self.headerPullingItem.title:SYRefreshViewPullingTitle;
        self.titleL.textColor = self.headerPullingItem.color?self.headerPullingItem.color:normalColor;
    }else if (state == SYRefreshViewRefreshing){
        self.titleL.text = self.headerRefreshingItem.title?self.headerRefreshingItem.title:SYRefreshViewRefreshingTitle;
        self.titleL.textColor = self.headerRefreshingItem.color?self.headerRefreshingItem.color:normalColor;
    }
    [self setNeedsLayout];
}

- (void)beginRefreshing
{
    if (self.state == SYRefreshViewStateIdle) {
        [UIView animateWithDuration:SYAnimationDuration+0.3 animations:^{
            self.alpha = 1.0;
        }];
    }
    self.state = SYRefreshViewRefreshing;
    [self.indicatorView startAnimating];
    self.arrowView.hidden = YES;
    if (!self.isFooter) { //头部刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentOffset = CGPointMake(0, - self.height-self.scrollview.contentInset.top);
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top+self.height, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            [self excuteBlock];
        }];
    }else{ //尾部刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom+self.height, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            [self excuteBlock];
        }];
    }
}

- (void)endRefreshing
{
    [self.indicatorView stopAnimating];
    if (!self.isFooter) { //头部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top-self.height, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            self.alpha  = 0.f;
            self.state = SYRefreshViewStateIdle;
            if (!self.isHiddenArrow) {
                self.arrowView.hidden = NO;
            }
        }];
    }else{ //尾部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom-self.height, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            self.alpha  = 0.f;
            self.state = SYRefreshViewStateIdle;
            if (!self.isHiddenArrow) {
                self.arrowView.hidden = NO;
            }
        }];
    }
}

- (void)excuteBlock{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.beginBlock) {
            self.beginBlock();
        }
        if (self.endBlock) {
            self.endBlock();
        }
    });
}


/**
 获取当前视图所属的控制器
 @return  当前视图所属的控制器
 */
-(UIViewController *)currentViewController{
    UIViewController *vc;
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[objc_getClass("UIViewController") class]] ) {
            vc=(UIViewController*)nextResponder;
            return vc;
        }
    }
    return vc;
}
@end

@implementation UIView(SY)

- (CGFloat)top{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top{
    CGRect frame = self.frame;
    frame.origin.y = top;
    [self setFrame:frame];
}

- (CGFloat)left{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left{
    CGRect frame = self.frame;
    frame.origin.x = left;
    [self setFrame:frame];
}

- (CGFloat)right{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    [self setFrame:frame];
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    [self setFrame:frame];
}

- (CGPoint)center{
    return CGPointMake(self.left+self.width/2.0, self.top+self.height/2.0);
}

- (void)setCenter:(CGPoint)center{
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width/2.0;
    frame.origin.y = center.y - frame.size.height/2.0;
    [self setFrame:frame];
}

- (CGFloat)centerX
{
    return self.frame.size.width*0.5;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.frame.size.height*0.5;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    return [self setFrame:frame];
}

- (CGSize)size
{
    return  self.frame.size;
}

@end
