//
//  NXSignal.h
//  EAVideo
//
//  Created by yangyk on 16/3/21.
//  Copyright © 2016年 yangyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXSignal : NSObject

@property (assign, nonatomic) bool enable ;

- (void)open ;
- (void)close ;

- (void)fire ;
- (void)wait ;

- (bool)trywait:(float)sec ;

@end
