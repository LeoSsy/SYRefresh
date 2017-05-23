//
//  VerticalCollectionViewController.m
//  SYRefreshExample
//
//  Created by shusy on 2017/5/17.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "VerticalCollectionViewController.h"
#import "SYRefresh.h"

@interface VerticalCollectionViewController ()

@end

@implementation VerticalCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static int count = 90;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.sy_header = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationTop height:60 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_header endRefreshing];
            count = 90;
            [self.collectionView reloadData];
        });
    }];
    
    SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"右滑即可刷新" color:[UIColor redColor] font:12 imageName:nil];
    SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放立即刷新" color:[UIColor greenColor] font:12 imageName:nil];
    SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"刷新中...." color:[UIColor brownColor] font:12 imageName:nil];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
    
    self.collectionView.sy_footer = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationBottom height:80 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_footer endRefreshing];
            count+=15;
            [self.collectionView reloadData];
        });
    }];
    [self.collectionView.sy_footer autoRefresh];
    
    SYTitleItem *item4 = [SYTitleItem itemWithTitle:@"左滑即可刷新" color:[UIColor redColor] font:12 imageName:nil];
    SYTitleItem *item5 = [SYTitleItem itemWithTitle:@"释放立即刷新" color:[UIColor greenColor] font:12 imageName:nil];
    SYTitleItem *item6 = [SYTitleItem itemWithTitle:@"刷新中...." color:[UIColor brownColor] font:12 imageName:nil];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewStateIdle item:item4];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewPulling item:item5];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewRefreshing item:item6];
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
    return cell;
}


@end
