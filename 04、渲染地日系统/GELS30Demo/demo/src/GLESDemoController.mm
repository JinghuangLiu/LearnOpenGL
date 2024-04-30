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
#import "GLESUtils.h"
#import "GLESMath.h"

@interface GLESDemoController()<NXTimerDelegate, GLKViewDelegate> {
    GLKView *renderView;
    NSTimer *myTimer;
}

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) CAEAGLLayer* myEagLayer;
@property (nonatomic, assign) GLuint myProgram;

@property (nonatomic, assign) float xDegree;
@property (nonatomic, assign) float yDegree;
@property (nonatomic, assign) float zDegree;
@property (nonatomic, assign) BOOL bX;
@property (nonatomic, assign) BOOL bY;
@property (nonatomic, assign) BOOL bZ;

@end

@implementation GLESDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化上下文和视图
    [self setupContextAndRenderView];
    
    //编译和链接着色器
    [self compileAndLinkShader];
    
    //设置顶点
    [self setupVectex];
    
    //设置纹理
    [self setupCubeTexture];
    
    //开始渲染
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.034
                                               target:self
                                             selector:@selector(tick:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)tick:(id)sender {
    int speed = 5;
    _xDegree += speed;
    _yDegree +=  speed;
    _zDegree +=  speed;
    
    [self renderLayer];
}

- (void)setupContextAndRenderView {
    
    //新建OpenGLES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.mContext) {
        NSLog(@"Failed to create ES context");
    }
    [EAGLContext setCurrentContext:self.mContext];
    
    renderView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.mContext];
    renderView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888; //颜色缓冲区格式
    renderView.delegate = self;
    [self.view addSubview:renderView];
    renderView.context = self.mContext;
    self.myEagLayer = (CAEAGLLayer*)renderView.layer;
    
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    //设置视口大小
    glViewport(self.view.frame.origin.x * scale,
               self.view.frame.origin.y * scale,
               self.view.frame.size.width * scale,
               self.view.frame.size.height * scale);
}

- (void)setupCubeTexture {
    
    NSString *fileName;
    
    //绑定纹理到默认的纹理ID
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    
    for (int i = 0; i < 6; i++) {
        
        fileName = [NSString stringWithFormat:@"texture0%@.png",@(i)];
        
        //1、获取图片的CGImageRef
        CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
        if (!spriteImage) {
            NSLog(@"Failed to load image %@", fileName);
            exit(1);
        }
        
        //2、读取图片的大小
        size_t width = 512;
        size_t height = 512;
        GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        
        //3、在CGContextRef上绘图
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        CGContextRelease(spriteContext);
        
        float fw = width, fh = height;
        glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        
        free(spriteData);
    }
    
    //设置纹理属性
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

}

- (void)setupVectex {
    GLfloat attrArr[] =
    {
        // 顶点:（x, y, z）      颜色：（r, g, b）      纹理: (s, t, p)
        // 前面
        -1.0, 1.0, 1.0,        1.0, 0.0, 0.0,       -1.0, 1.0, 1.0, // 前左上 0
        -1.0, -1.0, 1.0,       0.0, 1.0, 0.0,       -1.0, -1.0, 1.0, // 前左下 1
        1.0, -1.0, 1.0,        0.0, 0.0, 1.0,       1.0, -1.0, 1.0, // 前右下 2
        1.0, 1.0, 1.0,         1.0, 1.0, 1.0,       1.0, 1.0, 1.0, // 前右上 3
        // 后面
         -1.0, 1.0, -1.0,        1.0, 1.0, 1.0,       -1.0, 1.0, -1.0, // 后左上 4
         -1.0, -1.0, -1.0,       1.0, 1.0, 1.0,       -1.0, -1.0, -1.0, // 后左下 5
         1.0, -1.0, -1.0,        1.0, 1.0, 1.0,       1.0, -1.0, -1.0, // 后右下 6
         1.0, 1.0, -1.0,         1.0, 1.0, 1.0,       1.0, 1.0, -1.0, // 后右上 7
        // 左面
         -1.0, 1.0, -1.0,        1.0, 1.0, 1.0,       -1.0, 1.0, -1.0, // 后左上 8
         -1.0, -1.0, -1.0,       1.0, 1.0, 1.0,       -1.0, -1.0, -1.0, // 后左下 9
         -1.0, 1.0, 1.0,        1.0, 1.0, 1.0,       -1.0, 1.0, 1.0, // 前左上 10
         -1.0, -1.0, 1.0,       1.0, 1.0, 1.0,       -1.0, -1.0, 1.0, // 前左下 11
        // 右面
         1.0, 1.0, 1.0,         1.0, 1.0, 1.0,       1.0, 1.0, 1.0, // 前右上 12
         1.0, -1.0, 1.0,        1.0, 1.0, 1.0,       1.0, -1.0, 1.0, // 前右下 13
         1.0, -1.0, -1.0,        1.0, 1.0, 1.0,       1.0, -1.0, -1.0, // 后右下 14
         1.0, 1.0, -1.0,         1.0, 1.0, 1.0,       1.0, 1.0, -1.0, // 后右上 15
        // 上面
        -1.0, 1.0, -1.0,        1.0, 1.0, 1.0,       -1.0, 1.0, -1.0, // 后左上 16
        -1.0, 1.0, 1.0,        1.0, 1.0, 1.0,       -1.0, 1.0, 1.0, // 前左上 17
        1.0, 1.0, 1.0,         1.0, 1.0, 1.0,       1.0, 1.0, 1.0, // 前右上 18
        1.0, 1.0, -1.0,         1.0, 1.0, 1.0,       1.0, 1.0, -1.0, // 后右上 19
        // 下面
        -1.0, -1.0, 1.0,       1.0, 1.0, 1.0,       -1.0, -1.0, 1.0, // 前左下 20
        1.0, -1.0, 1.0,        1.0, 1.0, 1.0,       1.0, -1.0, 1.0, // 前右下 21
        -1.0, -1.0, -1.0,       1.0, 1.0, 1.0,       -1.0, -1.0, -1.0, // 后左下 22
         1.0, -1.0, -1.0,        1.0, 1.0, 1.0,       1.0, -1.0, -1.0, // 后右下 23
    };
    
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
}

- (void)renderLayer {
    
    glClearColor(1, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 9, NULL);
    
    GLuint positionColor = glGetAttribLocation(self.myProgram, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 9, (GLvoid *)(sizeof(GLfloat) * 3));
    
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 9, (GLvoid *)(sizeof(GLfloat) * 6));
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.myProgram, "modelViewMatrix");
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    //1、投影矩阵
    //1.1、投影矩阵的构造
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    //长宽比
    float aspect = width / height;
    //1.2、透视变换，视角30°
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f);
    
    //1.3、传递给着色器程序
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    //启用面剔除
    glEnable(GL_CULL_FACE);
    
    
    //2、模型视图矩阵
    //2.1、模型视图矩阵的构造
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    //平移
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -10.0);
    
    //旋转
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, _xDegree, 1.0, 0.0, 0.0); //绕X轴
    ksRotate(&_rotationMatrix, _yDegree, 0.0, 1.0, 0.0); //绕Y轴
    ksRotate(&_rotationMatrix, _zDegree, 0.0, 0.0, 1.0); //绕Z轴
    
    //2.2、变换矩阵相乘
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    //2.3、传递给着色器程序
    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
    GLuint indices[] = {
        // 前面
        0, 1, 2,
        0, 2, 3,
        // 后面
        4, 6, 5,
        4, 7, 6,
        // 左面
        8, 9, 11,
        8, 11, 10,
        // 右面
        12, 13, 14,
        12, 14, 15,
        // 上面
        16, 17, 18,
        16, 18, 19,
        // 下面
        20, 22, 23,
        20, 23, 21,
    };
    
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag {
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}

- (void)compileAndLinkShader {
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    //加载shader
    self.myProgram = [self loadShaders:vertFile frag:fragFile];
    
    //链接
    glLinkProgram(self.myProgram);
    GLint linkSuccess;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) { 
        //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
        return ;
    } else {
        NSLog(@"link successfully.");
        glUseProgram(self.myProgram);
    }
}

- (void)dealloc {
    [myTimer invalidate];
    myTimer = nil;
}

@end
