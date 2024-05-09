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

#import "sphere.h"

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

//@property (nonatomic, assign) GLuint texture;

@end

@implementation GLESDemoController {
    GLuint attrTextureBuffer;
    GLuint attrBuffer;
    GLuint vertexNormalBuffer;
}

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
    [self setTexture];
    
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
    //Generation, bind, and copy data into a new texture buffer
    GLuint      textureBufferID;
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    
//    for (int i = 0; i < 6; i++) {
        
    fileName = [NSString stringWithFormat:@"Earth512x256.jpg"];
    
    //1、获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片的大小
    size_t width = 512;
    size_t height = 256;
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //3、在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
//    }
    
    //设置纹理属性
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

}

- (void) updateTexture {
    NSString *fileName = @"Earth512x256.jpg";
//    if (_times > 0) {
//       fileName = @"pic2.jpeg";
//    }else {
//        fileName = @"texture0.png";
//    }
    CGImageRef imageRef = [UIImage imageNamed:fileName].CGImage;
    if (!imageRef) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }

    // 2 读取图片的大小
    size_t width = 512;
    size_t height = 512;

    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte

    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);

    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);

    CGContextRelease(spriteContext);

    float fw = width, fh = height;
        
    // 生成图片纹理
    //        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, fw, fh, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
}

- (void)setupVectex {
    
    
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVerts), sphereVerts, GL_DYNAMIC_DRAW);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(testVerts), testVerts, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &vertexNormalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexNormalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereNormals), sphereNormals, GL_DYNAMIC_DRAW);
    

    glGenBuffers(1, &attrTextureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereTexCoords), sphereTexCoords, GL_DYNAMIC_DRAW);
    
    
//    GLuint EBO;
//    glGenBuffers(1, &EBO);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
}

- (void) setTexture {
    glActiveTexture(GL_TEXTURE0);
    // 生成纹理ID
    GLuint texture;
    glGenTextures(1, &texture);
    // 绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    
    //
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 512, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glGenerateMipmap(GL_TEXTURE_2D);
    glUniform1i(glGetUniformLocation(_myProgram, "ourTexture"), 0);
//    self.texture = texture;
}

- (void)renderLayer {
    
    glClearColor(1, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self updateTexture];

    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);

    
    glBindBuffer(GL_ARRAY_BUFFER, vertexNormalBuffer);
    GLuint vertexNormal = glGetAttribLocation(self.myProgram, "vertexNormal");
    glEnableVertexAttribArray(vertexNormal);
    glVertexAttribPointer(vertexNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);

    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
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
    
    KSMatrix4 _viewMatrix;
    ksMatrixLoadIdentity(&_viewMatrix);
    ksTranslate(&_viewMatrix, 0.0, 0.0, -6);
    ksRotate(&_viewMatrix, _yDegree, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(viewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_viewMatrix.m[0][0]);
    
    KSMatrix4 _modelMatrix;
    ksMatrixLoadIdentity(&_modelMatrix);
    ksScale(&_modelMatrix, 0.5, 0.5, 0.5);
    ksTranslate(&_modelMatrix, 0, 0, 0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelMatrix.m[0][0]);
    
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    KSMatrix4 _modelMatrix2;
    ksMatrixLoadIdentity(&_modelMatrix2);
    ksTranslate(&_modelMatrix2, 0, 0.5, -1.0);
    ksScale(&_modelMatrix2, 0.3, 0.3, 0.3);
    ksRotate(&_modelMatrix2, _xDegree, 1.0, 0.0, 0.0); //绕X轴
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelMatrix2.m[0][0]);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    //2、模型视图矩阵
    //2.1、模型视图矩阵的构造
//    KSMatrix4 _modelViewMatrix;
//    ksMatrixLoadIdentity(&_modelViewMatrix);
//
//    //平移
//    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -6.0);
//
//    //旋转
//    KSMatrix4 _rotationMatrix;
//    ksMatrixLoadIdentity(&_rotationMatrix);
//    ksRotate(&_rotationMatrix, _xDegree, 1.0, 0.0, 0.0); //绕X轴
//    ksRotate(&_rotationMatrix, _yDegree, 0.0, 1.0, 0.0); //绕Y轴
//    ksRotate(&_rotationMatrix, _zDegree, 0.0, 0.0, 1.0); //绕Z轴
//
//    //2.2、变换矩阵相乘
//    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
//
//    //2.3、传递给着色器程序
//    glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
    
//    glDrawArrays(GL_TRIANGLES, 0, sizeof(testVerts) / sizeof(testVerts[0]));
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
