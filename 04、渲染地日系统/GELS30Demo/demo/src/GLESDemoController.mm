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

#include "XSMatrix.h"
using namespace xscore;

#include "NativeRender.h"
#import "sphere.h"

@interface GLESDemoController()<NXTimerDelegate, GLKViewDelegate> {
    GLKView *renderView;
    NSTimer *myTimer;
}

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) CAEAGLLayer* myEagLayer;
@property (nonatomic, assign) GLuint myProgram;

//地球旋转角度
@property (nonatomic) GLfloat sunRotationAngleDegrees;

//地球旋转角度
@property (nonatomic) GLfloat earthRotationAngleDegrees;

//月球旋转角度
@property (nonatomic) GLfloat moonRotationAngleDegrees;

@end

@implementation GLESDemoController {
    GLuint attrTextureBuffer;
    GLuint attrBuffer;
    GLuint vertexNormalBuffer;
    GLuint sunTexture;
    GLuint earthTexture;
    GLuint moonTexture;
}

//地球倾斜角度
static const GLfloat  SceneEarthAxialTiltDeg = 23.5f;
//月球绕地球一周的周期
static const GLfloat  SceneDaysPerMoonOrbit = 28.0f;
//月球的缩放
static const GLfloat  SceneMoonRadiusFractionOfEarth = 0.25;
//地球和月球的距离
static const GLfloat  SceneMoonDistanceFromEarth = 2.0;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self metaData];
    
    //初始化上下文和视图
    [self setupContextAndRenderView];
    
    //编译和链接着色器
    [self compileAndLinkShader];
    
    //设置顶点
    [self setupVectex];
    
    //设置纹理
    [self setupTexture:@"sun.jpg" textTure:&sunTexture];
    [self setupTexture:@"Earth512x256.jpg" textTure:&earthTexture];
    [self setupTexture:@"moon.jpg" textTure:&moonTexture];
    
    //开始渲染
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1/30
                                               target:self
                                             selector:@selector(tick:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)tick:(id)sender {
    
    //1秒（30帧）360度
    float degress = 360.0f / 30.0f;
    
    //太阳自转
    self.sunRotationAngleDegrees += degress/25;
    
    //旋转一圈
    self.earthRotationAngleDegrees += degress/6;
    
    //旋转一圈/月亮周期
    self.moonRotationAngleDegrees += degress / 28;
    
    [self renderLayer];
}

- (void)metaData {
    
    //当我们特别谈论到顶点着色器的时候，每个输入变量也叫顶点属性(Vertex Attribute)。
    //我们能声明的顶点属性是有上限的，它一般由硬件来决定。
    //OpenGL确保至少有16个包含4分量的顶点属性可用，但是有些硬件或许允许更多的顶点属性，你可以查询GL_MAX_VERTEX_ATTRIBS来获取具体的上限：
    int nrAttributes;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
    printf("Maximum nr of vertex attributes supported: %i \n",nrAttributes);

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

- (void)setupVectex {
    //顶点
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_DYNAMIC_DRAW);
    
    //法向量
    glGenBuffers(1, &vertexNormalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexNormalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereNormals), sphereNormals, GL_DYNAMIC_DRAW);
    
    //纹理坐标
    glGenBuffers(1, &attrTextureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_DYNAMIC_DRAW);
}

- (void)setupTexture:(NSString *)fileName textTure:(GLuint *) textTure {
    
    //加载图片
    CGImageRef imageRef = [UIImage imageNamed:fileName].CGImage;
    if (!imageRef) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    size_t width = 512;
    size_t height = 256;
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    //在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    //纹理（参考：https://learnopengl-cn.github.io/01%20Getting%20started/06%20Textures/）
    //生成纹理ID
//    GLuint earthTexture;
    glGenTextures(1, textTure);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, *textTure);
    
    //为当前绑定的纹理对象设置环绕、过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //生成图片纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 512, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glGenerateMipmap(GL_TEXTURE_2D);
    
    //通过统一采样器变量，把纹理数据传给着色器
//    glUniform1i(glGetUniformLocation(_myProgram, "ourTexture"), 0);
    
    //释放图片数据
    free(spriteData);
}


- (void)renderLayer {
    
    glClearColor(1, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    
    //以下代码说明：
    //1、为了定义顶点数据该如何管理，我们使用location这一元数据指定输入变量，这样我们才可以在CPU上配置顶点属性。
    //2、顶点着色器需要为它的输入提供一个额外的layout标识，这样我们才能把它链接到顶点数据。
    //3、也可以通过在OpenGL代码中使用glGetAttribLocation查询属性位置值(Location)
    
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
//    GLuint position = glGetAttribLocation(self.myProgram, "position");
    GLuint position = 0; //配合顶点着色器layout标识使用
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);

    
    glBindBuffer(GL_ARRAY_BUFFER, vertexNormalBuffer);
//    GLuint vertexNormal = glGetAttribLocation(self.myProgram, "vertexNormal");
    GLuint vertexNormal = 1;//配合顶点着色器layout标识使用
    glEnableVertexAttribArray(vertexNormal);
    glVertexAttribPointer(vertexNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);

    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
//    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    GLuint textCoor = 2;//配合顶点着色器layout标识使用
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, 0);
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    GLuint modelViewMatrixSlot = glGetUniformLocation(self.myProgram, "modelViewMatrix");
    
    GLuint modelMatrixSlot = glGetUniformLocation(self.myProgram, "model");
    GLuint viewMatrixSlot = glGetUniformLocation(self.myProgram, "view");
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    //1、投影矩阵
    //1.1、投影矩阵的构造
    XSMatrix projectionMatrix = XSMatrix::identity();
    //长宽比
    float aspect = width / height;
    //1.2、透视变换，视角30°
    projectionMatrix.makePerspective(30, aspect, 5.0f, 20.0f);
    
    //1.3、传递给着色器程序
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, &projectionMatrix.m[0]);
    
    //启用面剔除
    glEnable(GL_CULL_FACE);
    //深度测试
    glEnable(GL_DEPTH_TEST);
    
    //2.视图矩阵
    XSMatrix viewMatrix = XSMatrix::identity();
    viewMatrix.makeTranslate(0.0, 0.0, -10);
    //换个视角看
//    viewMatrix.makeRotate(90, 0.0, 1.0, 0.0);
    glUniformMatrix4fv(viewMatrixSlot, 1, GL_FALSE, (GLfloat*)&viewMatrix.m[0]);
    
    
    //3.模型矩阵
    //🌞太阳
    XSMatrix sunMatrix = XSMatrix::identity();
    sunMatrix.makeScale(1.5, 1.5, 1.5);
    sunMatrix.makeRotate(self.sunRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&sunMatrix.m[0]);
    glBindTexture(GL_TEXTURE_2D, sunTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //🌍地球
    XSMatrix earthMatrix = XSMatrix::identity();
    //公转
    earthMatrix.makeRotate(self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    earthMatrix.makeTranslate(0.0, 0.0, -2.0);
    earthMatrix.makeScale(0.5, 0.5, 0.5);
    //自转
    earthMatrix.makeRotate(self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&earthMatrix.m[0]);
    glBindTexture(GL_TEXTURE_2D, earthTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //🌕月球
    XSMatrix moonMatrix = earthMatrix;
    //公转
    moonMatrix.makeRotate(self.moonRotationAngleDegrees, 1.0, 0.0, 0.0);
    moonMatrix.makeTranslate(0.0, 0.0, -1.0);
    moonMatrix.makeScale(0.3, 0.3, 0.3);
    //自转，月球自转和公转周期非常接近
    moonMatrix.makeRotate(self.moonRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&moonMatrix.m[0]);
    glBindTexture(GL_TEXTURE_2D, moonTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);

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
    GLint compileSuccess;
    glGetProgramiv(self.myProgram, GL_COMPILE_STATUS, &compileSuccess);
    
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"compile error : %@", messageString);
    } else {
        NSLog(@"compile successfully.");
    }
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
