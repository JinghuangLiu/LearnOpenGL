//
//  AnimationManager.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#ifndef AnimationManager_hpp
#define AnimationManager_hpp

#include <stdio.h>
#include <vector>
#include "Animation.h"

using namespace std;

class AnimationManager
{
public:
    void addAnimaton(shared_ptr<Animation>& anim);
    void loopOnce(float deltaTime); //动画总的驱动入口
private:
    vector<shared_ptr<Animation>> animations;
};


#endif /* AnimationManager_hpp */
