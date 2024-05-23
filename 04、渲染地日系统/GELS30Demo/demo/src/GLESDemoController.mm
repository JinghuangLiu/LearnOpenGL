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

#include "XSMatrix.h"
#include "ShaderTools.h"
#import "ShaderUtils.h"
using namespace xscore;

#import "sphere.h"
//#import "KSCamera.hpp"
#import "KXCamera.hpp"

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


@property (nonatomic) GLfloat camerDegrees;

@property (nonatomic) GLfloat camerYDegrees;

@end

@implementation GLESDemoController {
    GLuint attrTextureBuffer;
    GLuint attrBuffer;
    GLuint vertexNormalBuffer;
    GLuint sunTexture;
    GLuint earthTexture;
    GLuint moonTexture;
    
    float cameraPos[3];
    float cameraUp[3];
    KXCamera *camera;

    float g;
    float jumpSpeed;
    float currentSpeed;
//    bool jumping = false;
    float lastFrameTS;
    bool firstCursor;
    float lastCursorX;
    float lastCursorY;
//    float fov = 45.f;
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
    g = 0.05;
    jumpSpeed = 30;
    currentSpeed = jumpSpeed;
    firstCursor = YES;
    lastCursorX = 0;
    lastCursorY = 0;
    cameraPos[0] = 0;
    cameraPos[1] = 0.0;
    cameraPos[2] = 3.0;
    
    cameraUp [0] = 0.0;
    cameraUp [1] = 1.0;
    cameraUp [2] = 0;
    camera = new KXCamera(cameraPos, cameraUp, 0, 0.0f);
    
    
    
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
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.tag = 1;
    [leftBtn setTitle:@"左" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.tag = 2;
    [rightBtn setTitle:@"右" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *topBtn = [[UIButton alloc] init];
    topBtn.tag = 0;
    [topBtn setTitle:@"上" forState:UIControlStateNormal];
    [topBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [topBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *bottomBtn = [[UIButton alloc] init];
    bottomBtn.tag = 3;
    [bottomBtn setTitle:@"下" forState:UIControlStateNormal];
    [bottomBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bottomBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *fontBtn = [[UIButton alloc] init];
    fontBtn.tag = 4;
    [fontBtn setTitle:@"前" forState:UIControlStateNormal];
    [fontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fontBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.tag = 5;
    [backBtn setTitle:@"后" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *circelBtn = [[UIButton alloc] init];
    circelBtn.tag = 6;
    [circelBtn setTitle:@"旋转" forState:UIControlStateNormal];
    [circelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [circelBtn addTarget:self action:@selector(changeCamer:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftBtn];
    [self.view addSubview:rightBtn];
    [self.view addSubview:topBtn];
    [self.view addSubview:bottomBtn];
    [self.view addSubview:fontBtn];
    [self.view addSubview:backBtn];
    [self.view addSubview:circelBtn];
    
    leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    topBtn.translatesAutoresizingMaskIntoConstraints = NO;
    bottomBtn.translatesAutoresizingMaskIntoConstraints = NO;
    fontBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    circelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    
    [[circelBtn.topAnchor constraintEqualToAnchor:rightBtn.topAnchor] setActive:YES];
    [[circelBtn.leftAnchor constraintEqualToAnchor:rightBtn.rightAnchor constant:10] setActive:YES];
    [[circelBtn.heightAnchor constraintEqualToConstant:45] setActive:YES];
    [[circelBtn.widthAnchor constraintEqualToConstant:60] setActive:YES];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [renderView addGestureRecognizer:pan];
    
}

- (void) panAction:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:self.view];
        float xpos = point.x;
        float ypos = point.y;
//        if (firstCursor) {
//             lastCursorX = xpos;
//             lastCursorY = ypos;
//             firstCursor = false;
//             return;
//         }
         
         float xoffset = xpos - lastCursorX;
         float yoffset = lastCursorY - ypos;
         lastCursorX = xpos;
         lastCursorY = ypos;
         
         float sensitivity = 0.1f;
         xoffset *= sensitivity;
         yoffset *= sensitivity;
         
         float yaw = camera->Yaw;
         float pitch = camera->Pitch;
         yaw += xoffset;
         pitch += yoffset;
         
         if (pitch > 89.0f) {
             pitch = 89.0f;
         } else if (pitch < -89.0f) {
             pitch = -89.0f;
         }
         camera->setPitch(pitch);
         camera->setYaw(yaw);
         camera->updateCameraVectors();
    }
}

- (void) changeCamer:(UIButton *)sender {
    if (sender.tag == 0) { 
        _camerYDegrees += 0.1;
        camera->move(KX_UPWARD, 0.1);
//        camera->ProcessKeyboard(KS_UP, 1);
//        camera->ProcessMovement(5, 5);
    }else if (sender.tag == 1) {
        _camerYDegrees += 1;
//        camera->ProcessKeyboard(KS_LEFT, 0.1);
//        camera->ProcessMovement(0.5, 0);
//        camera->setPitch(_camerYDegrees);
//        camera->updateCameraVectors();
        camera->move(KX_LEFT, 0.1);
    }else if (sender.tag == 2) {
        _camerYDegrees -= 1;
//        camera->ProcessKeyboard(KS_RIGHT, 0.1);
//        camera->ProcessMovement(-0.5, 0);
//        camera->move(KX_RIGHT, 0.1);
        
//        camera->setYaw(_camerDegrees);
//        camera->setPitch(_camerYDegrees);
//        camera->updateCameraVectors();
        
        camera->move(KX_RIGHT, 0.1);
        
        
    }else if (sender.tag == 3) {
        _camerYDegrees -= 0.1;
        camera->move(KX_DOWNWARD, 0.1);
//        camera->ProcessKeyboard(KS_DOWN, 1);
//        camera->ProcessMovement(-5, -5);
    }else if (sender.tag == 4) {
        camera->move(KX_FORWARD, 0.1);
    }else if ( sender.tag == 5) {
        camera->move(KX_BACKWARD, 0.1);
    }else if (sender.tag == 6) {
        _camerYDegrees += 10;
        float radius = 3;
//        float camX = -sin(_camerYDegrees) * radius;
//        float camZ = cos(_camerYDegrees) * radius;
//        
////        camera->Position[0] = camX + camera->DefaultOrigin[0];
////        camera->Position[1] = camera->DefaultOrigin[1];
////        camera->Position[2] = camZ + camera->DefaultOrigin[2];
//
//        camera->Position[0] = camX;
//        camera->Position[1] = 0;
//        camera->Position[2] = camZ;
//        
//        camera->Front[0] = -camX;
//        camera->Front[1] = 0;
//        camera->Front[2] = -camZ;
        camera->setYaw(_camerYDegrees);
        camera->updateCameraVectors();
    }
    
}

- (void)tick:(id)sender {
    
    //1秒（30帧）360度
    float degress = 360.0f / 30.0f;
    
    //太阳自转
    self.sunRotationAngleDegrees += degress/25;
    
    //旋转一圈
    self.earthRotationAngleDegrees += degress/30;
    
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
    
    //长宽比
    float aspect = width / height;
    
    //1、投影矩阵
    //1.1、投影矩阵的构造
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    
    //1.2、透视变换，视角30°
    ksPerspective(&_projectionMatrix, 60, aspect, 1, 100.0f);
    //1.3、传递给着色器程序
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
//    //1、投影矩阵
//    //1.1、投影矩阵的构造
//    XSMatrix projectionMatrix = XSMatrix::identity();
//    //1.2、透视变换，视角30°
//    projectionMatrix.makePerspective(GLKMathDegreesToRadians(30), aspect, 5.0f, 20.0f);
//    //1.3、传递给着色器程序
//    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, &projectionMatrix.m[0]);
    
    
    //启用面剔除
    glEnable(GL_CULL_FACE);
    //深度测试
    glEnable(GL_DEPTH_TEST);
    
    //2.视图矩阵
//    KSMatrix4 _viewMatrix;
//    ksMatrixLoadIdentity(&_viewMatrix);
//    ksTranslate(&_viewMatrix, 0.0, 0.0, -15);
//    //换个视角看
//    ksRotate(&_viewMatrix, _camerYDegrees, 0.0, 1.0, 0.0);
    
//    float radius = 10.0f;
//    float camX = sin(glfwGetTime()) * radius;
//    float camZ = cos(glfwGetTime()) * radius;
    
    
    float eyeX = sin(_camerYDegrees) * 10, eyeY = 0.0, eyeZ = cos(_camerYDegrees) * 10;
    float centerX = 0.0f, centerY = 0, centerZ = 0.0f;
    float upX = 0.0f, upY = 1.0, upZ = 0.0f;
    
//    for (int i = 0; i < 3; i++) {
//        camera->Position[i] = camera->WorldUp[i] * currentSpeed * 0.01;
//    }
//    currentSpeed -= g;
//    if (currentSpeed <= -jumpSpeed) {
//        currentSpeed = 0;
//        camera->Position[1] -= camera->Position[1];
//    }
    
    
//    camera.Position += camera.WorldUp * (float)(currentSpeed * 0.01);
//    currentSpeed -= g;
//    if (currentSpeed <= -jumpSpeed) {
//        currentSpeed = 0;
//        jumping = false;
//        camera.Position -= glm::vec3(0.f,camera.Position.y,0.f);
//    }
   
    
    
    KSMatrix4 _viewMatrix = camera->getViewMatrix();
//    KSMatrix4 _viewMatrix;
//    ksMatrixLoadIdentity(&_viewMatrix);
//    ksTranslate(&_viewMatrix, 0.0, 0.0, -5);
    //换个视角看
//    ksRotate(&_viewMatrix, 90, 0.0, 1.0, 0.0);

//    ksLookAt(&_viewMatrix, eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
    glUniformMatrix4fv(viewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_viewMatrix.m[0][0]);
    
    //2.视图矩阵
//    XSMatrix viewMatrix = XSMatrix::identity();
//    //换个视角看
//    viewMatrix.applyRotateLeft(GLKMathDegreesToRadians(60), 0.0, 1.0, 0.0);
//    viewMatrix.applyTranslateLeft(0.0, 0.0, -10);
//    glUniformMatrix4fv(viewMatrixSlot, 1, GL_FALSE, (GLfloat*)&viewMatrix.m[0]);
    
    
    //3.模型矩阵
    //🌞太阳
    KSMatrix4 _sunMatrix;
    ksMatrixLoadIdentity(&_sunMatrix);
//    ksScale(&_sunMatrix, 1.5, 1.5, 1.5);
//    ksRotate(&_sunMatrix, self.sunRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&_sunMatrix.m[0][0]);
    glBindTexture(GL_TEXTURE_2D, sunTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //3.模型矩阵
    //🌞太阳
//    XSMatrix sunMatrix = XSMatrix::identity();
//    sunMatrix.applyScaleLeft(1.5, 1.5, 1.5);
//    sunMatrix.applyRotateLeft(GLKMathDegreesToRadians(self.sunRotationAngleDegrees), 1.0, 0.0, 0.0);
//    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&sunMatrix.m[0]);
//    glBindTexture(GL_TEXTURE_2D, sunTexture);
//    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //🌍地球
    KSMatrix4 _earthMatrix;
    ksMatrixLoadIdentity(&_earthMatrix);
    //公转
//    ksRotate(&_earthMatrix, self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    ksTranslate(&_earthMatrix, 0, 0, -2.0);
    ksScale(&_earthMatrix, 0.5, 0.5, 0.5);
    //自转
//    ksRotate(&_earthMatrix, self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&_earthMatrix.m[0][0]);
    glBindTexture(GL_TEXTURE_2D, earthTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //🌍地球
//    XSMatrix earthMatrix = XSMatrix::identity();
//    //公转
//    earthMatrix.applyRotateLeft(GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 1.0, 0.0, 0.0);
//    earthMatrix.applyTranslateLeft(0.0, 0.0, -2.0);
//    earthMatrix.applyScaleLeft(0.5, 0.5, 0.5);
//    //自转
//    earthMatrix.applyRotateLeft(GLKMathDegreesToRadians(self.earthRotationAngleDegrees), 1.0, 0.0, 0.0);
//    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&earthMatrix.m[0]);
//    glBindTexture(GL_TEXTURE_2D, earthTexture);
//    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);

    //🌕月球
    KSMatrix4 _moonMatrix = _earthMatrix;
    //公转
    ksRotate(&_moonMatrix, self.moonRotationAngleDegrees, 1.0, 0.0, 0.0);
    ksTranslate(&_moonMatrix, 0, 0.0, -0.7);
    ksScale(&_moonMatrix, 0.3, 0.3, 0.3);
    //自转，月球自转和公转周期非常接近
    ksRotate(&_moonMatrix, self.moonRotationAngleDegrees, 1.0, 0.0, 0.0);
    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&_moonMatrix.m[0][0]);
    glBindTexture(GL_TEXTURE_2D, moonTexture);
    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
    
    //🌕月球
//    XSMatrix moonMatrix = earthMatrix;
//    //公转
//    moonMatrix.applyRotateLeft(GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 1.0, 0.0, 0.0);
//    moonMatrix.applyTranslateLeft(0.0, 0.0, -1.0);
//    moonMatrix.applyScaleLeft(0.3, 0.3, 0.3);
//    //自转，月球自转和公转周期非常接近
//    moonMatrix.applyRotateLeft(GLKMathDegreesToRadians(self.moonRotationAngleDegrees), 1.0, 0.0, 0.0);
//    glUniformMatrix4fv(modelMatrixSlot, 1, GL_FALSE, (GLfloat*)&moonMatrix.m[0]);
//    glBindTexture(GL_TEXTURE_2D, moonTexture);
//    glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);

    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)compileAndLinkShader {
    
    //读取文件路径
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    //加载shader
    self.myProgram = [[ShaderUtils sharedInstance] loadShaders:vertFile frag:fragFile];
    
}

//- (void)compileAndLinkShader {
//    
//    //读取文件路径
//    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
//    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
//    
//    //加载shader
//    self.myProgram = ShaderTools::createShaderProgram([vertFile UTF8String], [fragFile UTF8String]);
//    glUseProgram(self.myProgram);
//}

- (void)dealloc {
    [myTimer invalidate];
    myTimer = nil;
}

@end
