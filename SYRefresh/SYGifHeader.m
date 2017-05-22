//
//  SYGifHeader.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//  代码地址: https://github.com/shushaoyong/SYRefresh

#import "SYGifHeader.h"
#import "SYRefreshView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


@implementation SYAnimatedImage

- (NSTimeInterval)frameDurationForImage:(NSInteger)index{return 0.f;}
- (UIImage*)imageForIndex:(NSInteger)index{return nil;}

@end

@implementation SYGifAnimatedImage

- (NSMutableArray *)images
{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (CGSize)size{
    if (self.images.count) {
        SYGifItem *item = self.images[0];
        return item.image.size;
    }else{
        return CGSizeZero;
    }
}

- (NSInteger)frameCount
{
    return self.images.count;
}

- (instancetype)initWithData:(NSData*)data
{
    self = [super init];
    if (self) {
        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, nil);
        CFStringRef type =  CGImageSourceGetType(source);
        BOOL isTypeGif = UTTypeConformsTo(type, kUTTypeGIF);
        size_t count = CGImageSourceGetCount(source);
        if (!isTypeGif || count<1)  return nil;
        for (NSInteger index=0; index<count; index++) {
            
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, index, nil);
            NSDictionary *info = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, index, nil));
            NSDictionary *gifInfo = info[(NSString*)kCGImagePropertyGIFDictionary];
            if (gifInfo==nil) {
                continue;
            }
            CGFloat duration = 0;
            NSString *unlampedDelayStr = (NSString*)kCGImagePropertyGIFUnclampedDelayTime;
            double unlampedDelay = [gifInfo[unlampedDelayStr] doubleValue];
            if (unlampedDelay) {
                duration = unlampedDelay;
            }else{
                duration = [gifInfo[(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
            }
            if (duration<=0.001) {
                duration = 0.1;
            }
            SYGifItem *item = [[SYGifItem alloc] init];
            item.image = [UIImage imageWithCGImage:image];
            item.duration = duration;
            [self.images addObject:item];
        }
    }
    return self;
}

- (NSTimeInterval)frameDurationForImage:(NSInteger)index
{
    if (index>self.images.count-1)  return 0.f;
    SYGifItem *item = self.images[index];
    return item.duration;
}

- (UIImage*)imageForIndex:(NSInteger)index
{
    if (index>self.images.count-1)  return nil;
    SYGifItem *item = self.images[index];
    return item.image;
}
@end

@implementation SYGifAnimatedImageView

- (void)setAnimatedImage:(SYAnimatedImage *)animatedImage
{
    _animatedImage = animatedImage;
    self.image = [animatedImage imageForIndex:0];
}

- (void)setIndex:(NSInteger)index
{
    _index = index;
    self.image = [self.animatedImage imageForIndex:index];
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshDisplay)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

- (void)startAnimating
{
    if (self.animated) return;
    self.displayLink.paused = NO;
    self.animated = true;
}

- (void)stopAnimating
{
    if (!self.animated) return;
    self.displayLink.paused = true;
    self.animated = false;
}

- (void)refreshDisplay
{
    if (!self.animated||self.animatedImage==nil) return;
    CGFloat currentFrameDuration = [self.animatedImage frameDurationForImage:self.index];
    CGFloat delta = self.displayLink.timestamp - self.lastTimestamp;
    if (delta>=currentFrameDuration) {
        self.index = (self.index+1)%self.animatedImage.frameCount;
        self.lastTimestamp = self.displayLink.timestamp;
    }
}

@end

@implementation SYGifItem

- (instancetype)initWithData:(NSData*)data idBig:(BOOL)isBig height:(CGFloat)height
{
    if (self = [super init]) {
        
        self.data = data;
        self.isBig = isBig;
        self.height = height;
        self.imageView = [[SYGifAnimatedImageView alloc] init];
        SYAnimatedImage *animatedImage = [[SYGifAnimatedImage alloc] initWithData:data];
        if (!animatedImage) return nil;
        self.imageView.animatedImage = animatedImage;
        if (isBig) {
            CGRect rect = self.imageView.bounds;
            rect.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, height);
            self.imageView.bounds = rect;
            self.imageView.contentMode= UIViewContentModeScaleAspectFill;
        }else{
            CGFloat scale = animatedImage.size.width/animatedImage.size.height;
            CGRect rect = self.imageView.bounds;
            rect.size = CGSizeMake(scale*height*0.67, height*0.67);
            self.imageView.bounds = rect;
            self.imageView.contentMode= UIViewContentModeScaleAspectFit;
            
        }
    }
    return self;
}

- (void)updateState:(BOOL)isRefreshing
{
    isRefreshing?[self.imageView startAnimating]:[self.imageView stopAnimating];
}

- (void)updateProgress:(CGFloat)progress
{
    if (self.imageView.animatedImage.frameCount<=0) return;
    if (progress>=1) {
        [self.imageView startAnimating];
    }else{
        [self.imageView stopAnimating];
        self.imageView.index = (self.imageView.animatedImage.frameCount-1)*progress;
    }
}


@end

@interface SYGifHeader()
@property(nonatomic,strong)NSMutableDictionary *images; //保存对应状态的图片
@property(nonatomic,strong)NSMutableDictionary *durations; //保存对应状态的动画时间
@end

@implementation SYGifHeader

- (UIImageView *)gifImageView
{
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc] init];
        [self addSubview:_gifImageView];
    }
    return _gifImageView;
}

- (NSMutableDictionary *)images
{
    if (!_images) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

- (NSMutableDictionary *)durations
{
    if (!_durations) {
        _durations = [NSMutableDictionary dictionary];
    }
    return _durations;
}

+ (instancetype)headerWithHeight:(CGFloat)height orientation:(SYRefreshViewOrientation)orientation  callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;
{
    SYGifHeader *header = [[self alloc] init];
    header.orientation = orientation;
    BOOL isFooter = NO;
    if(orientation==SYRefreshViewOrientationBottom|| orientation==SYRefreshViewOrientationRight){
        isFooter = YES;
    }
    header.isFooter = isFooter;
    header.sy_height =  height;
    header.hideAllSubviews = YES;
    header.beginBlock = finishRefreshBlock;
    return header;
}

+ (instancetype)headerWithData:(NSData*)data orientation:(SYRefreshViewOrientation)orientation isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;
{
    SYGifHeader *header = [[self alloc] init];
    header.orientation = orientation;
    BOOL isFooter = NO;
    if(orientation==SYRefreshViewOrientationBottom|| orientation==SYRefreshViewOrientationRight){
        isFooter = YES;
    }
    header.sy_height = height;
    header.isFooter = isFooter;
    header.hideAllSubviews = YES;
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:height];
    header.beginBlock = finishRefreshBlock;
    return header;
}

- (void)beginRefreshing
{
    [super beginRefreshing];
    [self.gifItem updateState:YES];
}

- (void)endRefreshing
{
    [super endRefreshing];
    [self.gifItem updateState:NO];
}

- (void)setGifItem:(SYGifItem *)gifItem
{
    _gifItem = gifItem;
    if (gifItem.imageView) {
        self.clipsToBounds = YES;
        [self addSubview:self.gifItem.imageView];
        [self setNeedsLayout];
    }
}

- (void)setImages:(NSArray *)images duration:(double)duration forState:(SYRefreshViewState)state
{
    if (images==nil) return;
    self.images[@(state)] = images;
    self.durations[@(state)] = @(duration);
    self.gifImageView.top = 0;
    self.gifImageView.size = [self imageSize];
    
}

- (void)setImages:(NSArray *)images forState:(SYRefreshViewState)state
{
    [self setImages:images duration:images.count*0.1 forState:state];
}

- (void)dragingProgress:(CGFloat)progress
{
    [super dragingProgress:progress];
    
    if (self.images.count>0) {
        self.gifImageView.hidden = NO;
        NSArray *images = self.images[@(SYRefreshViewStateIdle)];
        if ([self getState] != SYRefreshViewStateIdle || images.count == 0) return;
        [self.gifImageView stopAnimating];
        NSUInteger index =  images.count * progress;
        if (index >= images.count) index = images.count - 1;
        self.gifImageView.image = images[index];
    }else{
        [self.gifItem updateProgress:progress];
    }
}

- (void)setState:(SYRefreshViewState)state
{
    [super setState:state];
    if (![self isLoadedGif]) {
        [self.gifImageView stopAnimating];
        if (state==SYRefreshViewPulling || state == SYRefreshViewRefreshing) {
            NSArray *images = self.images[@(state)];
            double duration = [self.durations[@(state)] doubleValue];
            if (images.count==1) {
                self.gifImageView.image = [images firstObject];
            }else{
                [self.gifImageView setAnimationImages:images];
                [self.gifImageView setAnimationDuration:duration];
                [self.gifImageView setAnimationRepeatCount:MAXFLOAT];
                [self.gifImageView startAnimating];
            }
        }else if (state == SYRefreshViewStateIdle){
            self.gifImageView.hidden = YES;
        }
    }
}

- (BOOL)isLoadedGif
{
    return self.images.count>0?NO:YES;
}

- (CGSize)imageSize
{
    if (self.images.count) {
        UIImage *image = [self.images[@(SYRefreshViewStateIdle)] firstObject];
        return image.size;
    }else{
        return self.gifItem.imageView.image.size;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.images.count>0) {
        CGFloat imgH = [self imageSize].height;
        self.top = - self.height;
        self.gifImageView.centerX = self.centerX;
        self.gifImageView.top = self.height - imgH-(self.animtaionImageBottomMargin?_animtaionImageBottomMargin:0);
    }else{
        self.gifItem.imageView.frame = self.bounds;
    }
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.gifItem = nil;
}

@end
