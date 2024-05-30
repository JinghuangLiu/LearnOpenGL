//
//  Animation.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#include "Animation.h"
#include <ctime>

Animation::Animation(const std::shared_ptr<Object3D> &animTarget) {
    //初始值
    currentTime = 0;
    executeIndex = 0;
    isLoopMode = false;
    originScale = animTarget->getScale();
    originPosition = animTarget->getPosition();
    originRotation = animTarget->getRotation();
    this->animTarget = animTarget;
}

void Animation::addKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame) {
    keyFrames.push_back(*keyFrame);
}

void printTime() {
    // 获取当前时间点
    std::time_t now = std::time(nullptr);
    
    // 转换为本地时间
    std::tm* localTime = std::localtime(&now);
    
    // 打印本地时间
    std::cout << "Current local time: "
              << (localTime->tm_year + 1900) << '-'
              << (localTime->tm_mon + 1) << '-'
              << localTime->tm_mday << ' '
              << localTime->tm_hour << ':'
              << localTime->tm_min << ':'
              << localTime->tm_sec
              << std::endl;
}

void Animation::startAnimation() {
    
    printTime();
    
    currentTime += 1;
    if (this->isLoopMode) {
        //如果当前时间大于最后一个关键帧时间则恢复初始值
        if (currentTime > keyFrames[keyFrames.size() - 1].keyTime) {
            std::shared_ptr<Object3D> target = this->animTarget.lock();
            target->setScale(originScale);
            target->setPosition(originPosition);
            target->setRotation(originRotation);
            currentTime = 0;
            executeIndex = 0;
        }
    }
    
    //有关键帧且还在关键帧数组范围内，则执行动画
    if (keyFrames.size() > 0 && executeIndex < keyFrames.size()) {
        this->executeAnimation();
    }
}

void Animation::executeAnimation() {
    
    auto target = this->animTarget.lock();
    
    //1、获取当前关键帧
    KeyFrame keyFrame = this->keyFrames[executeIndex];
    float keyTime = keyFrame.keyTime;
    if (keyTime <= 0) {
        return;
    }
    
    //2、计算关键帧缩放、位置、旋转值增量
    XSVector3 additionKeyScale;
    XSVector3 additionKeyPosition;
    XSVector3 additionKeyRotation;
    if (executeIndex > 0) {
        //不是第一个关键帧：当前关键帧减去上一个关键帧，计算两关键帧之间的增量
        keyTime = (keyFrame.keyTime - this->keyFrames[executeIndex - 1].keyTime);
        additionKeyScale = keyFrame.keyScale - this->keyFrames[executeIndex - 1].keyScale;
        additionKeyPosition = keyFrame.keyPosition - this->keyFrames[executeIndex - 1].keyPosition;
        additionKeyRotation = keyFrame.keyRotation - this->keyFrames[executeIndex - 1].keyRotation;
    } else {
        //第一个关键帧：相对初始值的增量
        additionKeyScale = keyFrame.keyScale - originScale;
        additionKeyPosition = keyFrame.keyPosition - originPosition;
        additionKeyRotation = keyFrame.keyRotation - originRotation;
    }
    
    //3、把缩放、位置、旋转的原始值加上增值，赋给接口
    //3.1、缩放
    //每毫秒的缩放增值
    XSVector3 keyFrameScale = additionKeyScale / keyTime;
    //物体当前缩放
    XSVector3 currentScale = target->getScale();
    //判断是否在当前关键帧内
    if (currentTime <= keyFrame.keyTime) {
        //当前的量=原来的量+增量
        currentScale = currentScale + keyFrameScale;
        //设置给接口
        target->setScale(currentScale);
    }
    
    //3.2、旋转
    //每毫秒的旋转增值
    XSVector3 keyFrameRotation =  additionKeyRotation / keyTime;
    XSVector3 currentRotation = target->getRotation();
    if (currentTime <= keyFrame.keyTime) {
        currentRotation.y = currentRotation.y + keyFrameRotation.y;
        //设置给接口
        target->setRotation(currentRotation);
    }
    
    //3.3、位置
    //每毫秒的位置增值
    XSVector3 keyFramePosition =  additionKeyPosition / keyTime;
    XSVector3 currentPosition = target->getPosition();
    if (currentTime <= keyFrame.keyTime) {
        currentPosition = currentPosition + keyFramePosition;
        //设置给接口
        target->setPosition(currentPosition);
    }
    
    //当时间大于关键帧时间，则下标+1，进入下一个关键帧
    if (currentTime >= keyFrame.keyTime) {
        executeIndex += 1;
    }
}

