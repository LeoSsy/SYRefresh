//
//  SYGifViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifViewController.h"
#import "SYGifHeader.h"
#import "UIScrollView+SYRefresh.h"

@interface SYGifViewController ()

@end

@implementation SYGifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.tableView.sy_header = [SYGifHeader headerWithData:data isBig:YES height:150 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    [self.tableView.sy_header beginRefreshing];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 500;
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
