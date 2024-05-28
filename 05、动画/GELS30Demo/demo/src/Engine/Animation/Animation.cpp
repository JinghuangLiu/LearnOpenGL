//
//  Animation.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#include "Animation.h"

Animation::Animation(const std::shared_ptr<Object3D> &animTarget) {
    currentTime = 0;
    index = 0;
    executeIndex = 0;
    isLoopMode = false;
    originScale = animTarget->getScale();
    originPosition = animTarget->getPosition();
    this->animTarget = animTarget;
}

void Animation::addKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame) {
    keyFrames.push_back(*keyFrame);
}

void Animation::startAnimation() {
    float time =  1.0 / 30.0;
    currentTime += time;
    index += 1;
    
    if (this->isLoopMode) {
        if (currentTime > keyFrames[keyFrames.size() - 1].keyTime) {
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
    float time =  1.0  / 30.0;
    KeyFrame keyFrame = this->keyFrames[executeIndex];
    float keyTime = keyFrame.keyTime;
    XSVector3 preKeyScale = keyFrame.keyScale * 0.8;
    XSVector3 preKeyPosition = keyFrame.keyPosition;
    if (executeIndex > 0) {
        keyTime = keyFrame.keyTime - this->keyFrames[executeIndex - 1].keyTime;
        preKeyScale = this->keyFrames[executeIndex - 1].keyScale - keyFrame.keyScale;
        preKeyPosition = this->keyFrames[executeIndex - 1].keyPosition - keyFrame.keyPosition;
    }
    float zhe = keyTime / time;
    if (zhe == 0) { return; }
    XSVector3 keyFrameScale = preKeyScale / zhe;
    XSVector3 currentScale = target->getScale();
    if (currentTime <= keyFrame.keyTime) {
        XSVector3 preScale = originScale;
        if (executeIndex > 0) {
            preScale = keyFrames[executeIndex - 1].keyScale;
        }
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
    
    XSVector3 keyFramePosition =  preKeyPosition / zhe;
    XSVector3 currentPosition = target->getPosition();
    if (currentTime <= keyFrame.keyTime) {
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
    
    if (currentTime >= keyFrame.keyTime) {
        executeIndex += 1;
    }
}

