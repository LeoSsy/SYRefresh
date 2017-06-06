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
#import "SYSYRefreshConst.h"

@interface SYProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end

@implementation SYProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[SYProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

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
- (void)updateProgress:(CGFloat)progress;

/**以下属性为辅助属性 用在解析图片时保存图片信息*/
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,assign)CGFloat  duration;
@end

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
            CGImageRelease(image);
        }
        CFRelease(source);
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
        _displayLink = [CADisplayLink displayLinkWithTarget:[SYProxy proxyWithTarget:self] selector:@selector(refreshDisplay)];
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
@property(nonatomic,strong)UIImageView *gifImageView;//gif图片显示view
@property(nonatomic,strong)SYGifItem *gifItem;//图像信息 保存当前帧的图片和总帧数
@end

@implementation SYGifHeader

- (UIImageView *)gifImageView
{
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc] init];
        [self insertSubview:self.gifImageView atIndex:MAXFLOAT];
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
    return [self createHeaderOrientation:orientation height:height callBack:finishRefreshBlock];
}

+ (instancetype)headerWithData:(NSData*)data orientation:(SYRefreshViewOrientation)orientation isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock;
{
    SYGifHeader *header = [self createHeaderOrientation:orientation height:height callBack:finishRefreshBlock];
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:height];
    return header;
}

+ (instancetype)createHeaderOrientation:(SYRefreshViewOrientation)orientation height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock
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
    return  header;
}


- (void)beginRefreshing
{
    [super beginRefreshing];
    if ([self isLoadedGif]) [self.gifItem updateState:YES];
}

- (void)endRefreshing
{
    [super endRefreshing];
    if ([self isLoadedGif]) [self.gifItem updateState:NO];
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
    if (self.images.count==1) {
        self.gifImageView.top = 0;
        self.gifImageView.size = [self imageSize];
    }
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

- (UIImageView*)getGifView
{
    if (self.isLoadedGif) {
        return self.gifItem.imageView;
    }else{
        return self.gifImageView;
    }
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
        PerformWithoutAnimation( self.top = - self.height;
                                self.gifImageView.centerX = self.centerX;
                                self.gifImageView.top = self.height - imgH-(self.animtaionImageBottomMargin?_animtaionImageBottomMargin:0);)
    }else{
        PerformWithoutAnimation(self.gifItem.imageView.frame = self.bounds;)
    }
}

@end
