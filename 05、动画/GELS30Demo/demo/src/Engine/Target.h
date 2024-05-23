//
//  Target.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/23.
//

#ifndef Target_h
#define Target_h

#include "XSMatrix.h"
using namespace xscore;

// 定义接口类
class ITarget {
public:
    // 纯虚函数
    virtual void setPosition(const XSVector3 &mPosition) = 0;
    virtual void setRotation(const XSVector3 &mRotation) = 0;
    virtual void setScale(const XSVector3 &mScale) = 0;
};

#endif /* Target_h */
