//
//  SYRefreshView.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/8.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "SYRefreshView.h"
#import <objc/runtime.h>
#import "SYSYRefreshConst.h"
#import "UIScrollView+SYRefresh.h"

@implementation SYTitleItem
+ (instancetype)itemWithTitle:(NSString*)title color:(UIColor*)color font:(CGFloat)fontSize imageName:(NSString *)imageName
{
    SYTitleItem *item = [[SYTitleItem alloc] init];
    item.title = title;
    item.color = color;
    item.font = [UIFont systemFontOfSize:fontSize];
    item.image = [UIImage imageNamed:imageName];
    return item;
}
+ (instancetype)itemWithTitle:(NSString*)title hexColor:(long)hexColor font:(CGFloat)fontSize imageName:(NSString *)imageName
{
    SYTitleItem *item = [[SYTitleItem alloc] init];
    item.title = title;
    item.color = SYColorFromRGB(hexColor);
    item.font = [UIFont systemFontOfSize:fontSize];
    item.image = [UIImage imageNamed:imageName];
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
/***自动刷新的拖拽比例*/
@property(nonatomic ,assign) CGFloat autoRefreshProgress;
/***记录控件不同的状态的样式*/
@property(nonatomic ,strong) SYTitleItem *headerNormalItem;
@property(nonatomic ,strong) SYTitleItem *headerPullingItem;
@property(nonatomic ,strong) SYTitleItem *headerRefreshingItem;
@property(nonatomic ,strong) SYTitleItem *headerNoMoreDataItem;

@end

@implementation SYRefreshView

- (void)autoRefreshProgress:(CGFloat)progress
{
    if (progress>1.0) {
        progress = 1;
    }else if (progress<0){
        progress = 0;
    }
    _autoRefreshProgress = progress;
}

- (void)autoRefresh
{
    _autoRefreshProgress = autoRefreshProgress;
}

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
        _arrowView.image = [self refreshOriIsLeftOrRight]?[self arrowLrImage]:[self arrowNormalImage];
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

- (UIImage*)arrowNormalImage
{
    NSString *imgSrc = [[NSBundle bundleForClass:[self class]] pathForResource:@"SYRefresh" ofType:@"bundle"];
    return [UIImage imageWithContentsOfFile:[imgSrc stringByAppendingPathComponent:@"arrow@2x.png"]];
}

- (UIImage*)arrowLrImage
{
    NSString *imgSrc = [[NSBundle bundleForClass:[self class]] pathForResource:@"SYRefresh" ofType:@"bundle"];
    return [UIImage imageWithContentsOfFile:[imgSrc stringByAppendingPathComponent:@"arrowLeft@2x.png"]];
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

+ (SYRefreshView*)refreshWithOrientation:(SYRefreshViewOrientation)orientation height:(CGFloat)height completionBlock:(SYRefreshViewbeginRefreshingCompletionBlock)completionBlock
{
    SYRefreshView *view = [[SYRefreshView alloc] init];
    BOOL isFooter = NO;
    if(orientation==SYRefreshViewOrientationBottom|| orientation==SYRefreshViewOrientationRight){
        isFooter = YES;
    }
    view.sy_height = height;
    view.isFooter = isFooter;
    view.orientation = orientation;
    if (!view.isFooter) {
        view.beginBlock = completionBlock;
    }else{
        view.endBlock = completionBlock;
    }
    if ([view refreshOriIsLeftOrRight]) {
        view.titleL.numberOfLines = 0;
    }
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
    self.arrowRotation = YES; //默认箭头图片可以旋转
    self.arrowView.transform = CGAffineTransformIdentity;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    self.scrollview = (UIScrollView*)newSuperview;
    if ([self refreshOriIsLeftOrRight]) {
        self.width = self.sy_height;
        self.left = 0;
        if (!self.isFooter) {
            self.left = -self.width;
        }
        self.height = newSuperview.height;
        self.scrollview.alwaysBounceHorizontal = YES;
    }else{
        self.height = self.sy_height;
        self.left = 0;
        if (!self.isFooter) {
            self.top = -self.sy_height;
        }else{
            self.top = CGRectGetMaxY(newSuperview.frame);
        }
        self.width = newSuperview.width;
        self.scrollview.alwaysBounceVertical = YES;
    }
    
    [self removeObservers];
    [self addObservers];
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    if (self.isFooter) return;
    UIViewController *currentVc = [self currentViewController];
    if (currentVc.automaticallyAdjustsScrollViewInsets == NO) { //如果用户设置了不要自定调整内边距 我们就自己处理导航栏问题
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

- (void)setHideAllSubviews:(BOOL)hideAllSubviews
{
    _hideAllSubviews = hideAllSubviews;
    self.titleL.hidden = YES;
    self.indicatorView.hidden = YES;
    self.arrowView.hidden = YES;
}

- (void)setSy_height:(CGFloat)sy_height
{
    if (sy_height>0) {
        _sy_height = sy_height;
        [self setNeedsLayout];
    }
}

- (CGFloat)titleWidth
{
    if (self.titleL.text.length<=0) return 0;
    return [self.titleL.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleL.font} context:nil].size.width;
}

- (CGFloat)titleHeight
{
    if (self.titleL.text.length<=0) return 0;
    return [self.titleL.text boundingRectWithSize:CGSizeMake(SYVerticalOroTitleW,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleL.font} context:nil].size.height;
}

- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
    [self.scrollview addObserver:self forKeyPath:SYKeyPathContentOffset options:options context:nil];
    [self.scrollview addObserver:self forKeyPath:SYKeyPathContentSize options:options context:nil];
}

- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:SYKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:SYKeyPathContentSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (!self.userInteractionEnabled) return;
    if ([keyPath isEqualToString:SYKeyPathContentOffset]) {
        [self scrollViewDidScrollChange];
    }
    if (self.hidden)  return;
    if ([keyPath isEqualToString:SYKeyPathContentSize]){
        [self scrollViewContentSizeDidChange];
    }
}

- (void)scrollViewDidScrollChange
{
    [self.indicatorView stopAnimating];
    if (self.state == SYRefreshViewRefreshing || !self.window) return;
    if ([self refreshOriIsLeftOrRight]) {
        [self refreshOffsetXchanged];
    }else{
        [self refreshOffsetYchanged];
    }
}

- (void)scrollViewContentSizeDidChange
{
    CGSize contentsize = self.scrollview.contentSize;
    if (self.orientation == SYRefreshViewOrientationRight) {
        if (self.left != contentsize.width) {
            //当内容不满一个屏幕的时候就隐藏底部的刷新控件
            if (contentsize.width<self.scrollview.width) {
                self.scrollview.sy_footer.alpha = 0.f;
            }
            self.left = contentsize.width;
        }
    }else if(self.orientation == SYRefreshViewOrientationBottom || self.isFooter){
        if (self.top != contentsize.height) {
            self.top = contentsize.height;
        }
        //当内容不满一个屏幕的时候就隐藏底部的刷新控件
        if (contentsize.height<self.scrollview.height) {
            self.scrollview.sy_footer.alpha = 0.f;
        }
    }
}

- (void)dragingProgress:(CGFloat)progress{}

#pragma mark 处理上下刷新控件的位置
- (void)refreshOffsetYchanged
{
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
            [self dragingProgress:dragingProgress];
            if (self.state == SYRefreshViewStateIdle&&offsetY<pullingOffsetY) { //负数 往下拉
                self.state = SYRefreshViewPulling;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                    }];
                }
            }else if (self.state == SYRefreshViewPulling&&offsetY>pullingOffsetY){//正数 往回弹
                self.state = SYRefreshViewStateIdle;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformIdentity;
                    }];
                }
            }
        }else{
            
            CGFloat contentS = self.scrollview.contentSize.height;
            if (contentS<self.scrollview.height) { //内容不足一个屏幕 就不显示尾部的刷新
                self.scrollview.sy_footer.alpha = 0.f;
                return;
            }else{
                //开启自动刷新
                if (self.autoRefreshProgress>0) {
                    if (offsetY>=(contentS-self.scrollview.height-self.scrollview.contentInset.bottom-self.height)*self.autoRefreshProgress) {
                        [self beginRefreshing];
                        return;
                    }
                }
            }
            CGFloat pullingOffsetX = contentS - self.scrollview.height+self.height;
            if (self.state == SYRefreshViewStateIdle&&offsetY>pullingOffsetX) { //正数 往上拉
                self.state = SYRefreshViewPulling;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                    }];
                }
            }else if (self.state == SYRefreshViewPulling&&offsetY<pullingOffsetX){//负数 往下弹
                self.state = SYRefreshViewStateIdle;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformIdentity;
                    }];
                }
            }
        }
    }else if (self.state == SYRefreshViewPulling){
        [self beginRefreshing];
    }
}

#pragma mark 处理左右刷新控件的位置
- (void)refreshOffsetXchanged
{
    // 当前的contentOffset
    CGFloat offsetX = self.scrollview.contentOffset.x;
    if (self.scrollview.isDragging) {
        self.alpha = 1.0;
        if (!self.isFooter) {
            // 头部控件特殊处理 如：有导航栏遮挡问题处理
            CGFloat justOffsetX = - self.scrollview.contentInset.left;
            CGFloat pullingOffsetX = justOffsetX - self.width;
            CGFloat dragingProgress = (justOffsetX - offsetX) / self.width;
            self.alpha = dragingProgress;
            if (self.state == SYRefreshViewStateIdle&&offsetX<pullingOffsetX) { //负数 往右边
                self.state = SYRefreshViewPulling;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                    }];
                }
            }else if (self.state == SYRefreshViewPulling&&offsetX>pullingOffsetX){//正数往左边
                self.state = SYRefreshViewStateIdle;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                    }];
                }
            }
        }else{
            
            CGFloat contentS = self.scrollview.contentSize.width;
            if (contentS<self.scrollview.width) { //内容不足一个屏幕 就不显示尾部的刷新
                self.scrollview.sy_footer.alpha = 0.f;
                return;
            }
            CGFloat pullingOffsetX = contentS - self.scrollview.width+self.width;
            if (self.state == SYRefreshViewStateIdle&&offsetX>pullingOffsetX) { //正数 往左边
                self.state = SYRefreshViewPulling;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                    }];
                }
            }else if (self.state == SYRefreshViewPulling&&offsetX<pullingOffsetX){//负数 往右边
                self.state = SYRefreshViewStateIdle;
                if (self.isArrowRotation) {
                    [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                    }];
                }
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
        if (self.state ==SYRefreshViewStateIdle) {
            [self setTitleAttrTextItem:item];
        }
    }else if (state == SYRefreshViewPulling){
        self.headerPullingItem = item;
        if (self.state ==SYRefreshViewPulling) {
            [self setTitleAttrTextItem:item];
        }
    }else if (state == SYRefreshViewRefreshing){
        self.headerRefreshingItem = item;
        if (self.state == SYRefreshViewRefreshing) {
            [self setTitleAttrTextItem:item];
        }
    }else if (state == SYRefreshViewNoMoreData){
        self.headerNoMoreDataItem = item;
    }
}

- (SYRefreshViewState)getState
{
    return self.state;
}

- (void)setState:(SYRefreshViewState)state
{
    if (state == self.lastState) return;
    _state = state;
    self.lastState = state;
    if (state == SYRefreshViewStateIdle) {
        [self setTitleAttrTextItem:self.headerNormalItem];
    }else if (state == SYRefreshViewPulling){
        [self setTitleAttrTextItem:self.headerPullingItem];
    }else if (state == SYRefreshViewRefreshing){
        [self setTitleAttrTextItem:self.headerRefreshingItem];
    }
}

- (void)setTitleAttrTextItem:(SYTitleItem*)item
{
    UIColor *normalColor = [UIColor blackColor];
    
    if (self.isFooter) { //如果是尾部刷新控件
        if (self.state == SYRefreshViewStateIdle) {
            self.titleL.text = item.title?item.title:SYRefreshViewFooterStateIdleTitle;
        }else if (self.state == SYRefreshViewPulling){
            self.titleL.text = item.title?item.title:SYRefreshViewFooterPullingTitle;
        }else if (self.state == SYRefreshViewRefreshing){
            self.titleL.text = item.title?item.title:SYRefreshViewFooterRefreshingTitle;
        }
    }else{
        if (self.state == SYRefreshViewStateIdle) {
            self.titleL.text = item.title?item.title:SYRefreshViewStateIdleTitle;
        }else if (self.state == SYRefreshViewPulling){
            self.titleL.text = item.title?item.title:SYRefreshViewPullingTitle;
        }else if (self.state == SYRefreshViewRefreshing){
            self.titleL.text = item.title?item.title:SYRefreshViewRefreshingTitle;
        }
    }
    self.titleL.textColor = item.color?item.color:normalColor;
    self.titleL.font = item.font?item.font:SYRefreshViewTitleFont;
    if (![self refreshOriIsLeftOrRight]) { //如果是水平刷新 需要特殊处理
        self.arrowView.image = item.image?item.image:[self arrowNormalImage];
    }else{
        self.arrowView.image = item.image?item.image:[self arrowLrImage];
    }
    [self setNeedsLayout];
}

- (void)getNormalTitle
{
    
}



- (void)beginRefreshing
{
    if (self.state == SYRefreshViewRefreshing || self.state == SYRefreshViewNoMoreData)  return;
    if (self.state == SYRefreshViewStateIdle) {
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.alpha = 1.0;
        }];
    }
    self.state = SYRefreshViewRefreshing;
    self.arrowView.hidden = YES;
    if (!self.hideAllSubviews) {
        [self.indicatorView startAnimating];
    }
    if ([self refreshOriIsLeftOrRight]) {
        [self beginRefreshingOffsetX];
    }else{
        [self beginRefreshingOffsetY];
    }
}

- (void)beginRefreshingOffsetY
{
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

- (void)beginRefreshingOffsetX
{
    if (!self.isFooter) { //头部刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentOffset = CGPointMake(-self.width-self.scrollview.contentInset.left, 0);
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left+self.width, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            [self excuteBlock];
        }];
    }else{ //尾部刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right+self.width);
        }completion:^(BOOL finished) {
            [self excuteBlock];
        }];
    }
}

- (void)endRefreshing
{
    [self.indicatorView stopAnimating];
    self.arrowView.transform = CGAffineTransformIdentity;
    if ([self refreshOriIsLeftOrRight]) {
        [self endRefreshingOffsetX];
    }else{
        [self endRefreshingOffsetY];
    }
}
- (void)endRefreshingOffsetY
{
    if (!self.isFooter) { //头部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top-self.height, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            self.alpha  = 0.f;
            self.state = SYRefreshViewStateIdle;
            if (!self.isHideAllSubviews) {
                if (!self.isHiddenArrow) {
                    self.arrowView.hidden = NO;
                }
            }
        }];
    }else{ //尾部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom-self.height, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            self.alpha  = 0.f;
            self.state = SYRefreshViewStateIdle;
            if (!self.isHideAllSubviews) {
                if (!self.isHiddenArrow) {
                    self.arrowView.hidden = NO;
                }
            }
        }];
    }
}

- (void)endRefreshingOffsetX
{
    if (!self.isFooter) { //头部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left-self.width, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            self.arrowView.transform = CGAffineTransformIdentity;
            self.alpha  = 0.f;
            self.state = SYRefreshViewStateIdle;
            if (!self.isHiddenArrow) {
                self.arrowView.hidden = NO;
            }
        }];
    }else{ //尾部结束刷新处理
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset =  UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right-self.width);
        }completion:^(BOOL finished) {
            self.arrowView.transform = CGAffineTransformIdentity;
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

#pragma mark 内部私有方法
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

- (BOOL)refreshOriIsLeftOrRight
{
    if (self.orientation&&
        (self.orientation==SYRefreshViewOrientationTop||self.orientation==SYRefreshViewOrientationBottom)) //上下刷新
    {
        return NO;
    }else if(self.orientation==SYRefreshViewOrientationLeft || self.orientation==SYRefreshViewOrientationRight){//左右刷新
        return YES;
    }else{  //没有设置方向 默认就是上下刷新
        return NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //去除隐式动画 collectionview默认会存在隐式动画
    if ([self.scrollview isKindOfClass:[UICollectionView class]]) {
        [UIView performWithoutAnimation:^{
            [self layoutAllSubViews];
        }];
    }else{
        [self layoutAllSubViews];
    }
}

- (void)layoutAllSubViews
{
    if ([self refreshOriIsLeftOrRight]) {
        
        if (self.orientation == SYRefreshViewOrientationLeft) {
            
            self.arrowView.width = self.arrowView.image.size.width;
            self.arrowView.height = self.arrowView.image.size.height;
            self.arrowView.left = SYArrowRightMargin;
            self.arrowView.centerY = self.centerY;
            
            self.indicatorView.frame = self.arrowView.frame;
            self.indicatorView.centerY = self.centerY;
            
            self.titleL.height = [self titleHeight];
            self.titleL.left =  CGRectGetMaxX(self.arrowView.frame)+(self.arrowRightInset>0?self.arrowRightInset:SYArrowRightMargin);
            self.titleL.top = (self.height-self.titleL.height)*0.5;
            self.titleL.width = SYVerticalOroTitleW;
            
        }else{
            
            self.arrowView.width = self.arrowView.image.size.width;
            self.arrowView.height = self.arrowView.image.size.height;
            self.arrowView.left = SYArrowRightMargin;
            self.arrowView.centerY = self.centerY;
            
            self.indicatorView.frame = self.arrowView.frame;
            self.indicatorView.centerY = self.centerY;
            
            self.titleL.height = [self titleHeight];
            self.titleL.left =  CGRectGetMaxX(self.arrowView.frame)+(self.arrowRightInset>0?self.arrowRightInset:SYArrowRightMargin);
            self.titleL.top = (self.height-self.titleL.height)*0.5;
            self.titleL.width = SYVerticalOroTitleW;
        }
        
    }else{
        
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
}

- (void)noMoreData
{
    self.arrowView.hidden = YES;
    self.indicatorView.hidden = YES;
    self.state = SYRefreshViewNoMoreData;
    self.titleL.text = self.headerNoMoreDataItem.title? self.headerNoMoreDataItem.title:SYRefreshViewNoMoreDataTitle;
    self.titleL.textColor = self.headerNoMoreDataItem.color? self.headerNoMoreDataItem.color:[UIColor blackColor];
    
    if ([self refreshOriIsLeftOrRight]) {
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom, self.scrollview.contentInset.right+self.width);
        }completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:SYAnimationDuration animations:^{
            self.scrollview.contentInset = UIEdgeInsetsMake(self.scrollview.contentInset.top, self.scrollview.contentInset.left, self.scrollview.contentInset.bottom+self.height, self.scrollview.contentInset.right);
        }completion:^(BOOL finished) {
            
        }];
    }
    [self setNeedsLayout];
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
