//
//  EffectViewController.m
//  ECoreEngineDemo
//
//  Created by yangyk on 2022/4/15.
//

#import "GLESDemoController.h"

#import "NXTimer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#import <GLKit/GLKit.h>

#include "NativeRender.h"

@interface GLESDemoController()<NXTimerDelegate, GLKViewDelegate>
{
    GLKView* _renderView;
    GLuint vertexBuffer;
    GLuint indexBuffer;
}

@property (nonatomic, strong) EAGLContext* renderContext;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic , assign) int mCount;

@end

@implementation GLESDemoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //1.设置上下文
    [self setupContext];
    
    //2.设置顶点数据（位置，颜色，纹理(渲染图片时用到)）
    [self setupVertexData];
    
    //3.设置着色器：顶点着色器和片元着色器
    [self setupEffect];
    
    //4.加载纹理
    [self setupTexture];
}

- (void)setupContext {
    
    _renderContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_renderContext) {
        NSLog(@"Failed to create ES context");
    }
    [EAGLContext setCurrentContext:_renderContext];
    
    _renderView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.renderContext];
    _renderView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    _renderView.delegate = self;
    [self.view addSubview:_renderView];
    _renderView.context = _renderContext;
    
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.0, 1.0, 1.0, 1.0);
}

- (void)setupVertexData {
    
//    GLfloat vertexArray[] =
//    {
//        //位置：（x, y, z）  颜色：（r, g, b）  纹理：（s, t）
//        0.5, -0.5, 0.0,    1.0, 0.0, 0.0,    1.0, 0.0, //右下
//        0.5, 0.5, 0.0,     1.0, 0.0, 0.0,    1.0, 1.0, //右上
//        -0.5, 0.5, 0.0,    1.0, 0.0, 0.0,    0.0, 1.0, //左上
//
//        0.5, -0.5, 0.0,    0.0, 1.0, 0.0,    1.0, 0.0, //右下
//        -0.5, 0.5, 0.0,    0.0, 1.0, 0.0,    0.0, 1.0, //左上
//        -0.5, -0.5, 0.0,   0.0, 1.0, 0.0,    0.0, 0.0  //左下
//    };
    
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    GLfloat vertexArray[] =
    {
        0.5, -0.5, 0.0f,    1.0f, 0.0f,    0.0, 0.0, 1.0f, //右下
        -0.5, 0.5, 0.0f,    0.0f, 1.0f,    0.0, 0.0, 1.0f, //左上
        -0.5, -0.5, 0.0f,   0.0f, 0.0f,    0.0, 0.0, 1.0f, //左下
        0.5, 0.5, -0.0f,    1.0f, 1.0f,    0.0, 0.0, 1.0f //右上
    };
    
    //顶点索引
    GLuint indices[] =
    {
        0, 1, 2,
        1, 3, 0
    };
    self.mCount = sizeof(indices) / sizeof(GLuint);
    
    //顶点数据缓存
    GLuint buffer;
    //申请一个缓存区标识符
    glGenBuffers(1, &buffer);
    //glBindBuffer把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //glBufferData把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); //纹理
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);   //颜色
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 5);
}

- (void)setupEffect {
    //着色器
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(0.7f,0.7f,0.7f,1.0f);
    self.effect.light0.position = GLKVector4Make(0.5f,0.5f,0.5f,0.0f);
    self.effect.material.diffuseColor = GLKVector4Make(0.8, 0.1, 0.1 , 1.0f);
    self.effect.material.specularColor = GLKVector4Make(0.1, 0.1, 0.1 , 1.0f);
    self.effect.colorMaterialEnabled = GL_TRUE;
}

- (void)setupTexture {
    //纹理贴图
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"texture0" ofType:@"png"];
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:@(1), GLKTextureLoaderOriginBottomLeft, nil];//GLKTextureLoaderOriginBottomLeft 纹理坐标系是相反的
    GLKTextureInfo* textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath
                                                                      options:options
                                                                        error:nil];
    _effect.texture2d0.name = textureInfo.name;
}

#pragma mark --GLKViewDelegate--
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.mCount, GL_UNSIGNED_INT, 0);
}

@end
