//
//  Animation.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#include "Animation.h"

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

void Animation::startAnimation() {
    currentTime += 1;
    if (this->isLoopMode) {
        //如果当前时间大于最后一个关键帧时间则恢复初始值
        if (currentTime > keyFrames[keyFrames.size() - 1].keyTime * 1000) {
            auto target =  this->animTarget.lock();
            target->setScale(originScale);
            target->setPosition(originPosition);
            target->setPosition(originRotation);
            currentTime = 0;
            executeIndex = 0;
        }
    }
    
    //有关键帧则执行动画
    if (keyFrames.size() > 0 && executeIndex < keyFrames.size()) {
        this->executeAnimation();
    }
}

void Animation::executeAnimation() {
    auto target =  this->animTarget.lock();
    float time = 1000.0;
    // 获取当前关键帧
    KeyFrame keyFrame = this->keyFrames[executeIndex];
    /// 转化关键帧时间为毫秒
    float keyTime = keyFrame.keyTime * time;
    
    /// 第一个关键帧缩放值总增量
    XSVector3 additionKeyScale = keyFrame.keyScale - originScale;
    /// 第一个关键帧位移值总增量
    XSVector3 additionKeyPosition = keyFrame.keyPosition - originPosition;
    /// 第一个关键帧旋转值总增量
    XSVector3 additionKeyRotation = keyFrame.keyRotation - originRotation;
    
    
    /// 非第一个关键帧，则当前关键帧减去上一个关键帧计算出差值
    if (executeIndex > 0) {
        keyTime = (keyFrame.keyTime - this->keyFrames[executeIndex - 1].keyTime) * time;
        additionKeyScale = keyFrame.keyScale - this->keyFrames[executeIndex - 1].keyScale;
        additionKeyPosition = keyFrame.keyPosition - this->keyFrames[executeIndex - 1].keyPosition;
        additionKeyRotation = keyFrame.keyRotation - this->keyFrames[executeIndex - 1].keyRotation;
    }
    
    /// 角度往同一个方向旋转
    if (additionKeyRotation.y < 0) {
        additionKeyRotation.y = -additionKeyRotation.y;
    }
    /// 关键帧时间小于0 则返回
    if (keyTime <= 0) {
        return;
    }
    
    /// 每毫秒帧缩放值
    XSVector3 keyFrameScale = additionKeyScale / keyTime;
    /// 物体当前缩放
    XSVector3 currentScale = target->getScale();
    /// 判断是否在当前关键帧内
    if (currentTime <= keyFrame.keyTime * time) {
        currentScale = currentScale + keyFrameScale;
        target->setScale(currentScale);
    }
    
    XSVector3 keyFrameRotation =  additionKeyRotation / keyTime;
    XSVector3 currentRotation = target->getRotation();
    if (currentTime <= keyFrame.keyTime * time) {
        currentRotation.y = currentRotation.y + keyFrameRotation.y;
        target->setRotation(currentRotation);
    }
    
    XSVector3 keyFramePosition =  additionKeyPosition / keyTime;
    XSVector3 currentPosition = target->getPosition();
    if (currentTime <= keyFrame.keyTime * time) {
        currentPosition = currentPosition + keyFramePosition;
        target->setPosition(currentPosition);
    }
    
    /// 时间大于关键帧时间则下标+1
    if (currentTime >= keyFrame.keyTime * time) {
        executeIndex += 1;
    }
}

