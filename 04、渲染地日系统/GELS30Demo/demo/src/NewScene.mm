//
//  NewScene.m
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import "NewScene.h"
#import <UIKit/UIKit.h>

GLubyte* NewScene::loadImage(NSString *fileName) {
    
    //加载图片
    CGImageRef imageRef = [UIImage imageNamed:fileName].CGImage;
    if (!imageRef) {
        exit(1);
    }
    size_t width = 512;
    size_t height = 256;
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba共4个byte
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
    this->width = width;
    this->height = height;
    
    //在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(spriteContext);
    
    return spriteData;
}

void NewScene::Begin() {
    
    string engineV = [[[NSBundle mainBundle] pathForResource:@"engine.vsh" ofType:nil] UTF8String];
    
    string engineF = [[[NSBundle mainBundle] pathForResource:@"engine.fsh" ofType:nil] UTF8String];
    
    //创建一个太阳纹理材质
    auto sunMaterial = std::make_shared<Material>(engineV,engineF,loadImage(@"sun.jpg"),width,height);
    
    //创建一个地球纹理材质
    auto earthMaterial = std::make_shared<Material>(engineV,engineF,loadImage(@"Earth512x256.jpg"),width,height);

    //创建一个月球纹理材质
    auto moonMaterial = std::make_shared<Material>(engineV,engineF,loadImage(@"moon.jpg"),width,height);

    sunObj = std::make_shared<Sphere>(0.5f, sunMaterial);
    earthObj = std::make_shared<Sphere>(0.2f, earthMaterial);
    moonObj = std::make_shared<Sphere>(0.1f, moonMaterial);
    
    //将太阳加入场景中
    addComponent(sunObj);
    //太阳设置在原点
    sunObj->setPosition(XSVector3(0.0f, 0.0f, 0.0f));

    
    //将地球加入到太阳的层级里
    sunObj->addComponent(earthObj);
    //地球相对太阳在X轴的偏移量
    earthObj->setPosition(XSVector3(1.5f, 0.0f, 0.0f));
    
    
    //将月亮加入到地球的层级
    earthObj->addComponent(moonObj);
    //设置月球相对地球在X轴的偏移量
    moonObj->setPosition(XSVector3(0.5f, 0.0f, 0.0f));
    

    //测试加多个立方体
    cubeObj = make_shared<Cube>(1.0f, sunMaterial);
    cubeObj->setPosition(XSVector3(0.0f, 3.0f, 0.0f));
    addComponent(cubeObj);
    
    shared_ptr<Object3D> cubeSubObj = make_shared<Cube>(0.5f, earthMaterial);
    cubeSubObj->setPosition(XSVector3(1.0f, 0.0f, 0.0f));
    cubeObj->addComponent(cubeSubObj);

    Object3D::Begin();
}

void NewScene::Loop(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    this->cycleAccumulator += 0.01f;

    //太阳自转，在原点绕着Y轴旋转
    XSVector3 temp = this->sunObj->getRotation();
    temp.y += 0.005f;
    this->sunObj->setRotation(temp);

    //地球自转，在原点绕着Y轴旋转
    //如果不设置，由于地球也继承了太阳的矩阵，自身又有偏移量。地球在原点旋转，地球也会做旋转（绕地球）
    temp = this->earthObj->getRotation();
    temp.y += 0.01f;
    this->earthObj->setRotation(temp);

    //月亮自转，在原点绕着Y轴旋转
    temp = this->moonObj->getRotation();
    temp.x += 0.02f;
    this->moonObj->setRotation(temp);

    Object3D::RecursiveLoop(proj, cam, parent);

}

void NewScene::End() {
    Object3D::End();
}


