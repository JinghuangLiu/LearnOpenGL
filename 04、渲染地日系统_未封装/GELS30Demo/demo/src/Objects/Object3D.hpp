//
//  Object3D.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Object3D_hpp
#define Object3D_hpp

#include <stdio.h>
#include <iostream>
#include "XSMatrix.h"
using namespace xscore;

class Object3D
{
    //返回当前这一级模型的变换矩阵。
    XSMatrix mObjMatrix;

    //子节点数组
    std::vector<std::shared_ptr<Object3D>> *mChildren;
    
    //每一帧的调用入口，递归调用所有子类的LoopOnce。
    void LoopOnce();
};

#endif /* Object3D_hpp */
