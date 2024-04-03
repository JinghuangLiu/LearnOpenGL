//
//  NXSignal.m
//  EAVideo
//
//  Created by yangyk on 16/3/21.
//  Copyright © 2016年 yangyk. All rights reserved.
//

#import "NXSignal.h"

@interface NXSignal ()
{
    dispatch_semaphore_t    _sgsem ; //是否缓存为空
}
@end

@implementation NXSignal

- (void) open
{
    _enable = false ;
    _sgsem  = dispatch_semaphore_create(0);
}
- (void) close
{
    dispatch_semaphore_signal(_sgsem);
    _sgsem = nil ;
}

- (void) fire
{
    dispatch_semaphore_signal(_sgsem);
}
- (void) wait
{
    dispatch_semaphore_wait(_sgsem, DISPATCH_TIME_FOREVER);
}

- (bool)trywait:(float)sec
{
    long retcode = dispatch_semaphore_wait(_sgsem, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*sec));
    return (retcode == 0) ;
}

@end
