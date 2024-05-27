//
//  Animation.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#ifndef Animation_hpp
#define Animation_hpp

#include <stdio.h>
#include <vector>

#include "KeyFrame.h"
#include "Target.h"
#include "Object3D.h"
class Animation
{
public:
    Animation(const std::shared_ptr<Object3D> &animTarget);
    std::vector<KeyFrame>  keyFrames;
    std::weak_ptr<Object3D>   animTarget;
    bool  isLoopMode;
    void setKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame);
    void startAnimation();
    
private:
    XSVector3 originScale;
    XSVector3 originPosition;
    float currentTime;
    int excuteIndex;
    int index;
    void excuteAnimatio();
};

#endif /* Animation_hpp */
