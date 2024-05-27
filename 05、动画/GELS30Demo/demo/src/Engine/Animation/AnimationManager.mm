//
//  AnimationManager.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#import "AnimationManager.h"
#import "NXTimer.h"


@interface AnimationManager()<NXTimerDelegate>
@property (nonatomic,strong) NXTimer* timer;
@end

@implementation AnimationManager

- (void)addAnimaton:(shared_ptr<Animation>&)anim {
    animations.push_back(anim);
}
    
- (void)loopOnce:(float)deltaTime {
    if (_timer) { return;}
    _timer = [NXTimer new];
    _timer.delegate = self;
    [_timer startTimer];
    [_timer startLoopingWithInterval:deltaTime];
    
}

- (void) onTimerLooping:(NXTimer*)timer {
    for (std::shared_ptr<Animation> &animation : self->animations) {
        animation->startAnimation();
    }

}

- (void)onTimerStart:(NXTimer *)timer { 
    
}


- (void)onTimerStop:(NXTimer *)timer { 
    
}


@end

