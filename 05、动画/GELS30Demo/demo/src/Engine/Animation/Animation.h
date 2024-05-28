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
    
    //关键帧
    std::vector<KeyFrame> keyFrames;
    
    //作用对象
    std::weak_ptr<Object3D> animTarget;
    
    //是否循环
    bool  isLoopMode;
    
    //设置关键帧
    void addKeyFrame(const std::shared_ptr<KeyFrame>& keyFrame);
    
    //添加关键帧
    void startAnimation();
    
private:
    //初始比例
    XSVector3 originScale;
    //初始位置
    XSVector3 originPosition;
    ///初始位置
    XSVector3 originRotation;
    /// 当前时长毫秒
    float currentTime;
    /// 当前执行关键帧下标
    int executeIndex;
    /// 执行动画
    void executeAnimation();
};

#endif /* Animation_hpp */
