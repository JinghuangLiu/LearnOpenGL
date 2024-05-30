//
//  NewScene.m
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import "NewScene.h"
#import <UIKit/UIKit.h>
#include "AnimationManager.h"

// Objective-C++实现
class NewScene::AnimationManagerImpl {
public:
    AnimationManagerImpl() : objcObject([[AnimationManager alloc] init]) {}
    ~AnimationManagerImpl() {  }
    
    void addAnimaton(shared_ptr<Animation> &animate) {
        [objcObject addAnimaton:animate];
    }
    
    void startAnimation(float deltaTime) {
        [objcObject loopOnce:deltaTime];
    }

private:
    AnimationManager *objcObject;
};

NewScene::NewScene() : animationManagerImpl(new AnimationManagerImpl()) {
    
}

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
    //将地球加入到太阳的层级里
    sunObj->addComponent(earthObj);
    //将月亮加入到地球的层级
    earthObj->addComponent(moonObj);

    //太阳设置在原点
    sunObj->setPosition(XSVector3(0.0f, 0.0f, 0.0f));
    //地球相对太阳在X轴的偏移量
    earthObj->setPosition(XSVector3(1.5f, 0.0f, 0.0f));
    //设置月球相对地球在X轴的偏移量
    moonObj->setPosition(XSVector3(0.5f, 0.0f, 0.0f));

//    //测试加多个立方体
//    cubeObj = make_shared<Cube>(1.0f, sunMaterial);
//    cubeObj->setPosition(XSVector3(0.0f, 3.0f, 0.0f));
//    addComponent(cubeObj);
//    
//    shared_ptr<Object3D> cubeSubObj = make_shared<Cube>(0.5f, earthMaterial);
//    cubeSubObj->setPosition(XSVector3(1.0f, 0.0f, 0.0f));
//    cubeObj->addComponent(cubeSubObj);

    Object3D::Begin();
}

void NewScene::Loop(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    this->cycleAccumulator += 0.01f;

    //太阳自转，在原点绕着Y轴旋转
//    XSVector3 temp = this->sunObj->getRotation();
//    temp.y += 0.05f;
//    this->sunObj->setRotation(temp);

    //地球自转，在原点绕着Y轴旋转
    //如果不设置，由于地球也继承了太阳的矩阵，自身又有偏移量。地球在原点旋转，地球也会做旋转（绕地球）
//    temp = this->earthObj->getRotation();
//    temp.y += 0.1f;
//    this->earthObj->setRotation(temp);

    //月亮自转，在原点绕着Y轴旋转
//    temp = this->moonObj->getRotation();
//    temp.x += 0.2f;
//    this->moonObj->setRotation(temp);

    Object3D::RecursiveLoop(proj, cam, parent);

}

void NewScene::End() {
    Object3D::End();
}


void NewScene::addAnimation() {
    
    //1、🌞创建太阳的动画
    shared_ptr<Animation> sunAnimation = make_shared<Animation>(sunObj);
    sunAnimation->isLoopMode = true;
    //添加关键帧
    shared_ptr<KeyFrame> sunKF = make_shared<KeyFrame>();
    sunKF->keyScale = XSVector3(1.0f, 1.0f, 1.0f);
    sunKF->keyPosition = sunObj->getPosition();
    sunKF->keyTime = 10000;
    sunKF->keyRotation = XSVector3(0.0f, 360.0 * M_PI / 180.0, 0.0f);
    sunAnimation->addKeyFrame(sunKF);
    //添加关键帧
//    shared_ptr<KeyFrame> sunSecondKF = make_shared<KeyFrame>();
//    sunSecondKF->keyScale = XSVector3(1.0f, 1.0f, 1.0f);
//    sunSecondKF->keyTime = 10;
//    sunSecondKF->keyRotation = XSVector3(0.0f, 0, 0.0f);
//    sunSecondKF->keyPosition = sunObj->getPosition();
//    sunAnimation->addKeyFrame(sunSecondKF);
    //添加动画
    animationManagerImpl->addAnimaton(sunAnimation);
    
    //2、🌍创建地球的动画
    shared_ptr<Animation> earthAnimation = make_shared<Animation>(earthObj);
    earthAnimation->isLoopMode = true;
    //添加关键帧
    shared_ptr<KeyFrame> earthKF = make_shared<KeyFrame>();
    earthKF->keyScale = XSVector3(1.0f, 1.0f, 1.0f);
    earthKF->keyTime = 10000;
    earthKF->keyPosition = earthObj->getPosition();
    earthKF->keyRotation = XSVector3(0.0f, 5*360.0 * M_PI / 180.0, 0.0f);
    earthAnimation->addKeyFrame(earthKF);
    animationManagerImpl->addAnimaton(earthAnimation);
    
    //3、🌕创建月球的动画
    shared_ptr<Animation> moonAnimation = make_shared<Animation>(moonObj);
    moonAnimation->isLoopMode = true;
    //添加关键帧
    shared_ptr<KeyFrame> moonKF = make_shared<KeyFrame>();
    moonKF->keyScale = XSVector3(1.0f, 1.0f, 1.0f);
    moonKF->keyTime = 10000;
    moonKF->keyPosition = moonObj->getPosition();
    moonKF->keyRotation = XSVector3(0.0f, 360.0 * M_PI / 180.0, 0.0f);
    moonAnimation->addKeyFrame(moonKF);
    animationManagerImpl->addAnimaton(moonAnimation);
}

void NewScene::startAnimation() {
    //开始动画
    animationManagerImpl->startAnimation(1/1000.0);
}
