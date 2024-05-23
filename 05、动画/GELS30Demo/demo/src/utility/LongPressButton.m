//
//  LongPressButton.m
//  demo
//
//  Created by 刘靖煌 on 2024/5/22.
//

#import "LongPressButton.h"

@interface LongPressButton ()

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LongPressButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture {
    self.longPressDuration = 0.001;
    self.repeatInterval = 0.001;
    
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self startTimer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self stopTimer];
            break;
        default:
            break;
    }
}

- (void)startTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.repeatInterval target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [self timerFired]; // Trigger immediately
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerFired {
    if (self.longPressAction) {
        self.longPressAction();
    }
}

- (void)dealloc {
    [self stopTimer];
}

@end
