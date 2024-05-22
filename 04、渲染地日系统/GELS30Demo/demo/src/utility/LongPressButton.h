//
//  LongPressButton.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LongPressButton : UIButton

@property (nonatomic, copy) void (^longPressAction)(void);
@property (nonatomic, assign) NSTimeInterval longPressDuration;
@property (nonatomic, assign) NSTimeInterval repeatInterval;

@end

NS_ASSUME_NONNULL_END
