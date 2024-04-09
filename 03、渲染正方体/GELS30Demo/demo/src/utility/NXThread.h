//
//  TKThread.h
//  FLVPlayer
//
//  Created by administrator on 14-7-11.
//  Copyright (c) 2014年 trustsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NXRunnable <NSObject>

- (void) thread_run ;

@end

typedef enum tag_NXThreadStatusType{
    NXThreadStatusStart = 1 ,
    NXThreadStatusRunning = 2,
    NXThreadStatusStoping = 3,
    NXThreadStatusComplete = 4,
} NXThreadStatusType;

@interface NXThread : NSThread

@property (assign, nonatomic) id<NXRunnable> runnable ;

@property (assign, nonatomic) bool           paused ;

@property (assign, nonatomic) id             obj ;
@property (assign, nonatomic) SEL            sel ;
@property (retain, nonatomic) id             ctx ;

+ (void) call:(id<NXRunnable>) runnable ;

+ (void) call:(id)obj sel:(SEL)sel ;

+ (void) call:(id)obj sel:(SEL)sel ctx:(id)ctx;

@end
