# SYRefresh
一款简洁易用的刷新控件

示例程序：
![MacDown Screenshot](./demoExample.gif)

此次更新了刷新控件的创建方式为传入指定方向设置指定方向的刷新控件，删除原来创建的方法

默认刷新控件使用方法：
	
	//添加头部刷新控件 
    第一种方式：
    ScrollView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [_firstScrollView.sy_header endRefreshing];
          });
    }];

    第二种方式：
    self.tableView.sy_header = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationTop height:50 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
        });
    }];
    
        
    //添加尾部刷新控件  
    第一种方式
    ScrollView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_firstScrollView.sy_footer endRefreshing];
                [self showSecondController];
            });
     }];
    第二种方式
    self.tableView.sy_footer = [SYRefreshView refreshWithOrientation:SYRefreshViewOrientationBottom height:50 completionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
        });
    }];

GIF图片刷新控件使用方法：

    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.tableView.sy_header = [SYGifHeader headerWithData:data orientation:SYRefreshViewOrientationTop isBig:YES height:150 callBack:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.tableView.sy_header endRefreshing];
    NSLog(@"刷新结束");
    });
    }];
    [self.tableView.sy_header beginRefreshing];

GIF图片加文字刷新控件使用方法：
	
    NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-small.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];

    self.tableView.sy_header = [SYGifTextHeader headerWithData:data orientation:SYRefreshViewOrientationTop isBig:NO height:100 callBack:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.tableView.sy_header endRefreshing];
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

传入对应状态的图片数组组成GIF图片使用方法：
    SYGifHeader *gifHeader = [SYGifHeader headerWithHeight:100 orientation:SYRefreshViewOrientationTop callBack:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
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

没有更多数据的提示使用方法：
self.tableView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.tableView.sy_footer noMoreData];
    });
}];

UICollectionView的使用方法同上，如果UICollectionView需要支持水平刷新功能，请设置布局的方向为水平方向即可！
 更多功能敬请期待！ 此控件会持续的更新和完善
