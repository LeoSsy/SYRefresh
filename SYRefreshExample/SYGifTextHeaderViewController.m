//
//  SYGifTextHeaderViewController.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifTextHeaderViewController.h"
#import "SYGifTextHeader.h"
#import "UIScrollView+SYRefresh.h"

@interface SYGifTextHeaderViewController ()

@end

@implementation SYGifTextHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-small.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.tableView.sy_header = [SYGifTextHeader textGifheaderWithData:data isBig:NO height:100 text:@"刷新吧" callBack:^{
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
