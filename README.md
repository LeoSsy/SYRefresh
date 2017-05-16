# SYRefresh
一款简洁易用的刷新控件

示例程序：
![MacDown Screenshot](./SYRefreshDemo.gif)
![MacDown Screenshot](./collectionrefresh.gif)

默认刷新控件使用方法：
	
	//添加头部刷新控件
    ScrollView.sy_header = [SYRefreshView refreshWithHeight:40 isFooter:NO completionBlock:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_firstScrollView.sy_header endRefreshing];
                   
          });
    }];
        
    //添加尾部刷新控件    
    ScrollView.sy_footer = [SYRefreshView refreshWithHeight:55 isFooter:YES completionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_firstScrollView.sy_footer endRefreshing];
                [self showSecondController];
            });
     }];


GIF图片刷新控件使用方法：

	  NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-big.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.tableView.sy_header = [SYGifHeader headerWithData:data isBig:YES height:150 callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    [self.tableView.sy_header beginRefreshing];

GIF图片加文字刷新控件使用方法：
	
	NSString *url =  [[NSBundle mainBundle] pathForResource:@"demo-small.gif" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:url];
    self.tableView.sy_header = [SYGifTextHeader textGifheaderWithData:data isBig:NO height:100 text:@"刷新吧" callBack:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView.sy_header endRefreshing];
            NSLog(@"刷新结束");
        });
    }];
    [self.tableView.sy_header beginRefreshing];

UICollectionView的使用方法同上，如果UICollectionView需要支持水平刷新功能，请设置布局的方向为水平方向即可！
    
 更多功能敬请期待！ 此控件会持续的更新和完善
