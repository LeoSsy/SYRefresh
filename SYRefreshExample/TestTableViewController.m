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
    
        __weak typeof(self)weakSelf = self;
 
        SYGifHeader *gifHeader = [SYGifHeader headerWithHeight:45 orientation:SYRefreshViewOrientationTop callBack:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView.sy_header endRefreshing];
                count = 25;
                [weakSelf.tableView reloadData];
            });
        }];
     self.tableView.sy_header = gifHeader; //需要先添加到scrollview上面 然后再设置图片数组 否则会导致崩溃 此问题后期优化

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
    
        self.tableView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView.sy_footer endRefreshing];
                count += 15;
                [weakSelf.tableView reloadData];
            });
        }];
        [self.tableView.sy_footer autoRefresh];
        self.tableView.sectionHeaderHeight = 45;
        self.tableView.sectionFooterHeight = 0;
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
