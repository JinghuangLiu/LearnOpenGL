//
//  Camera.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Camera_hpp
#define Camera_hpp

#include <stdio.h>
#include "Object3D.h"

using namespace std;
using namespace xscore;

enum CameraMovement {
    UP,
    DOWN,
    LEFT,
    RIGHT,
    FORWARD,
    BACKWARD,
};

//参考：https://learnopengl-cn.github.io/01%20Getting%20started/09%20Camera/
//定义相机
class Camera  : public Object3D
{
public:
    
    /// 构造相机
    /// - Parameters:
    ///   - position: 位置
    ///   - mFov: 视场（Field of view）
    ///   - aspectRatio: 横纵比
    ///   - mNear: 近裁剪平面
    ///   - mFar: 远裁剪平面
    Camera(XSVector3 position, float mFov, float aspectRatio, float mNear, float mFar);
    
    // 摄像头移动
    void move(CameraMovement movement, float delta);

    // 缩小
    void zoomIn(float deltaAngle = 0.5f);

    // 放大
    void zoomOut(float deltaAngle = 0.5f);
    
    // 获取缩放系数
    const float getZoom();

    // 获取相机位置
    const XSVector3 &getPosition();
    
    // 获取视角矩阵
    XSMatrix getViewMatrix();

    // 获取透视投影矩阵
    XSMatrix getProjectionPerspectiveMatrix() const;

private:
    // 横纵比
    float mAspectRatio;
    // 视场（Field of view）
    float mFov;
    // 近裁剪平面
    float mNear;
    // 远裁剪平面
    float mFar;
    
    // 位置
    XSVector3 cameraPosition;
    // 前向量
    XSVector3 cameraFront;
    // 上向量
    XSVector3 cameraUp;
};

#endif /* Camera_hpp */
