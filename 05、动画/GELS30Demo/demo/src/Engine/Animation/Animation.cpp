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
    excuteIndex = 0;
    originScale = animTarget->getScale();
    originPosition = animTarget->getPosition();
    this->animTarget = animTarget;
}

void Animation::setKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame) {
    keyFrames.push_back(*keyFrame);
}

void Animation::startAnimation() {
    float time =  1.0 / 30.0;
    currentTime += time;
    index += 1;
    if (keyFrames.size() > 0 && excuteIndex < keyFrames.size()) {
        this->excuteAnimatio();
    }
}

void Animation::excuteAnimatio() {
    auto target =  this->animTarget.lock();
    float time =  1.0  / 30.0;
    KeyFrame keyFrame = this->keyFrames[excuteIndex];
    float keyTime = keyFrame.keyTime;
    XSVector3 preKeyScale = keyFrame.keyScale * 0.8;
    XSVector3 preKeyPosition = keyFrame.keyPosition;
    if (excuteIndex > 0) {
        keyTime = keyFrame.keyTime - this->keyFrames[excuteIndex - 1].keyTime;
        preKeyScale = this->keyFrames[excuteIndex - 1].keyScale - keyFrame.keyScale;
        preKeyPosition = this->keyFrames[excuteIndex - 1].keyPosition - keyFrame.keyPosition;
    }
    float zhe = keyTime / time;
    if (zhe == 0) { return; }
    XSVector3 keyFrameScale = preKeyScale / zhe;
    XSVector3 currentScale = target->getScale();
    if (currentTime <= keyFrame.keyTime) {
        XSVector3 preScale = originScale;
        if (excuteIndex > 0) {
            preScale = keyFrames[excuteIndex - 1].keyScale;
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
        if (excuteIndex > 0) {
            prePosition = keyFrames[excuteIndex - 1].keyPosition;
        }
        if (keyFrame.keyPosition.x > prePosition.x) {
            currentPosition = currentPosition + keyFramePosition;
        }else {
            currentPosition = currentPosition - keyFramePosition;
        }
        target->setPosition(currentPosition);
    }
    
    if (currentTime >= keyFrame.keyTime) {
        excuteIndex += 1;
    }
}

