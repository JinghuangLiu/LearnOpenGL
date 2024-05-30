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

- (void)printCurrentDateTime {
    // 获取当前日期和时间
    NSDate *currentDate = [NSDate date];
    
    // 创建一个日期格式器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 将日期转换为字符串
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    // 打印日期和时间
    NSLog(@"Current Date and Time: %@", dateString);
}

- (void) onTimerLooping:(NXTimer*)timer {
    
//    [self printCurrentDateTime];
    
    for (std::shared_ptr<Animation> &animation : self->animations) {
        animation->startAnimation();
    }
}

- (void)onTimerStart:(NXTimer *)timer { 
    
}


- (void)onTimerStop:(NXTimer *)timer { 
    
}


@end

