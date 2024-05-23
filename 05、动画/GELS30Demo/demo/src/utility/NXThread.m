//
//  TKThread.m
//  FLVPlayer
//
//  Created by administrator on 14-7-11.
//  Copyright (c) 2014年 trustsky. All rights reserved.
//

#import "NXThread.h"
#import <UIKit/UIKit.h>

@implementation NXThread

- (void) main
{
    @autoreleasepool {
        if(self.runnable != nil)
            [self.runnable thread_run] ;
        else if(self.obj != nil)
            [self.obj performSelector:self.sel withObject:self.ctx];
    }
}

- (id) init
{
    self = [super init] ;
    if(self)
    {
        self.paused = false ;
    }
    return self ;
}

- (void) dealloc
{
    self.obj = nil ;
    self.sel = nil ;
    self.ctx = nil ;
    self.runnable = nil ;
}

- (void) setQualityOfService:(NSQualityOfService)qualityOfService
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [super setQualityOfService:qualityOfService];
}

+ (void) call:(id<NXRunnable>) runnable
{
    NXThread* thread = [[NXThread alloc] init];
    thread.runnable = runnable ;
    [thread start];
}

+ (void) call:(id)obj sel:(SEL)sel
{
    NXThread* thread = [[NXThread alloc] init];
    thread.obj = obj ;
    thread.sel = sel ;
    [thread start];
}

+ (void) call:(id)obj sel:(SEL)sel ctx:(id)ctx
{
    NXThread* thread = [[NXThread alloc] init];
    thread.obj = obj ;
    thread.sel = sel ;
    thread.ctx = ctx ;
    [thread start];
}
@end
