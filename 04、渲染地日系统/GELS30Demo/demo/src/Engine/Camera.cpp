//
//  Camera.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#include "Camera.h"

Camera::Camera(XSVector3 position, float fov, float aspectRatio, float near, float far) : mAspectRatio(aspectRatio), mFov(fov), mNear(near), mFar(far) {
    
    //参考：https://learnopengl-cn.github.io/01%20Getting%20started/09%20Camera/#_2
    //glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
    //glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
    //glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);
    
    cameraPosition.set(position.x, position.y, position.z);
    cameraFront.set(0.0f, 0.0f, -1.0f);
    cameraUp.set(0.0f, 1.0f, 0.0f);
}

XSMatrix Camera::getViewMatrix() {
    
    //参考：https://learnopengl-cn.github.io/01%20Getting%20started/09%20Camera/#_2
    //view = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
    
    mObjMatrix.makeLookAt(cameraPosition, cameraPosition + cameraFront,cameraUp);
    return mObjMatrix;
}

XSMatrix Camera::getProjectionPerspectiveMatrix() const {
    XSMatrix matrix;
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
    return cameraPosition;
}

const float Camera::getZoom() {
    return mFov;
}

void Camera::move(CameraMovement movement, float delta) {
    switch (movement) {
        case CameraMovement::FORWARD:
            cameraPosition.z -= delta;
            break;
        case CameraMovement::BACKWARD:
            cameraPosition.z += delta;
            break;
        case CameraMovement::LEFT:
            cameraPosition.x -= delta;
            break;
        case CameraMovement::RIGHT:
            cameraPosition.x += delta;
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
