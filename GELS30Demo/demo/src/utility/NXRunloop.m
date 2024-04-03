//
//  NXRunloop.m
//  EXDisk
//
//  Created by yangyk on 16/12/22.
//  Copyright © 2016年 xcomm. All rights reserved.
//

#import "NXRunLoop.h"
#import "NXThread.h"

@interface NXRunLoop() <NXRunnable>
{
    bool                _status ;
    CFRunLoopRef        _rnloop ;
}

@property (strong, nonatomic) NXThread* thread ;
@property (strong, nonatomic) NSTimer*  dtimer ;
@property (strong, nonatomic) NSRunLoop* looper;

@end

@implementation NXRunLoop

- (void) start
{
    _status = false ;
    
    self.thread = [[NXThread alloc] init];
    self.thread.qualityOfService = NSQualityOfServiceUserInteractive ; //线程优先级
    self.thread.runnable = self ;
    [self.thread start];
    
    while (!_status)
        [NXThread sleepForTimeInterval:0.01];
}

- (void) stop
{
    [self.thread cancel];
    
    while (_status)
        [NXThread sleepForTimeInterval:0.01];
}

- (NSRunLoop*)runloop
{
    return self.looper;
}

- (void) thread_run
{
    _rnloop = CFRunLoopGetCurrent();
    
    self.dtimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(timer_call) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:self.dtimer forMode:NSDefaultRunLoopMode];
    
    self.looper = [NSRunLoop currentRunLoop];
    
    _status = true ;
    
    while (!_thread.cancelled)
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, false);
    
    [self.dtimer invalidate];
    self.dtimer = nil ;
    
    //last loop
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, false);
    
    self.looper = nil;
    
    _rnloop = nil ;
    _status = false ;
}

- (void) timer_call
{
    //need one timer at least !!
}

- (void) dispatch:(dispatch_block_t)block
{
    CFRunLoopPerformBlock(_rnloop, kCFRunLoopDefaultMode, ^{
        if(block)
            block() ;
    }) ;
}

@end
