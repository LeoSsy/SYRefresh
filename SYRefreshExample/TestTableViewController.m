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

int count = 20;
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:url];
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
    
//    self.tableView.sy_footer = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationBottom isBig:NO height:80 callBack:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_footer endRefreshing];
//            NSLog(@"刷新结束");
//        });
//    }];
    
//    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
//    NSData *data = [NSData dataWithContentsOfFile:url];
//    self.tableView.sy_header = [SYGifHeader headerWithData:data isBig:YES height:150 callBack:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_header endRefreshing];
//            NSLog(@"刷新结束");
//        });
//    }];
//    [self.tableView.sy_header beginRefreshing];

//    {
//        self.tableView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.tableView.sy_header endRefreshing];
//                
//            });
//        }];
//        self.tableView.sy_header.arrowRotation = NO;
//        SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"下拉回到商品详情" color:[UIColor redColor] font:13 imageName:@"bear"];
//        SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放回到商品详情" color:[UIColor brownColor] font:13 imageName:@"hippo"];
//        SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"更新中..." color:[UIColor brownColor] font:13 imageName:@""];
//        [self.tableView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
//        [self.tableView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
//        [self.tableView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
        
        SYGifHeader *gifHeader = [SYGifHeader headerWithHeight:100 orientation:SYRefreshViewOrientationTop callBack:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.tableView.sy_footer noMoreData];
                [self.tableView.sy_header endRefreshing];
                count = 5;
                [self.tableView reloadData];

            });
        }];
        
        NSMutableArray *normailImages = [NSMutableArray array];
        for (int i = 1 ; i<=19; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"refresh_camera_frame%d",i]];
            [normailImages addObject:image];
        }
        NSMutableArray *pullingImages = [NSMutableArray array];
        UIImage *image = [UIImage imageNamed:@"refresh_camera_frame20"];
        [pullingImages addObject:image];
    
        NSMutableArray *refreshingImages = [NSMutableArray array];
        for (int i = 21 ; i<=45; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"refresh_camera_frame%d",i]];
            [refreshingImages addObject:image];
         }
        [gifHeader setImages:normailImages  forState:SYRefreshViewStateIdle];
        [gifHeader setImages:pullingImages  forState:SYRefreshViewPulling];
        [gifHeader setImages:refreshingImages forState:SYRefreshViewRefreshing];
        self.tableView.sy_header = gifHeader;
        
        
//        SYGifHeader *gifHeader = [SYGifHeader headerWithHeight:100 orientation:SYRefreshViewOrientationTop callBack:^{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                //                [self.tableView.sy_footer noMoreData];
//                [self.tableView.sy_footer endRefreshing];
//                
//            });
//        }];
//        
//        NSMutableArray *normailImages = [NSMutableArray array];
//        for (int i = 1 ; i<=19; i++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"refresh_camera_frame%d",i]];
//            [normailImages addObject:image];
//        }
//        NSMutableArray *pullingImages = [NSMutableArray array];
//        UIImage *image = [UIImage imageNamed:@"refresh_camera_frame20"];
//        [pullingImages addObject:image];
//        
//        NSMutableArray *refreshingImages = [NSMutableArray array];
//        for (int i = 21 ; i<=45; i++) {
//            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"refresh_camera_frame%d",i]];
//            [refreshingImages addObject:image];
//        }
//        [gifHeader setImages:normailImages  forState:SYRefreshViewStateIdle];
//        [gifHeader setImages:pullingImages  forState:SYRefreshViewPulling];
//        [gifHeader setImages:refreshingImages forState:SYRefreshViewRefreshing];
//        self.tableView.sy_footer = gifHeader;
        
//    }
   
    self.tableView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.tableView.sy_footer endRefreshing];
            count += 5;
            [self.tableView reloadData];
            [self.tableView.sy_footer noMoreData];
            
        });
    }];
//    SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"上拉查看图文详情" color:[UIColor redColor]];
//    SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放查看图文详情" color:[UIColor greenColor]];
//    SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"加载中." color:[UIColor purpleColor]];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewStateIdle item:item1];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewPulling item:item2];
//    [self.tableView.sy_footer setHeaderForState:SYRefreshViewRefreshing item:item3];
    
    self.tableView.sectionHeaderHeight = 45;
    self.tableView.sectionFooterHeight = 0;
    
    self.tableView.sy_header = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationTop height:50 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
            
        });
    }];
    
    self.tableView.sy_footer = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationBottom height:50 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
            
        });
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return count;
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
