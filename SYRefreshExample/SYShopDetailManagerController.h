//
//  ViewController.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/6.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 切换视图的回调
 @param flag flag 为true 表示用户上拉操作  为false 表示进入商品主页
 */
typedef void (^SYShopDetailSwithcViewCompletionBlock)(BOOL flag);

@interface SYShopDetailManagerController : UIViewController

/**以下方法由子类实现*/
/**
 配置顶部内容控制器
 */
- (UIViewController*)prepareContentController;
/**
 配置详情的控制器
 */
- (UIViewController*)prepareDetailController;

/**切换视图的同时 进行的回调方法*/
@property(nonatomic ,copy) SYShopDetailSwithcViewCompletionBlock switchViewBlock;

@end

