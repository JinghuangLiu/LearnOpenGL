//
//  TKTimer.m
//  FLVPlayer
//
//  Created by administrator on 14-7-25.
//  Copyright (c) 2014年 trustsky. All rights reserved.
//


#import "NXTimer.h"
#import "NXRunLoop.h"
#import "NXThread.h"

#import <sys/time.h>


@interface BlockObject : NSObject
@property (copy, atomic) dispatch_block_t block;
@end
@implementation BlockObject
@end


@interface NXTimer ()
{
    bool _looping;
    float _interval;
    
    bool _exited;
    double _lastTime;
}

@property (strong, nonatomic) NXRunLoop* runloop;
@property (strong, nonatomic) NSArray* runmode;

@end


@implementation NXTimer

- (id)init
{
    if(self = [super init])
    {
        _looping = false;
        _interval = 0;
        self.runmode = [NSArray arrayWithObject:NSDefaultRunLoopMode];
    }
    return self;
}

- (void) startTimer
{
    if(self.runloop)
        return;
    
    self.runloop = [[NXRunLoop alloc] init];
    [self.runloop start];
    
    __weak typeof(self) weakSelf = self;
    [[self.runloop runloop] performBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf)
            [strongSelf.delegate onTimerStart:weakSelf];
    }];
}

- (void) stopTimer
{
    if(!self.runloop)
        return;

    _exited = false;
    
    [[self.runloop runloop] cancelPerformSelectorsWithTarget:self];
    
    __weak typeof(self) weakSelf = self;
    [[self.runloop runloop] performBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf)
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(onLooping) object:nil];
        if(strongSelf.delegate)
            [strongSelf.delegate onTimerStop:self];
        strongSelf->_exited = true;
    }];
    
    while(!_exited)
        [NXThread sleepForTimeInterval:0.01];
    
    [self.runloop stop];
    self.runloop = nil;
}

- (NSRunLoop*) getRunLoop
{
    return [self.runloop runloop];
}

- (void) startLoopingWithInterval:(float)interval
{
    if(!self.runloop)
        return;
    
    _interval = interval;
    _lastTime = [self getTime];
    _looping = true;
    
    __weak typeof(self) weakSelf = self;
    [[self.runloop runloop] performBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf)
        {
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(onLooping) object:nil];
            [strongSelf performSelector:@selector(onLooping) withObject:nil afterDelay:0];//immediately perform
        }
    }];
}

- (void) stopLooping
{
    if(!self.runloop)
        return;
    
    __weak typeof(self) weakSelf = self;
    [[self.runloop runloop] performBlock:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if(strongSelf)
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf selector:@selector(onLooping) object:nil];
    }];
    
    _interval = 0;
    _lastTime = 0;
    _looping = false;
}

- (double) getTime
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return 1.0 * tv.tv_sec + 1.0 * tv.tv_usec / 1000000;
}

- (void) onLooping
{
    //No.1 work timer works
    if(self.delegate)
        [self.delegate onTimerLooping:self];
    
    double nextTime = _lastTime + _interval;
    double waiting = fmax(0.0, nextTime - [self getTime]);
    
    _lastTime = nextTime;
    
    //No.2 send next looping
    if(_looping)
        [self performSelector:@selector(onLooping) withObject:nil afterDelay:waiting];
}

- (void) onBlock:(BlockObject*)param
{
    if(param.block)
        param.block();
}

- (void) dispatch:(dispatch_block_t)block
{
    if(!self.runloop)
        return;
    
    BlockObject* param = [[BlockObject alloc] init];
    param.block = block;
    
    [[self.runloop runloop] performSelector:@selector(onBlock:) target:self argument:param order:0 modes:self.runmode];
}

@end
