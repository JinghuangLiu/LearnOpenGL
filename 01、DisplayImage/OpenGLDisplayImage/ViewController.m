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
    
    [self setupConfig];
    
    [self loadVertexArray];

    [self loadTexture];
    
}

- (void)setupConfig {
    self.mContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.mContext;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.delegate = self;
    
    [EAGLContext setCurrentContext:self.mContext];
}

- (void)loadVertexArray {
    ///前三个是顶点坐标(x,y,z)，后两个是纹理坐标(u,v)
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
    
    GLint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(squareVertexData), squareVertexData, GL_STATIC_DRAW);
    
    ///顶点数据缓存
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5, (GLfloat *)NULL + 0);
    
    ///纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *5, (GLfloat *)NULL + 3);
}

- (void)loadTexture {
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
