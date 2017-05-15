//
//  GifCollectionViewController.m
//  SYRefreshExample
//
//  Created by shusy on 2017/5/15.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "GifCollectionViewController.h"
#import "SYRefreshView.h"
#import "UIScrollView+SYRefresh.h"
#import "SYGifHeader.h"

@interface GifCollectionViewController ()

@end

@implementation GifCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:41/255.0 green:68/255.0 blue:119/255.0 alpha:1.0];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.collectionView.sy_header = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationLeft isBig:NO width:80 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_header endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    [self.collectionView.sy_header beginRefreshing];
    
    self.collectionView.sy_footer = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationRight isBig:NO width:80 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView.sy_footer endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    [self.collectionView.sy_footer beginRefreshing];
    

    
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
