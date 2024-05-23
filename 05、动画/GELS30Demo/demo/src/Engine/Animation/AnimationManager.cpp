//
//  AnimationManager.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#include "AnimationManager.h"

void AnimationManager::addAnimaton(std::shared_ptr<Animation>& anim) {
    this->animations.push_back(anim);
}

void AnimationManager::loopOnce(float deltaTime) {
    
}
