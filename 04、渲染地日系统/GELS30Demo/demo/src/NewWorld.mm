//
//  NewWorld.m
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import "NewWorld.h"
#import <UIKit/UIKit.h>

GLubyte* NewWorld::loadImage(NSString *fileName) {
    
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

void NewWorld::Begin() {
    
    int width = this->width;
    int height = this->height;
    
    //创建一个地球纹理材质
    auto earthMaterial = std::make_shared<Material>("shaderv.vsh","shaderf.fsh",loadImage(@"Earth512x256.jpg"),width,height);
    
    //创建一个太阳纹理材质
    auto sunMaterial = std::make_shared<Material>(
            "shaderv.vsh",
            "shaderf.fsh",
                                                  loadImage(@"sun.jpg"),width,height);

    //创建一个月球纹理材质
    auto moonMaterial = std::make_shared<Material>(
            "shaderv.vsh",
            "shaderf.fsh",
                                                   loadImage(@"Moon256x128.jpg"),width,height);

    sunObj = std::make_shared<Sphere>(0.5f, sunMaterial);
    earthObj = std::make_shared<Sphere>(0.2f, earthMaterial);
    moonObj = std::make_shared<Sphere>(0.1f, moonMaterial);
    
    //将太阳加入到世界中
    addChild(sunObj);
    //将地球加入到太阳的child层级里
    sunObj->addChild(earthObj);
    //将月亮加入到地球的child层级里
    earthObj->addChild(moonObj);

    //太阳设置在原点
    sunObj->setPosition(XSVector3(0.0f, 0.0f, 0.0f));
    //地球相对太阳在X轴的偏移量
    earthObj->setPosition(XSVector3(1.5f, 0.0f, 0.0f));
    //设置月球相对地球在X轴的偏移量
    moonObj->setPosition(XSVector3(0.5f, 0.0f, 0.0f));


    //测试加多个立方体

//    cubeObj = std::make_shared<Cube>(1.0f, sunMaterial);
//    cubeObj->setPosition(XSVector3(0.0f, 3.0f, 0.0f));
//    addChild(cubeObj);
//
//    std::shared_ptr<Object3D> cubeSubObj = std::make_shared<Cube>(0.5f, earthMaterial);
//    cubeSubObj->setPosition(XSVector3(1.0f, 0.0f, 0.0f));
//    cubeObj->addChild(cubeSubObj);


    Object3D::Begin();
}

void NewWorld::LoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    this->cycleAccumulator += 0.01f;


    //太阳自转 在原点绕着Y轴旋转  速度设置慢一点
    XSVector3 temp = this->sunObj->getRotation();
    temp.y += 0.05f;
    this->sunObj->setRotation(temp);

    //地球自转 在原点绕着Y轴旋转 速度
    //如果不设置，由于地球也继承了太阳的矩阵，自身又有偏移量。地球在原点旋转，地球也会做旋转（绕地球）
    temp = this->earthObj->getRotation();
    temp.y += 0.1f;
    this->earthObj->setRotation(temp);

    //月亮自转 在原点绕着Y轴旋转 速度
    temp = this->moonObj->getRotation();
    temp.x += 0.2f;
    this->moonObj->setRotation(temp);

    //this->cubeObj->setRotation(this->cycleAccumulator * 360.0f, XSVector3(0.0f, 1.0f, 0.0f));

    Object3D::LoopOnce(proj, cam, parent);

}

void NewWorld::End() {
    Object3D::End();
}


