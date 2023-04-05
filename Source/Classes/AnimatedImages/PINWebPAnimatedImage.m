//
//  PINWebPAnimatedImage.m
//  PINRemoteImage
//
//  Created by Garrett Moon on 9/14/17.
//  Copyright © 2017 Pinterest. All rights reserved.
//

#if PIN_WEBP

#import "PINWebPAnimatedImage.h"

#import "NSData+ImageDetectors.h"

//#import "webp/demux.h"

@interface PINWebPAnimatedImage ()
{
    NSData *_animatedImageData;
//    WebPData _underlyingData;
//    WebPDemuxer *_demux;
    uint32_t _width;
    uint32_t _height;
    BOOL _hasAlpha;
    size_t _frameCount;
    size_t _loopCount;
    CGColorRef _backgroundColor;
    CFTimeInterval *_durations;
    NSError *_error;
}

@end

static void releaseData(void *info, const void *data, size_t size)
{
//    WebPFree((void *)data);
}

@implementation PINWebPAnimatedImage

- (instancetype)initWithAnimatedImageData:(NSData *)animatedImageData
{
    if (self = [super init]) {
        _animatedImageData = animatedImageData;
    }
    return self;
}

- (void)dealloc
{
//    if (_demux) {
//        WebPDemuxDelete(_demux);
//    }
    if (_durations) {
        free(_durations);
    }
    if (_backgroundColor) {
        CGColorRelease(_backgroundColor);
    }
}

- (NSData *)data
{
    return _animatedImageData;
}

- (size_t)frameCount
{
    return _frameCount;
}

- (size_t)loopCount
{
    return _loopCount;
}

- (uint32_t)width
{
    return _width;
}

- (uint32_t)height
{
    return _height;
}

- (uint32_t)bytesPerFrame
{
    return _width * _height * (_hasAlpha ? 4 : 3);
}

- (NSError *)error
{
    return _error;
}

- (CFTimeInterval)durationAtIndex:(NSUInteger)index
{
    return _durations[index];
}

- (CGImageRef)canvasWithPreviousFrame:(CGImageRef)previousFrame
                    previousFrameRect:(CGRect)previousFrameRect
                   clearPreviousFrame:(BOOL)clearPreviousFrame
                      backgroundColor:(CGColorRef)backgroundColor
                                image:(CGImageRef)image
                    clearCurrentFrame:(BOOL)clearCurrentFrame
                               atRect:(CGRect)rect
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 _width,
                                                 _height,
                                                 8,
                                                 0,
                                                 colorSpaceRef,
                                                 _hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNone);
    if (backgroundColor) {
        CGContextSetFillColorWithColor(context, backgroundColor);
    }
    
    if (previousFrame) {
        CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), previousFrame);
        if (clearPreviousFrame) {
            CGContextFillRect(context, previousFrameRect);
        }
    }
    
    if (image) {
        CGRect currentRect = CGRectMake(rect.origin.x, _height - rect.size.height - rect.origin.y, rect.size.width, rect.size.height);
        if (clearCurrentFrame) {
            CGContextFillRect(context, currentRect);
        }
        CGContextDrawImage(context, currentRect, image);
    }
    
    CGImageRef canvas = CGBitmapContextCreateImage(context);
    if (canvas) {
        CFAutorelease(canvas);
    }
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    
    return canvas;
}


- (CGImageRef)imageAtIndex:(NSUInteger)index cacheProvider:(nullable id<PINCachedAnimatedFrameProvider>)cacheProvider
{
    PINLog(@"Drawing webp image at index: %lu", (unsigned long)index);
    // This all *appears* to be threadsafe as I believe demux is immutable…
    
    
    CGImageRef canvas = NULL;
    
    
    return canvas;
}


@end

#endif
