//
//  AnimationManager.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#import "AnimationManager.h"
#import "NXTimer.h"


@interface AnimationManager()<NXTimerDelegate>

@end

@implementation AnimationManager

- (void)addAnimaton:(shared_ptr<Animation>&)anim {
    animations.push_back(anim);
}
    
- (void)loopOnce:(float)deltaTime {
    NXTimer *timer = [NXTimer new];
    [timer startLoopingWithInterval:deltaTime];
    timer.delegate = self;
}

- (void) onTimerLooping:(NXTimer*)timer {
    
}

- (void)onTimerStart:(NXTimer *)timer { 
    
}


- (void)onTimerStop:(NXTimer *)timer { 
    
}


@end

