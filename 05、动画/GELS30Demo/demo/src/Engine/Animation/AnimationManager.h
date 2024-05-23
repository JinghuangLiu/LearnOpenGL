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
#import <Foundation/Foundation.h>
#include "Animation.h"

using namespace std;

@interface AnimationManager : NSObject {
    vector<shared_ptr<Animation>> animations;
}
    
    
- (void)addAnimaton:(shared_ptr<Animation>&)anim;
    
- (void)loopOnce:(float)deltaTime; //动画总的驱动入口

    


@end

#endif /* AnimationManager_hpp */
