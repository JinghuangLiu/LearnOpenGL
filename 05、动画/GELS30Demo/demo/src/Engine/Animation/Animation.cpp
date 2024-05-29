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
        if (currentTime > keyFrames[keyFrames.size() - 1].keyTime * 1000) {
            auto target =  this->animTarget.lock();
            target->setScale(originScale);
            target->setPosition(originPosition);
            currentTime = 0;
            executeIndex = 0;
        }
    }
    
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
    /// 前一个关键帧缩放增量，默认当前关键帧
    XSVector3 preKeyScale = keyFrame.keyScale * 0.8;
    /// 前一个关键帧位置
    XSVector3 preKeyPosition = keyFrame.keyPosition;
    
    XSVector3 preKeyRotation = keyFrame.keyRotation;
    
    if (executeIndex > 0) {
        keyTime = (keyFrame.keyTime - this->keyFrames[executeIndex - 1].keyTime) * time;
        preKeyScale = this->keyFrames[executeIndex - 1].keyScale - keyFrame.keyScale;
        preKeyPosition = this->keyFrames[executeIndex - 1].keyPosition - keyFrame.keyPosition;
        preKeyRotation = this->keyFrames[executeIndex - 1].keyRotation - keyFrame.keyRotation;
    }
    
    /// 每毫秒帧缩放值
    XSVector3 keyFrameScale = preKeyScale / keyTime;
    /// 物体当前缩放
    XSVector3 currentScale = target->getScale();
    /// 判断是否在当前关键帧内
    if (currentTime <= keyFrame.keyTime * time) {
        XSVector3 preScale = originScale;
        if (executeIndex > 0) {
            preScale = keyFrames[executeIndex - 1].keyScale;
        }
        /// 当前关键帧大于上一个关键帧则是放大，否值是缩小
        if (keyFrame.keyScale.x > preScale.x) {
            currentScale = currentScale + keyFrameScale;
            if (currentScale.x >= keyFrame.keyScale.x) {
                currentScale = keyFrame.keyScale;
            }
        }else {
            currentScale = currentScale - keyFrameScale;
            if (currentScale.x <= keyFrame.keyScale.x) {
                currentScale = keyFrame.keyScale;
            }
        }
        target->setScale(currentScale);
    }
    
    XSVector3 keyFramePosition =  preKeyPosition / keyTime;
    XSVector3 currentPosition = target->getPosition();
    if (currentTime <= keyFrame.keyTime * time) {
        XSVector3 prePosition = originPosition;
        if (executeIndex > 0) {
            prePosition = keyFrames[executeIndex - 1].keyPosition;
        }
        if (keyFrame.keyPosition.x > prePosition.x) {
            currentPosition = currentPosition + keyFramePosition;
        }else {
            currentPosition = currentPosition - keyFramePosition;
        }
        target->setPosition(currentPosition);
    }
    
    XSVector3 keyFrameRotation =  preKeyRotation / keyTime;
    XSVector3 currentRotation = target->getRotation();
    if (currentTime <= keyFrame.keyTime * time) {
        XSVector3 preRotation = originRotation;
        if (executeIndex > 0) {
            preRotation = keyFrames[executeIndex - 1].keyRotation;
        }
        if (keyFrame.keyRotation.y > preRotation.y) {
            currentRotation.y = currentRotation.y + keyFrameRotation.y;
        }else {
            currentRotation.y = currentRotation.y - keyFrameRotation.y;
        }
        target->setRotation(currentRotation);
    }
    
    /// 时间大于关键帧时间则下标+1
    if (currentTime >= keyFrame.keyTime * time) {
        executeIndex += 1;
    }
}

