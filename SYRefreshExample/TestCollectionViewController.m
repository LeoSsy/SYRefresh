//
//  TestCollectionViewController.m
//  SYRefreshExample
//
//  Created by shusy on 2017/5/15.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "TestCollectionViewController.h"
#import "SYRefresh.h"


@interface TestCollectionViewController ()

@end

@implementation TestCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.sy_header = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationLeft width:60 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_header endRefreshing];
        });
    }];
    
    SYTitleItem *item1 = [SYTitleItem itemWithTitle:@"右滑即可刷新" color:[UIColor redColor]];
    SYTitleItem *item2 = [SYTitleItem itemWithTitle:@"释放立即刷新" color:[UIColor greenColor]];
    SYTitleItem *item3 = [SYTitleItem itemWithTitle:@"刷新中..." color:[UIColor brownColor]];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewStateIdle item:item1];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewPulling item:item2];
    [self.collectionView.sy_header setHeaderForState:SYRefreshViewRefreshing item:item3];
    
    self.collectionView.sy_footer = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationRight width:80 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_footer endRefreshing];
        });
    }];
    
    SYTitleItem *item4 = [SYTitleItem itemWithTitle:@"左滑即可刷新" color:[UIColor redColor]];
    SYTitleItem *item5 = [SYTitleItem itemWithTitle:@"释放立即刷新" color:[UIColor greenColor]];
    SYTitleItem *item6 = [SYTitleItem itemWithTitle:@"刷新中..." color:[UIColor brownColor]];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewStateIdle item:item4];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewPulling item:item5];
    [self.collectionView.sy_footer setHeaderForState:SYRefreshViewRefreshing item:item6];
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor grayColor];
    return cell;
}


@end
