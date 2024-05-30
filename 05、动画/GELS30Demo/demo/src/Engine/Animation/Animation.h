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
    
    //关键帧数组
    std::vector<KeyFrame> keyFrames;

    //作用对象
    std::weak_ptr<Object3D> animTarget;
    
    //是否循环
    bool isLoopMode;
    
    //添加关键帧
    void addKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame);
    
    //开始执行动画
    void startAnimation();
    
private:
    //初始比例、位置、旋转值
    XSVector3 originScale;
    XSVector3 originPosition;
    XSVector3 originRotation;
    
    //当前时长（毫秒）
    float currentTime;
    //当前执行关键帧下标
    int executeIndex;
    //执行动画
    void executeAnimation();
};

#endif /* Animation_hpp */
