//
//  Object3D.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Object3D_hpp
#define Object3D_hpp

#include <stdio.h>
#include <iostream>
#include "XSMatrix.h"

#include <vector>
#include <memory>

using namespace std;
using namespace xscore;

struct VertexData {
    float position[3]; // 顶点坐标
    float texCoord[2]; // 纹理坐标
};

#define PI  3.14159265358979323846f

class Object3D
{
public:
    Object3D();
    
    virtual void Begin();
    //每一帧的调用入口，递归调用所有子类的RecursiveLoop
    virtual void RecursiveLoop(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent);
    virtual void OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent){};
    virtual void End();
    
    //添加组件
    void addComponent(shared_ptr<Object3D> components);
    const vector<shared_ptr<Object3D>> &getChildren() const;

    //矩阵变换
    //获取对象的变换矩阵
    const XSMatrix &getMatrix() const;
    
    //设置
    void setPosition(const XSVector3 &mPosition);
    void setRotation(const XSVector3 &mRotation);
    void setScale(const XSVector3 &mScale);

    //获取
    const XSVector3& getPosition() { return mPosition;}
    const XSVector3& getRotation() { return mRotation;}
    const XSVector3& getScale() { return mScale;}
    
protected:
    //组件数组
    vector<shared_ptr<Object3D>> components;
    
    //返回当前这一级模型的变换矩阵。
    XSMatrix mObjMatrix;

    //缓存当前位置，缩放，旋转，渲染之前要更新这些数据到mObjMatrix。
    XSVector3 mPosition;
    XSVector3 mRotation;
    XSVector3 mScale;
};

#endif /* Object3D_hpp */
