//
//  TestTableViewController.m
//  SYRefreshExample
//
//  Created by shusy on 2017/5/16.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "TestTableViewController.h"
#import "SYRefresh.h"

@interface TestTableViewController ()

@property(nonatomic,strong)UIPanGestureRecognizer *pan;

@end

@implementation TestTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
//    self.tableView.sy_header = [SYGifHeader headerWithData:data isBig:YES height:150 callBack:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_header endRefreshing];
//            NSLog(@"刷新结束");
//        });
//    }];
//    [self.tableView.sy_header beginRefreshing];
//    
////    
//    self.tableView.sy_header = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationTop isBig:NO width:80 callBack:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_header endRefreshing];
//            NSLog(@"刷新结束");
//        });
//    }];
//    [self.tableView.sy_header beginRefreshing];
//    
//    
    self.tableView.sy_footer = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationBottom isBig:NO width:80 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_footer endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    
//    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:url];
//    self.tableView.sy_header = [SYGifHeader headerWithData:data isBig:YES height:150 callBack:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_header endRefreshing];
//            NSLog(@"刷新结束");
//        });
//    }];
//    [self.tableView.sy_header beginRefreshing];

    {
        self.tableView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView.sy_header endRefreshing];
                
            });
        }];
        SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"下拉回到商品详情" color:[UIColor redColor]];
        SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放回到商品详情" color:[UIColor yellowColor]];
        SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"更新中..." color:[UIColor brownColor]];
        [self.tableView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
        [self.tableView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
        [self.tableView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
    }
   
//    self.tableView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_footer endRefreshing];
//        });
//    }];
//    SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"上拉查看图文详情" color:[UIColor redColor]];
//    SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放查看图文详情" color:[UIColor greenColor]];
//    SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"加载中." color:[UIColor purpleColor]];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewStateIdle item:item1];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewPulling item:item2];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewRefreshing item:item3];
    
    self.tableView.sectionHeaderHeight = 45;
    self.tableView.sectionFooterHeight = 0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"title===%zd",indexPath.row];
    return cell;
}

@end
