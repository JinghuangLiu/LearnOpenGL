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

enum ButtonType {
    BUTTON_UP = 0,
    BUTTON_DOWN = 1,
    BUTTON_LEFT = 2,
    BUTTON_RIGHT = 3,
    BUTTON_FORWARD = 4,
    BUTTON_BACK = 5,
    BUTTON_ROTATERIGHT = 6,
    BUTTON_ROTATERILEFT = 7
};

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
    [self addButtons];
}

- (void)addButtons {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.tag = BUTTON_LEFT;
    [leftBtn setTitle:@"左" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.tag = BUTTON_RIGHT;
    [rightBtn setTitle:@"右" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *topBtn = [[UIButton alloc] init];
    topBtn.tag = BUTTON_UP;
    [topBtn setTitle:@"上" forState:UIControlStateNormal];
    [topBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *bottomBtn = [[UIButton alloc] init];
    bottomBtn.tag = BUTTON_DOWN;
    [bottomBtn setTitle:@"下" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *fontBtn = [[UIButton alloc] init];
    fontBtn.tag = BUTTON_FORWARD;
    [fontBtn setTitle:@"前" forState:UIControlStateNormal];
    [fontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fontBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.tag = BUTTON_BACK;
    [backBtn setTitle:@"后" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightRotateBtn = [[UIButton alloc] init];
    rightRotateBtn.tag = BUTTON_ROTATERIGHT;
    [rightRotateBtn setTitle:@"旋转" forState:UIControlStateNormal];
    [rightRotateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightRotateBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *leftRotateBtn = [[UIButton alloc] init];
    leftRotateBtn.tag = BUTTON_ROTATERILEFT;
    [leftRotateBtn setTitle:@"旋转" forState:UIControlStateNormal];
    [leftRotateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftRotateBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:leftBtn];
    [self.view addSubview:rightBtn];
    [self.view addSubview:topBtn];
    [self.view addSubview:bottomBtn];
    [self.view addSubview:fontBtn];
    [self.view addSubview:backBtn];
    [self.view addSubview:rightRotateBtn];
    [self.view addSubview:leftRotateBtn];
    
    leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    topBtn.translatesAutoresizingMaskIntoConstraints = NO;
    bottomBtn.translatesAutoresizingMaskIntoConstraints = NO;
    fontBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    rightRotateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    leftRotateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[bottomBtn.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-80] setActive:YES];
    [[bottomBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[bottomBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[bottomBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    
    [[topBtn.bottomAnchor constraintEqualToAnchor:bottomBtn.topAnchor constant:-60] setActive:YES];
    [[topBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[topBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[topBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    
    [[leftBtn.topAnchor constraintEqualToAnchor:topBtn.bottomAnchor constant:10] setActive:YES];
    [[leftBtn.rightAnchor constraintEqualToAnchor:topBtn.leftAnchor constant:20] setActive:YES];
    [[leftBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[leftBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    
    [[rightBtn.topAnchor constraintEqualToAnchor:topBtn.bottomAnchor constant:10] setActive:YES];
    [[rightBtn.leftAnchor constraintEqualToAnchor:topBtn.rightAnchor constant:-20] setActive:YES];
    [[rightBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[rightBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    
    [[fontBtn.bottomAnchor constraintEqualToAnchor:topBtn.topAnchor constant:-10] setActive:YES];
    [[fontBtn.leftAnchor constraintEqualToAnchor:topBtn.leftAnchor] setActive:YES];
    [[fontBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[fontBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    [[backBtn.topAnchor constraintEqualToAnchor:bottomBtn.bottomAnchor constant:10] setActive:YES];
    [[backBtn.leftAnchor constraintEqualToAnchor:bottomBtn.leftAnchor] setActive:YES];
    [[backBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[backBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    [[rightRotateBtn.topAnchor constraintEqualToAnchor:rightBtn.topAnchor] setActive:YES];
    [[rightRotateBtn.leftAnchor constraintEqualToAnchor:rightBtn.rightAnchor constant:10] setActive:YES];
    [[rightRotateBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[rightRotateBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    [[leftRotateBtn.topAnchor constraintEqualToAnchor:leftBtn.topAnchor] setActive:YES];
    [[leftRotateBtn.rightAnchor constraintEqualToAnchor:leftBtn.leftAnchor] setActive:YES];
    [[leftRotateBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[leftRotateBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
}

- (void) changeCamer:(UIButton *)sender {
    
    switch (sender.tag) {
        case BUTTON_UP:
            mNativeRender.camera->move(UP, 0.1);
            break;
        case BUTTON_DOWN:
            mNativeRender.camera->move(DOWN, 0.1);
            break;
        case BUTTON_LEFT:
            mNativeRender.camera->move(LEFT, 0.1);
            break;
        case BUTTON_RIGHT:
            mNativeRender.camera->move(RIGHT, 0.1);
            break;
        case BUTTON_FORWARD:
            mNativeRender.camera->move(FORWARD, 0.1);
            break;
        case BUTTON_BACK:
            mNativeRender.camera->move(BACKWARD, 0.1);
            break;
        default:
            break;
    }
    
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
