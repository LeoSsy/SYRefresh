//
//  SYGifTextHeaderViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifTextHeaderViewController.h"
#import "SYRefresh.h"

@interface SYGifTextHeaderViewController ()

@end

@implementation SYGifTextHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-small.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];

    __weak typeof(self)weakSelf = self;
    self.tableView.sy_header = [SYGifTextHeaderFooter headerWithData:data orientation:SYRefreshViewOrientationTop isBig:YES height:100 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView.sy_header endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    
    SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"下拉回到商品详情" color:[UIColor redColor] font:12 imageName:nil];
    SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放回到商品详情" color:[UIColor yellowColor] font:12 imageName:nil];
    SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"更新中..." color:[UIColor brownColor] font:12 imageName:nil];
    [self.tableView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
    [self.tableView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
    [self.tableView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
    
    [self.tableView.sy_header beginRefreshing];
    
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
