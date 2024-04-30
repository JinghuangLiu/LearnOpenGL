//
//  TKTimer.h
//  FLVPlayer
//
//  Created by administrator on 14-7-25.
//  Copyright (c) 2014年 trustsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXTimer;

@protocol NXTimerDelegate <NSObject>
@required
- (void) onTimerStart:(NXTimer*)timer ;
- (void) onTimerStop:(NXTimer*)timer ;
- (void) onTimerLooping:(NXTimer*)timer ;
@end

@interface NXTimer : NSObject

@property (weak, nonatomic) id<NXTimerDelegate> delegate;

- (void) startTimer;
- (void) stopTimer;

- (NSRunLoop*) getRunLoop;

- (void) startLoopingWithInterval:(float)interval;
- (void) stopLooping;

- (void) dispatch:(dispatch_block_t)block ;

@end
