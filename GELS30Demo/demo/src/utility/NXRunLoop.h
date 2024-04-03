//
//  NXRunloop.h
//  EXDisk
//
//  Created by yangyk on 16/12/22.
//  Copyright © 2016年 xcomm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXTimer.h"

@interface NXRunLoop : NSObject

- (void) start;
- (void) stop;

- (NSRunLoop*)runloop;

- (void) dispatch:(dispatch_block_t)block ;

@end
