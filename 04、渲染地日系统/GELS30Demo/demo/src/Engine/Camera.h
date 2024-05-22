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
    
    Camera(XSVector3 position, float mFov, float aspectRatio, float mNear, float mFar);

    XSMatrix getViewMatrix();

    XSMatrix getProjectionPerspectiveMatrix() const;
    
    // 摄像头移动
    void move(CameraMovement movement, float delta);

    // 缩小
    void zoomIn(float deltaAngle = 0.5f);

    // 放大
    void zoomOut(float deltaAngle = 0.5f);

    //位置
    const XSVector3 &getPosition();

    // 获取缩放系数
    const float getZoom();

    void receiveKeyCommand(char key);

private:
    float mAspectRatio;
    float mFov;
    float mNear;
    float mFar;
    
    //位置
    XSVector3 cameraPosition;
    //前向量
    XSVector3 cameraFront;
    //上向量
    XSVector3 cameraUp;
    //旋转角度
    float yaw = 0.0f;
};

#endif /* Camera_hpp */
