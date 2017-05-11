//
//  SYGifHeader.m
//  SYShopDetailAnimation
//
//  Created by shusy on 2017/5/10.
//  Copyright © 2017年 shusy. All rights reserved.
//

#import "SYGifHeader.h"
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
    if (self.animated) return;
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
    if (!self.imageView.animatedImage.frameCount) return;
    if (progress==1) {
        [self.imageView startAnimating];
    }else{
        [self.imageView stopAnimating];
        self.imageView.index = (int)(self.imageView.animatedImage.frameCount -1)*progress;
    }
}

@end

@implementation SYGifHeader

+ (instancetype)headerWithData:(NSData*)data isBig:(BOOL)isBig height:(CGFloat)height callBack:(SYRefreshViewbeginRefreshingCompletionBlock)finishRefreshBlock
{
    SYGifHeader *header = [[SYGifHeader alloc] init];
    header.isFooter = NO;
    header.hiddenArrow = YES;
    header.hiddenIndictorView = YES;
    header.sy_height = height;
    header.gifItem = [[SYGifItem alloc] initWithData:data idBig:isBig height:height];
    header.beginBlock = finishRefreshBlock;
    return header;
}

- (void)beginRefreshing
{
    [super beginRefreshing];
    [self.gifItem updateState:YES];
    [self.gifItem updateProgress:0.5];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.gifItem.imageView.frame= self.bounds;
}

@end
