//
//  ViewController.m
//  OpenGLDisplayImage
//
//  Created by 刘靖煌 on 2021/2/26.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *mContext;
@property (nonatomic, strong) GLKBaseEffect* mEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupContextAndRenderView];
    
    [self loadVertexArray];

    [self loadTexture];
    
}

- (void)setupContextAndRenderView {
    
    //新建OpenGLES上下文
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; //还有ES1、ES2

    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888; //颜色缓冲区格式
    view.delegate = self;
    
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)loadVertexArray {
    //前三个是顶点坐标(x,y,z)，后两个是纹理坐标(u,v)
    //顶点数组里包括顶点坐标，OpenGLES的世界坐标系是[-1, 1]，故而点(0, 0)是在屏幕的正中间。
    //纹理坐标系的取值范围是[0, 1]，原点是在左下角。故而点(0, 0)在左下角，点(1, 1)在右上角。
    GLfloat squareVertexData[] = {
        //右下
        0.8f, -0.25f, 0.0f, 1.0f, 0.0f,
        
        //右上
        0.8f, 0.25f, 0.0f, 1.0f, 1.0f,
        
        //左上
        -0.8f, 0.25f, 0.0f, 0.0f, 1.0f,
        
        //右下
        0.8f, -0.25f, 0.0f, 1.0f, 0.0f,
        
        //左上
        -0.8f, 0.25f, 0.0f, 0.0f, 1.0f,
        
        //左下
        -0.8f, -0.25f, 0.0f, 0.0f, -1.0f
    };
    
    //顶点数据缓存
    GLuint buffer;
    //申请一个标识符
    glGenBuffers(1, &buffer);
    //把标识符绑定到GL_ARRAY_BUFFER上
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    //把顶点数据从cpu内存复制到gpu内存
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    ///开启对应的顶点属性
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置合适的格式从buffer里面读取数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5, (GLfloat *)NULL + 0);
    
    ///纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5, (GLfloat *)NULL + 3);
}

- (void)loadTexture {
    //纹理贴图
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"gene" ofType:@"jpg"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    //着色器
    self.mEffect = [[GLKBaseEffect alloc] init];
    self.mEffect.texture2d0.enabled = GL_TRUE;
    self.mEffect.texture2d0.name = textureInfo.name;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.3f, 0.6f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启动着色器
    [self.mEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}


@end
