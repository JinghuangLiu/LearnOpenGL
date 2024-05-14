//
//  IOSVideoReader.h
//  IOS
//
//  Created by wakeyang on 2018/6/21.
//  Copyright © 2018年 IOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "IOSMediaFormat.h"

@interface IOSVideoReader : NSObject

- (instancetype) initWithAlpha:(bool) alpha;

- (bool) open:(AVAsset*)file sync:(bool)sync;

- (const IOSVideoFormat*)getFormat;

- (bool) starting:(bool)sync time:(float) begin;

- (bool) started;

- (bool) seek:(float) time;

- (float) progress;

- (bool) forward:(float) interval;

- (bool) reachend;

- (int) texture;

- (void) stop;

- (void) close;

@end
