//
//  NewWorldViewController.m
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import "NewWorldViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#include "NativeRender.h"

@interface NewWorldViewController() {
    GLKView *renderView;
    NSTimer *myTimer;
    NativeRender mNativeRender;
}

@property (nonatomic, strong) EAGLContext *mContext;


@end

@implementation NewWorldViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化上下文和视图
    [self setupContextAndRenderView];
    
    //开始渲染
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1/30
                                               target:self
                                             selector:@selector(tick:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)setupContextAndRenderView {
    
    //新建OpenGLES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.mContext) {
        NSLog(@"Failed to create ES context");
    }
    [EAGLContext setCurrentContext:self.mContext];
    
    renderView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.mContext];
    renderView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888; //颜色缓冲区格式
    renderView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self.view addSubview:renderView];
    renderView.context = self.mContext;
//    self.myEagLayer = (CAEAGLLayer*)renderView.layer;
    
    //初始化
    mNativeRender = NativeRender();
    CGFloat scale = [[UIScreen mainScreen] scale];
    mNativeRender.create(self.view.frame.size.width*scale, self.view.frame.size.height*scale);
}

- (void)tick:(id)sender {
    //绘制
    mNativeRender.drawFrame();
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    [myTimer invalidate];
    myTimer = nil;
}


@end
