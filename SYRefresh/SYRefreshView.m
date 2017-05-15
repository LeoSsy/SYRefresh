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
/***记录用户设置的方向*/
@property(nonatomic ,assign) SYRefreshViewOrientation orientation;
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

- (void)setTitleAttrText:(NSString*)text color:(UIColor*)color
{
    if ([self refreshOriIsLeftOrRight]) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByCharWrapping;
        style.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:SYRefreshViewTitleFont,NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:color}];
        self.titleL.attributedText = attr;
    }else{
        self.titleL.text = text;
        self.titleL.textColor = color;
    }
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

+ (SYRefreshView*)refreshWithOrientation:(SYRefreshViewOrientation)orientation width:(CGFloat)width  completionBlock:(SYRefreshViewbeginRefreshingCompletionBlock)completionBlock
{
    SYRefreshView *view = [[SYRefreshView alloc] init];
    BOOL isFooter = NO;
    if(orientation==SYRefreshViewOrientationBottom|| orientation==SYRefreshViewOrientationRight){
        isFooter = YES;
    }
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
    view.sy_width = width;
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
    if ([newSuperview isKindOfClass:[UICollectionView class]]) {
        self.width = self.sy_width;
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
    self.scrollview = (UIScrollView*)newSuperview;
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
    if (self.hidden)  return;
    if ([keyPath isEqualToString:SYKeyPathContentOffset]) {
        [self scrollViewDidScrollChange];
    }else if ([keyPath isEqualToString:SYKeyPathContentSize]){
        [self scrollViewContentSizeDidChange];
    }
}

- (void)scrollViewDidScrollChange
{
    // 正在刷新状态
    if (self.state == SYRefreshViewRefreshing) return;
    if ([self refreshOriIsLeftOrRight]) {
        [self refreshOffsetXchanged];
    }else{
        [self refreshOffsetYchanged];
    }
}

- (void)scrollViewContentSizeDidChange
{
    // 正在刷新状态
    CGSize contentsize = self.scrollview.contentSize;
    if (self.orientation == SYRefreshViewOrientationRight) {
        if (self.left != contentsize.width) {
            self.left = contentsize.width;
        }
    }
}

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
            if (self.state == SYRefreshViewStateIdle&&offsetY<pullingOffsetY) { //负数 往下拉
                self.state = SYRefreshViewPulling;
                [UIView animateWithDuration:SYAnimationDuration animations:^{
                    self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                }];
            }else if (self.state == SYRefreshViewPulling&&offsetY>pullingOffsetY){//正数 往回弹
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

#pragma mark 处理左右刷新控件的位置
- (void)refreshOffsetXchanged
{
    // 当前的contentOffset
    CGFloat offsetX = self.scrollview.contentOffset.x;
    NSLog(@"contentOffset.x==%f==left==contentsize==%f",self.scrollview.contentOffset.x,self.scrollview.contentSize.width);
    if (self.scrollview.isDragging) {
        self.alpha = 1.0;
        if (!self.isFooter) {
            // 头部控件特殊处理 如：有导航栏遮挡问题处理
            CGFloat justOffsetX = - self.scrollview.contentInset.left;
            CGFloat pullingOffsetX = justOffsetX - self.sy_width;
            CGFloat dragingProgress = (justOffsetX - offsetX) / self.sy_width;
            self.alpha = dragingProgress;
            if (self.state == SYRefreshViewStateIdle&&offsetX<pullingOffsetX) { //负数 往右边
                self.state = SYRefreshViewPulling;
                [UIView animateWithDuration:SYAnimationDuration animations:^{
                        self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                }];
            }else if (self.state == SYRefreshViewPulling&&offsetX>pullingOffsetX){//负数 往左边
                self.state = SYRefreshViewStateIdle;
                [UIView animateWithDuration:SYAnimationDuration animations:^{
                    self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                }];
            }
        }else{
            
            CGFloat pullingOffsetX = self.scrollview.contentSize.width - self.scrollview.width+self.width;
            if (self.state == SYRefreshViewStateIdle&&offsetX>pullingOffsetX) { //正数 往左边
                self.state = SYRefreshViewPulling;
                [UIView animateWithDuration:SYAnimationDuration animations:^{
                    self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
                }];
            }else if (self.state == SYRefreshViewPulling&&offsetX<pullingOffsetX){//负数 往右边
                self.state = SYRefreshViewStateIdle;
                [UIView animateWithDuration:SYAnimationDuration animations:^{
                    self.arrowView.transform = CGAffineTransformRotate( self.arrowView.transform, -(0.000001 + M_PI));
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
        [self setTitleAttrText:item.title color:item.color];
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
        [self setTitleAttrText:self.headerNormalItem.title?self.headerNormalItem.title:SYRefreshViewStateIdleTitle color:self.headerNormalItem.color?self.headerNormalItem.color:normalColor];
    }else if (state == SYRefreshViewPulling){
        [self setTitleAttrText:self.headerPullingItem.title?self.headerPullingItem.title:SYRefreshViewPullingTitle color:self.headerPullingItem.color?self.headerPullingItem.color:normalColor];
    }else if (state == SYRefreshViewRefreshing){
        [self setTitleAttrText:self.headerRefreshingItem.title?self.headerRefreshingItem.title:SYRefreshViewRefreshingTitle color:self.headerRefreshingItem.color?self.headerRefreshingItem.color:normalColor];
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
            self.scrollview.contentOffset = CGPointMake(- self.width-self.scrollview.contentInset.left, 0);
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

/**
 判断当前的控件方向是否是左右刷新
 @return  是返回yes 否返回no
 */
- (BOOL)refreshOriIsLeftOrRight
{
    if (self.orientation&&
        (self.orientation==SYRefreshViewOrientationTop||self.orientation==SYRefreshViewOrientationBottom)) //上下刷新
    {
        return NO;
    }else if(self.orientation==SYRefreshViewOrientationLeft || self.orientation==SYRefreshViewOrientationRight){//左右刷新
        return YES;
    }else{ //没有设置方向 默认就是上下刷新
        return NO;
    }
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