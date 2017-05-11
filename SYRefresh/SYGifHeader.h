//
//  SYGifHeader.h
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYRefreshView.h"

@class SYGifAnimatedImageView;

@interface SYGifItem : NSObject
/**图片数据*/
@property(nonatomic,strong)NSData *data;
/**是否是大图*/
@property(nonatomic,assign)BOOL isBig;
/**高度*/
@property(nonatomic,assign)CGFloat height;
/**动画图像对象*/
@property(nonatomic,strong)SYGifAnimatedImageView *imageView;
/**
 初始化方法
 @param data 图片数据
 @param isBig 是否是大图
 @param height 图片高度
 @return SYGifItem
 */
- (instancetype)initWithData:(NSData*)data idBig:(BOOL)isBig height:(CGFloat)height;

/**播放图片方法*/
- (void)updateState:(BOOL)isRefreshing;
/**更新图片进度值*/
- (void)updateProgress:(CGFloat)progress;
/**以下属性为辅助属性 用在解析图片时保存图片信息*/
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)CGFloat  duration;

@end

@interface SYAnimatedImage : NSObject
/**图片尺寸*/
@property(nonatomic,assign)CGSize size;
/**图片帧数*/
@property(nonatomic,assign)NSInteger frameCount;
/**
 获取当前帧图片对应时间
 @param  index 第几帧
 @return 当前帧图片对应时间
 */
- (NSTimeInterval)frameDurationForImage:(NSInteger)index;
/**
 获取当前帧图片
 @param  index 第几帧
 @return 当前帧图片
 */
- (UIImage*)imageForIndex:(NSInteger)index;
@end


@interface SYGifAnimatedImageView : UIImageView
/**gif图片对象*/
@property(nonatomic,strong)SYAnimatedImage *animatedImage;
/**当前的索引*/
@property(nonatomic,assign)NSInteger index;
/**是否正在动画*/
@property(nonatomic,assign)BOOL animated;
/**上一帧的时间*/
@property(nonatomic, assign) NSTimeInterval lastTimestamp;
/**定时器*/
@property(nonatomic,strong)CADisplayLink *displayLink;
@end

@interface SYGifAnimatedImage : SYAnimatedImage
/**图片数组*/
@property(nonatomic,strong)NSMutableArray *images;
/**初始化方法*/
- (instancetype)initWithData:(NSData*)data;
@end

@interface SYGifHeader : SYRefreshView

/**图像信息*/
@property(nonatomic,strong)SYGifItem *gifItem;

/**
 初始化方法
 @param  data 图片数据
 @param  isBig 是否是大图
 @param  height 刷新控件高度
 @return SYGifHeader
 */
+ (instancetype)headerWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;

@end
