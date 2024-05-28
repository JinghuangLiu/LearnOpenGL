//
//  KeyFrame.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#ifndef KeyFrame_hpp
#define KeyFrame_hpp

#include <stdio.h>
#include "XSMatrix.h"

using namespace xscore;

struct KeyFrame
{
    /// 关键帧时间秒
    float keyTime;
    XSVector3  keyPosition;
    XSVector3  keyRotation;
    XSVector3  keyScale;
};

#endif /* KeyFrame_hpp */
