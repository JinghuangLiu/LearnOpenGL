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

class Animation
{
    std::vector<KeyFrame>  keyFrames;
    std::weak_ptr<ITarget>   animTarget;
    bool  isLoopMode;
    
};

#endif /* Animation_hpp */
