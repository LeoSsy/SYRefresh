//
//  ViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/6.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYShopDetailManagerController.h"
#import "UIScrollView+SYRefresh.h"
@interface SYShopDetailManagerController ()<UIScrollViewDelegate>
{
    UIViewController *_contentVc;
    UIViewController *_detailVc;
}
@property(nonatomic,strong)UIScrollView *firstScrollView;
@property(nonatomic,strong)UIScrollView *secondScrollView;
@end

@implementation SYShopDetailManagerController

/**以下方法由子类实现*/
/**
 配置顶部内容控制器
 */
- (UIViewController*)prepareContentController{return nil;}
/**
 配置详情的控制器
 */
- (UIViewController*)prepareDetailController{return nil;}

- (UIScrollView *)firstScrollView
{
    if (!_firstScrollView) {
        _firstScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _firstScrollView.contentSize = CGSizeMake(0, self.view.frame.size.height);
        _firstScrollView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_firstScrollView.sy_footer endRefreshing];
                [self showSecondController];
            });
        }];
        {
            _firstScrollView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_firstScrollView.sy_header endRefreshing];
                   
                });
            }];
            SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"下拉回到商品详情" color:[UIColor redColor]];
            SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放回到商品详情" color:[UIColor yellowColor]];
            SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"更新中..." color:[UIColor brownColor]];
            [_firstScrollView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
            [_firstScrollView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
            [_firstScrollView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
        }

        SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"上拉查看图文详情" color:[UIColor redColor]];
        SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放查看图文详情" color:[UIColor greenColor]];
        SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"" color:[UIColor purpleColor]];
//        _firstScrollView.sy_footer.hiddenArrow = YES;
        [_firstScrollView.sy_footer setHeaderForState:SYRefreshViewStateIdle item:item1];
        [_firstScrollView.sy_footer setHeaderForState:SYRefreshViewPulling item:item2];
        [_firstScrollView.sy_footer setHeaderForState:SYRefreshViewRefreshing item:item3];
          [self.view addSubview:_firstScrollView];
    }
    return _firstScrollView;
}

- (UIScrollView *)secondScrollView
{
    if (!_secondScrollView) {
        _secondScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height+40, self.view.frame.size.width, self.view.frame.size.height)];
        _secondScrollView.backgroundColor = [UIColor clearColor];
        _secondScrollView.contentSize = CGSizeMake(0, self.view.frame.size.height);
        _secondScrollView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_secondScrollView.sy_header endRefreshing];
                [self dismissSecondController];
            });
        }];
        SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"下拉回到商品详情" color:[UIColor orangeColor]];
        SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放回到商品详情" color:[UIColor yellowColor]];
        SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"" color:[UIColor brownColor]];
        [_secondScrollView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
        [_secondScrollView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
        [_secondScrollView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
        [self.view addSubview:_secondScrollView];
    }
    return _secondScrollView;
}

- (void)showSecondController
{
    self.secondScrollView.sy_header.hidden = YES;
    CGRect frame = self.secondScrollView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.35 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.secondScrollView.frame = frame;
    } completion:^(BOOL finished) {
        self.secondScrollView.sy_header.hidden = NO;
        if (self.switchViewBlock) {
            self.switchViewBlock(true);
        }
    }];
}

- (void)dismissSecondController
{
    CGRect frame = self.secondScrollView.frame;
    frame.origin.y = self.view.frame.size.height;
    [UIView animateWithDuration:0.35 delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.secondScrollView.frame = frame;
    } completion:^(BOOL finished) {
        if (self.switchViewBlock) {
            self.switchViewBlock(false);
        }
    }];
}

- (void)prepareController
{
    self.view.backgroundColor = [UIColor clearColor];
    _contentVc = [self prepareContentController];
    _detailVc = [self prepareDetailController];
    if (_contentVc==nil) {
        // 抛出异常
        NSException *excp = [NSException exceptionWithName:@"_contentVc nil" reason:@"没有设置内容控制器,需要实现：- (UIViewController*)prepareContentController方法" userInfo:nil];
        [excp raise];
    }else if (_detailVc==nil){
        // 抛出异常
        @throw [NSException exceptionWithName:@"_detailVc nil" reason:@"没有设置详情控制器,需要实现：- (UIViewController*)prepareDetailController方法" userInfo:nil];
    }
    _contentVc.view.frame = self.view.bounds;
    [self addChildViewController:_contentVc];
    [self.firstScrollView addSubview:_contentVc.view];
    
    [self addChildViewController:_detailVc];
    _detailVc.view.frame = CGRectMake(0, 0 ,self.view.frame.size.width, self.view.frame.size.height);
    [self.secondScrollView addSubview:_detailVc.view];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    [self prepareException];
}

- (void)prepareException
{
    if (![self.parentViewController isKindOfClass:[UINavigationController class]]) { //如果没有放到导航控制器管理 就抛出异常
        NSException *excp = [NSException exceptionWithName:@"弹出视图错误" reason:@"使用导航控制器 push出当前控制器 因为一些功能依赖于导航控制器" userInfo:nil];
        [excp raise]; // 抛出异常
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareException];
    [self prepareController];
}


@end
