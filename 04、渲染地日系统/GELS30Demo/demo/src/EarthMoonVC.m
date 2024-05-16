//
//  EarthMoonVC.m
//  demo
//
//  Created by empty on 2024/5/6.
//

#import "EarthMoonVC.h"
#import "GLESUtils.h"
#import "GLESMath.h"
#import "ball.h"
@interface EarthMoonVC ()

@property (nonatomic) GLfloat sunRotationAngleDegrees;

@property (nonatomic) GLfloat earthRotationAngleDegrees;

@property (nonatomic) GLfloat moonRotationAngleDegrees;

@end

@implementation EarthMoonVC {
    GLuint attrVertBuffer;
    GLuint ballNormalBuffer;
    GLuint attrTextureBuffer;
    GLuint sunTexture;
    GLuint earthTexture;
    NSTimer *myTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString* vertFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString* fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    [self compileAndLinkShader:vertFile fragFile:fragFile];
    [self setupVBO];
    [self setupTexture:@"sun.jpg" textTure:&sunTexture];
    [self setupTexture:@"Earth512x256.jpg" textTure:&earthTexture];
    [self renderLayer];
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
    self.earthRotationAngleDegrees += degress/30;
    
    //旋转一圈/月亮周期
    self.moonRotationAngleDegrees += degress / 28;
    
    [self renderLayer];
}

- (void)setupVBO {
   
    glGenBuffers(1, &attrVertBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrVertBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ballVerts), ballVerts, GL_DYNAMIC_DRAW);
    
    //法向量
    glGenBuffers(1, &ballNormalBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, ballNormalBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ballNormals), ballNormals, GL_DYNAMIC_DRAW);
    
    //纹理坐标
    glGenBuffers(1, &attrTextureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ballTexCoords), ballTexCoords, GL_DYNAMIC_DRAW);
    
    glEnable(GL_DEPTH_TEST);
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
    
    CGFloat scale = 1; //获取视图放大倍数，可以把scale设置为1试试
    glViewport(self.view.frame.origin.x * scale,
               self.view.frame.origin.y * scale,
               self.view.frame.size.width * scale,
               self.view.frame.size.height * scale); //设置视口大小
    
    //使用着色器
//    glUseProgram(self.myProgram);
    
    glBindBuffer(GL_ARRAY_BUFFER, attrVertBuffer);
    GLuint position = glGetAttribLocation(self.myProgram, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, attrTextureBuffer);
    GLuint textCoor = glGetAttribLocation(self.myProgram, "textCoordinate");
    glEnableVertexAttribArray(textCoor);
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, 0);
    
    
    GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
    
    GLuint view = glGetUniformLocation(self.myProgram, "view");
    
    GLuint model = glGetUniformLocation(self.myProgram, "model");
    
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    

    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width / height; //长宽比
    
    ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f); //透视变换，视角30°
    
    //设置glsl里面的投影矩阵
    glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
    
    glEnable(GL_CULL_FACE);
    
    
    KSMatrix4 viewMatrix;
    ksMatrixLoadIdentity(&viewMatrix);
    ksTranslate(&viewMatrix, 0.5, 0.5, -5);
    
//    float eyeX = 1.0f, eyeY = -1.0f, eyeZ = 5.0f;
//    float centerX = 0.0f, centerY = 0.0f, centerZ = 0.0f;
//    float upX = 0.0f, upY = 1.0f, upZ = 5.0f;

//    KSMatrix4 viewMatrix;
//    ksMatrixLoadIdentity(&viewMatrix);
//    ksLookAt(&viewMatrix, eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
    
    // Load the view matrix
    glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat*)&viewMatrix.m[0][0]);
    
    
    KSMatrix4 modelMatrix;
    ksMatrixLoadIdentity(&modelMatrix);
    ksScale(&modelMatrix, 1.5, 1.5, 1.5);
    ksRotate(&modelMatrix, self.sunRotationAngleDegrees, 1.0, 0.0, 0.0);
    // Load the model matrix
    glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat*)&modelMatrix.m[0][0]);
    glBindTexture(GL_TEXTURE_2D, sunTexture);
    glDrawArrays(GL_TRIANGLES, 0, ballNumVerts);
    
    
    KSMatrix4 earthMatrix;
    ksMatrixLoadIdentity(&earthMatrix);
//    ksRotate(&earthMatrix, self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    ksTranslate(&earthMatrix, 0, 0, -2);
    ksScale(&earthMatrix, 0.3, 0.3, 0.3);
    //自转
//    ksRotate(&earthMatrix, self.earthRotationAngleDegrees, 1.0, 0.0, 0.0);
    // Load the model matrix
    glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat*)&earthMatrix.m[0][0]);
    glBindTexture(GL_TEXTURE_2D, earthTexture);
    glDrawArrays(GL_TRIANGLES, 0, ballNumVerts);
    
    
    [self.mContext presentRenderbuffer:GL_RENDERBUFFER];
}


@end
