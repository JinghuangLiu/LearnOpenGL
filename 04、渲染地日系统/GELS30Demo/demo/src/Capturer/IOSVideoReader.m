//
//  IOSVideoReader.m
//  IOS
//
//  Created by wakeyang on 2018/6/21.
//  Copyright © 2018年 IOS. All rights reserved.
//

#import "IOSVideoReader.h"
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <AVFoundation/AVFoundation.h>

@interface IOSVideoReader()
{
    IOSVideoFormat _format;
    float            _progress;
    GLuint             _texture;
    CMSampleBufferRef  _nextSample;

    GLuint _previosTexWidth; //记录前一帧的宽，高(理论上视频解码过程宽高应该不会变了，这里只是兼容下)
    GLuint _previosTexHeight;

    bool _alphaEnable;
    
    CVOpenGLESTextureCacheRef _cvTextureCache;
    CVOpenGLESTextureRef _cvTextureOrigin;
}

@property (assign, nonatomic) EAGLContext*   renderContext;

@property (strong, nonatomic) AVAsset*       mediaAsset;
@property (strong, nonatomic) AVAssetTrack*  mediaTrack;

@property (strong, nonatomic) AVAssetReader* mediaReader;
@property (strong, nonatomic) AVAssetReaderTrackOutput* mediaOutput;

@end

@implementation IOSVideoReader

- (instancetype) initWithAlpha:(bool) alpha {
    if (self = [super init]) {
        _alphaEnable = alpha;
        
    }

    return self;
}


- (bool) open:(AVAsset*)file sync:(bool)sync
{
    self.renderContext = [EAGLContext currentContext];
    
    CVReturn cvRet = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.renderContext, NULL, &_cvTextureCache);
    if (cvRet != kCVReturnSuccess) {
        NSLog(@"Error:CVOpenGLESTextureCacheCreate %d\n",cvRet);
    }

    self.mediaAsset = file;

    memset(&_format, 0, sizeof(IOSVideoFormat));

    if(!self.mediaAsset)
        return false;

    NSArray* tracks = [self.mediaAsset tracksWithMediaType:AVMediaTypeVideo];
    if(!tracks || tracks.count == 0)
        return false;

    self.mediaTrack = [tracks firstObject];

    CGSize videoSzie = [self.mediaTrack naturalSize];
    _format.width = videoSzie.width;
    _format.height = videoSzie.height;
    _format.degree = [self degreeOfVideoTrack:self.mediaTrack];
    _format.frame_rate = self.mediaTrack.nominalFrameRate;
    _format.duration = CMTimeGetSeconds(self.mediaAsset.duration);

    _texture = 0;
    _progress = 0.0f;

    return true;
}

- (int)degreeOfVideoTrack:(AVAssetTrack *)videoTrack
{
    int degree = 0;
    CGAffineTransform t = videoTrack.preferredTransform;
    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        //orientation = UIImageOrientationRight;
        degree = 90;
    }
    else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        //orientation = UIImageOrientationLeft;
        degree = 270;
    }
    else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        //orientation = UIImageOrientationUp;
    }
    else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        degree = 180;
        //orientation = UIImageOrientationDown;
    }
    return degree;
}

- (const IOSVideoFormat*)getFormat
{
    return &_format;
}

- (bool) starting:(bool)sync time:(float) begin
{
    NSError* error = nil;
    self.mediaReader = [[AVAssetReader alloc] initWithAsset:self.mediaAsset error:&error];
    if(!self.mediaReader)
        return false;

    self.mediaReader.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(begin, self.mediaAsset.duration.timescale), kCMTimePositiveInfinity);
    //[self.mediaReader release]; //for mrc


    OSType type = _alphaEnable ? kCVPixelFormatType_32BGRA : kCVPixelFormatType_24RGB;
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObject:@(type) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    self.mediaOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:self.mediaTrack outputSettings:options];
    self.mediaOutput.alwaysCopiesSampleData = true;
    [self.mediaReader addOutput:self.mediaOutput];
    //[self.mediaOutput release]; //for mrc

    [self.mediaReader startReading];

    bool isok = self.mediaReader.status == AVAssetReaderStatusReading;
    if(isok)
        _nextSample = [self.mediaOutput copyNextSampleBuffer];
    
    _progress = begin;
    _texture = 0;

    return isok;
}

- (bool) started
{
    return true;
}

- (bool) seek:(float)time
{
    [self stop];
    [self starting:true time:time];
    return true;
}

- (float) progress
{
    return _progress;
}

- (bool) forward:(float) interval
{
#ifdef DEBUG
    NSTimeInterval time0 = [[NSDate date] timeIntervalSince1970];
#endif
    if(self.mediaReader.status != AVAssetReaderStatusReading)
        return false;

    _progress += interval;

    CMSampleBufferRef currSample = nil;
    while(self.mediaReader.status == AVAssetReaderStatusReading)
    {
        if(!_nextSample)
            _nextSample = [self.mediaOutput copyNextSampleBuffer];

        if(!_nextSample)
            break;

        CGFloat presentTime = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(_nextSample));
        if(presentTime <= _progress)
        {
            if(currSample)
            {
                CFRelease(currSample);
                currSample = NULL;
            }

            CMSampleBufferCreateCopy(kCFAllocatorDefault, _nextSample, &currSample);
            CFRelease(_nextSample);
            _nextSample = NULL;
        }
        else
        {
            break;
        }
    }
    
    if (self.mediaReader.status == AVAssetReaderStatusCompleted) {
        [self.mediaReader cancelReading];
        self.mediaReader = nil;
    }

    if(currSample)
    {
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(currSample);

        UIImage *image = [self imageFromPixelBuffer:pixelBuffer];
        
        if(pixelBuffer)
        {
            CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
//            size_t bytePerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
//            GLuint texWidth    = (GLuint)CVPixelBufferGetWidth(pixelBuffer);
//            GLuint texHeight   = (GLuint)CVPixelBufferGetHeight(pixelBuffer);
//            GLvoid *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);

            [self setCurrentContext];
            
            BOOL result = [self setupOriginTextureWithPixelBuffer:pixelBuffer];
            
            [self unlockPixelBuffer:pixelBuffer andRelease:currSample];
            
//            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
            CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
            
            if (_cvTextureOrigin) {
                CFRelease(_cvTextureOrigin);
                _cvTextureOrigin = NULL;
            }
            
//            if (_texture == 0) {
//                glGenTextures(1, &_texture);
//                glActiveTexture(GL_TEXTURE0);
//                glBindTexture(GL_TEXTURE_2D, _texture);
//                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//            }
//
//            glActiveTexture(GL_TEXTURE0);
//            glBindTexture(GL_TEXTURE_2D, _texture);
//
//            GLint internalFormat = _alphaEnable ? GL_RGBA: GL_RGB;
//            GLint format = _alphaEnable ? GL_BGRA: GL_RGB;
//            if (_previosTexWidth != texWidth || _previosTexHeight != texHeight) {
//                glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, texWidth, texHeight, 0, format, GL_UNSIGNED_BYTE, NULL);
//                _previosTexWidth = texWidth;
//                _previosTexHeight = texHeight;
//            }
//
//            int bytePerPixel = _alphaEnable ? 4: 3;
//
//            //如果已经内存对齐，直接上传数据
//            if (texWidth * bytePerPixel == bytePerRow) {
//
//                glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texWidth, texHeight, format, GL_UNSIGNED_BYTE, baseAddress);
//                [self unlockPixelBuffer:pixelBuffer andRelease:currSample];
//            }
//            else{
//                void *buffer = (void *)malloc(texWidth * texHeight * bytePerPixel);
//                unsigned long bufferByptePerRow = texWidth * bytePerPixel;
//                unsigned long nextBaseOffset = 0;
//                unsigned long nextBufferOffset = 0;
//
//                for (int i = 0; i < texHeight; ++i) {
//                    memcpy(buffer + nextBufferOffset, baseAddress + nextBaseOffset, texWidth*bytePerPixel);
//                    nextBaseOffset += bytePerRow;
//                    nextBufferOffset += bufferByptePerRow;
//                }
//
//                [self unlockPixelBuffer:pixelBuffer andRelease:currSample];
//
//                glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, texWidth, texHeight, format, GL_UNSIGNED_BYTE, buffer);
//                free(buffer);
//            }

            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }

#ifdef DEBUG
    NSTimeInterval time1 = [[NSDate date] timeIntervalSince1970] - time0;
    if(time1 > 0.005f)
        NSLog(@"IOSVideoReader::forward() cost time = %d", (int)(time1 * 1000));
#endif

    return true;
}

- (BOOL)setupOriginTextureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVReturn cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _cvTextureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  720,
                                                                  1280,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &_cvTextureOrigin);
    
    if (!_cvTextureOrigin || kCVReturnSuccess != cvRet) {
        NSLog(@"Error:CVOpenGLESTextureCacheCreateTextureFromImage %d\n" , cvRet);
        return NO;
    }
    
    _texture = CVOpenGLESTextureGetName(_cvTextureOrigin);
    glBindTexture(GL_TEXTURE_2D , _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    return YES;
}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    CVImageBufferRef imageBuffer =  pixelBufferRef;
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaLast, provider, NULL, true, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}

//内部工具方法释放资源
-(void) unlockPixelBuffer:(CVPixelBufferRef) pixelBuffer andRelease:(CMSampleBufferRef) sampleBuffer {
    if (pixelBuffer) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    }

    if (sampleBuffer) {
        CFRelease(sampleBuffer);
    }
}

- (bool) reachend
{
    if(!self.mediaReader || self.mediaReader.status == AVAssetReaderStatusCompleted){
        return true;
    }
    
    return self.mediaReader.status != AVAssetReaderStatusReading;
}

- (int) texture
{
    return _texture;
}

- (void) stop
{
    _progress = 0;

//    if(_currSample)
//    {
//        CFRelease(_currSample);
//        _currSample = NULL;
//    }

    if(_nextSample)
    {
        CFRelease(_nextSample);
        _nextSample = NULL;
    }

//    if(_textureCache)
//    {
//        CVOpenGLESTextureCacheFlush(_textureCache, 0);
//        CFRelease(_textureCache);
//        _textureCache = NULL;
//    }

    if(self.mediaReader.status == AVAssetReaderStatusReading)
        [self.mediaReader cancelReading];

    self.mediaReader = nil;
    self.mediaOutput = nil;

    [self setCurrentContext];
    glDeleteTextures(1, &_texture);
    _texture = 0;
}

- (void) close
{
    self.mediaTrack = nil;
    self.mediaAsset = nil;

    self.renderContext = nil;
}

- (void)setCurrentContext
{
    if ([EAGLContext currentContext] != self.renderContext) {
        [EAGLContext setCurrentContext:self.renderContext];
    }
}

@end
