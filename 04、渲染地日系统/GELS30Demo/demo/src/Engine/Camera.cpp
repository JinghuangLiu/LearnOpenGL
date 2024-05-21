//
//  Camera.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#include "Camera.h"

Camera::Camera(XSVector3 position, float fov, float aspectRatio, float near, float far) : mAspectRatio(aspectRatio), mFov(fov), mNear(near), mFar(far) {
    mPos.set(position.x, position.y, position.z);
    mFront.set(0.0f, 0.0f, -1.0f);
    mUp.set(0.0f, 1.0f, 0.0f);
}

XSMatrix Camera::getViewMatrix() {
    mObjMatrix.makeLookAt(mPos, mPos + mFront,mUp);
    return mObjMatrix;
}

XSMatrix Camera::getProjectionPerspectiveMatrix() const {
    xscore::XSMatrix matrix;
    //弧度/π = 角度/180°
    float fov = mFov / 180.0f * PI;
    matrix.makePerspective(fov, mAspectRatio, mNear, mFar);
    return matrix;
}

void Camera::zoomIn(float deltaAngle) {
    mFov -= deltaAngle;
    if (mFov < 5.0f) {
        mFov = 5.0f;
    }
}

void Camera::zoomOut(float deltaAngle) {
    mFov += deltaAngle;
    //不要大于90度
    if (mFov > 89.0f) {
        mFov = 89.0f;
    }
}

const XSVector3 &Camera::getPosition() {
    return mPos;
}

const float Camera::getZoom() {
    return mFov;
}

void Camera::move(CameraMovement movement, float delta) {
    switch (movement) {
        case CameraMovement::FORWARD:
            mPos.z -= delta;
            break;
        case CameraMovement::BACKWARD:
            mPos.z += delta;
            break;
        case CameraMovement::LEFT:
            mPos.x -= delta;
            break;
        case CameraMovement::RIGHT:
            mPos.x += delta;
            break;
        case CameraMovement::ROTATE_LEFT: {
//                yaw -= delta;
        }
            break;
        case CameraMovement::ROTATE_RIGHT: {
        }
            break;
        default:
            break;
    }
}

void Camera::receiveKeyCommand(char key) {
    switch (key) {
        case 'w':
            move(CameraMovement::FORWARD, 0.1f);
            break;
        case 's':
            move(CameraMovement::BACKWARD, 0.1f);
            break;
        case 'a':
            move(CameraMovement::LEFT, 0.1f);
            break;
        case 'd':
            move(CameraMovement::RIGHT, 0.1f);
            break;
        case 'q':
            move(CameraMovement::ROTATE_LEFT, 0.1f);
            break;
        case 'e':
            move(CameraMovement::ROTATE_RIGHT, 0.1f);
            break;
        case '+':
            zoomIn();
            break;
        case '-':
            zoomOut();
            break;
        default:
            break;
    }
    auto pos = getPosition();
    printf("camera position : (%f,%f,%f), fov : %f", pos.x, pos.y, pos.z,
                getZoom());
}
