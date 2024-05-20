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
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT,
    ROTATE_LEFT,
    ROTATE_RIGHT
};

//定义相机
class Camera  : public Object3D
{
public:
    
    Camera(XSVector3 position, float mFov, float aspectRatio, float mNear, float mFar);

    XSMatrix getViewMatrix();

    XSMatrix getProjectionPerspectiveMatrix() const;

    void move(CameraMovement movement, float delta);

    void zoomIn(float deltaAngle = 0.5f);

    void zoomOut(float deltaAngle = 0.5f);

    const XSVector3 &getPosition();

    const float getZoom();

    void receiveKeyCommand(char key);

private:
    float mAspectRatio;
    float mFov;
    float mNear;
    float mFar;
    
    XSVector3 mPos;
    XSVector3 mFront;
//        xscore::XSVector3 mTo;
    XSVector3 mUp;
    // 旋转角度
    float yaw = 0.0f;
};

#endif /* Camera_hpp */
