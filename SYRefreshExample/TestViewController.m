//
//  TestViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/9.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "TestViewController.h"
#import "FistViewController.h"
#import "SecondViewController.h"

static const CGFloat titleH = 64;
static const CGFloat titleW = 40;
@interface TestViewController ()
@property(nonatomic,strong)UIView *titleView;
@property(nonatomic,strong)UIView *topNav;
@property(nonatomic,strong)UIView *bottomNav;
@end

@implementation TestViewController

- (UIView *)titleView
{
    if (!_titleView) {
        
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, titleH)];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.clipsToBounds = YES;
        
        UIView *topNav = [[UIView alloc] initWithFrame:_titleView.bounds];
        topNav.backgroundColor = [UIColor clearColor];
        [_titleView addSubview:topNav];
        self.topNav = topNav;
        
        UIButton *shop = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.2, 0, titleW, titleH)];
        [shop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [shop setTitle:@"商品" forState:UIControlStateNormal];
        
        UIButton *detail = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shop.frame), 0, titleW, titleH)];
        [detail setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [detail setTitle:@"详情" forState:UIControlStateNormal];
        
        UIButton *commend = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(detail.frame), 0, titleW, titleH)];
        [commend setTitle:@"评论" forState:UIControlStateNormal];
        [commend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [topNav addSubview:shop];
        [topNav addSubview:detail];
        [topNav addSubview:commend];
        
        UIView *bottomNav = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topNav.frame), _titleView.frame.size.width, _titleView.frame.size.height)];
        bottomNav.backgroundColor = [UIColor clearColor];
        [_titleView addSubview:bottomNav];
        self.bottomNav = bottomNav;
        
        UIButton *shopdetail = [[UIButton alloc] initWithFrame:CGRectMake(titleW*2, 0, titleW*2, titleH)];
        [shopdetail setTitle:@"商品详情" forState:UIControlStateNormal];
        [bottomNav addSubview:shopdetail];
        
    }
    return _titleView;
}


/**
 配置顶部内容控制器
 */
- (UIViewController*)prepareContentController
{
    FistViewController *firstvc = [[FistViewController alloc] init];
    return firstvc;
}
/**
 配置详情的控制器
 */
- (UIViewController*)prepareDetailController
{
    SecondViewController *secondvc = [[SecondViewController alloc] init];
    return secondvc;
}

/**
 *   通过颜色返回一张图片
 */
- (UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.titleView;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, titleW, titleW)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [[UINavigationBar appearance] setBackgroundImage:[self createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]] forBarMetrics:UIBarMetricsDefault];
    __weak typeof(self)weakself = self;
    self.switchViewBlock = ^(BOOL flag){
        if (flag) {
            [UIView animateWithDuration:0.25 animations:^{
                weakself.topNav.transform = CGAffineTransformMakeTranslation(0, -titleH);
                weakself.bottomNav.transform = CGAffineTransformMakeTranslation(0, -titleH);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.bottomNav.hidden = NO;
            });
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                weakself.topNav.transform = CGAffineTransformIdentity;
                weakself.bottomNav.transform = CGAffineTransformIdentity;
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.bottomNav.hidden = YES;
            });

        }
    };
    
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
