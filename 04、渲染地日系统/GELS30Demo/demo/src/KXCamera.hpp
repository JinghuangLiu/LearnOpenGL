//
//  KXCamera.cpp
//  demo
//
//  Created by empty on 2024/5/17.
//

#ifndef Camera_h
#define Camera_h

//#include <glm/glm.hpp>
//#include <glm/gtc/matrix_transform.hpp>
//#include <glm/gtc/type_ptr.hpp>
#include "GLESMath.h"
#include <cmath>
#include <cstring>

const float PITCH = 0.f;
const float YAW = 0.f;
const float SPEED = 10.f;
const float SENSITYVITY = 0.1f;

enum KXCamera_Movement {
    KX_FORWARD,
    KX_BACKWARD,
    KX_LEFT,
    KX_RIGHT,
    KX_UPWARD,
    KX_DOWNWARD
};

class KXCamera {

public:
    float Position[3];
    
    float Front[3];
    float Up[3];
    float Right[3];
    float WorldUp[3];
    
    float Pitch;
    float Yaw;
    
    float MovementSpeed;
    float MouseSensityvity;
    float DefaultOrigin[3];
    ///构造方法
    KXCamera(float origin[3],float up[3],float pitch = PITCH,float yaw = YAW,float speed = SPEED,float sensityvity = SENSITYVITY) {
        Position[0] = origin[0];
        Position[1] = origin[1];
        Position[2] = origin[2];
        setDefaultOrigin(origin);
        WorldUp[0] = up[0];
        WorldUp[1] = up[1];
        WorldUp[2] = up[2];
        setDefaultWorldUp(up);
        Pitch = pitch;
        setDefaultPicth(pitch);
        Yaw = yaw;
        setDefaultYaw(yaw);
        MovementSpeed = speed;
        MouseSensityvity = sensityvity;
        updateCameraVectors();
    }
    
    ///朝指定方向移动
    void move(KXCamera_Movement movement,float deltaTime) {
        switch (movement) {
            case KX_FORWARD:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] += Front[i] * MovementSpeed * deltaTime;
            }
                break;
            case KX_BACKWARD:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] -= Front[i] * MovementSpeed * deltaTime;
            }
                break;
            case KX_RIGHT:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] -= Right[i] * MovementSpeed * deltaTime;
            }
                break;
            case KX_LEFT:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] += Right[i] * MovementSpeed * deltaTime;
            }
                break;
            case KX_DOWNWARD:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] += Up[i] * MovementSpeed * deltaTime;
            }
                break;
            case KX_UPWARD:
            {
                for (int i = 0; i < 3; i++)
                    Position[i] -= Up[i] * MovementSpeed * deltaTime;
            }
                break;
            default:
                break;
        }
    }
    
    ///设置移动速度
    void setSpeed(float speed = SPEED) {
        MovementSpeed = speed;
    }
    
    ///设置鼠标灵敏度
    void setSensityvity(float sensityvity = SENSITYVITY) {
        MouseSensityvity = sensityvity;
    }
    
    ///设置俯仰角
    void setPitch(float pitch) {
        Pitch = pitch;
    }
    
    ///设置偏航角
    void setYaw(float yaw) {
        Yaw = yaw;
    }
    
    ///设置世界坐标系中的上向量
    void setWorldUp (float worldUp[3]) {
        WorldUp[0] = worldUp[0];
        WorldUp[1] = worldUp[1];
        WorldUp[2] = worldUp[2];
    }
    
    ///改变俯仰角、偏航角或世界坐标上向量后需要更新摄像机的方向向量
    void updateCameraVectors() {
        float front[3];
        front[0] = cos(radians(Pitch)) * sin(radians(Yaw));
        front[1] = sin(radians(Pitch));
        front[2] = -cos(radians(Pitch)) * cos(radians(Yaw));
        Front[0] = front[0];
        Front[1] = front[1];
        Front[2] = front[2];
    
        float result[3];
        cross(Front, WorldUp, result);
        normalize(result, Right);
        
        float up[3];
        cross(Right, Front, up);
        normalize(up, Up);
    }
    
    ///设置默认的俯仰角
    void setDefaultPicth(float pitch) {
        DefaultPitch = pitch;
    }
    
    ///设置默认的偏航角
    void setDefaultYaw(float yaw) {
        DefaultYaw = yaw;
    }
    
    ///设置默认的摄像机位置
    void setDefaultOrigin(float camera[3]) {
        DefaultOrigin[0] = camera[0];
        DefaultOrigin[1] = camera[1];
        DefaultOrigin[2] = camera[2];
    }
    
    ///设置默认的世界坐标上向量
    void setDefaultWorldUp(float worldUp[3]) {
        DefaultWorldUp[0] = worldUp[0];
        DefaultWorldUp[1] = worldUp[1];
        DefaultWorldUp[2] = worldUp[2];
    }
    
    ///获取当前的观察矩阵
    KSMatrix4 getViewMatrix() {
        
        float centerX = Position[0] + Front[0];
        float centerY = Position[1] + Front[1];
        float centerZ = Position[2] + Front[2];
        
        return ksLookAt(Position[0], Position[1], Position[2], centerX, centerY, centerZ, WorldUp[0], WorldUp[1], WorldUp[2]);
    }
    
    ///重置摄像机至默认状态
    void resetCamera() {
        Position[0] = DefaultOrigin[0];
        Position[1] = DefaultOrigin[1];
        Position[2] = DefaultOrigin[2];
        
        WorldUp[0] = DefaultWorldUp[0];
        WorldUp[1] = DefaultWorldUp[1];
        WorldUp[2] = DefaultWorldUp[2];
        
        Pitch = DefaultPitch;
        Yaw = DefaultYaw;
        updateCameraVectors();
    }
    
private:
    
    float DefaultWorldUp[3];
    float DefaultPitch;
    float DefaultYaw;
    
    float radians(float degree) {
        return degree * M_PI / 180.0f;
    }
    
    void normalize(const float* v, float* result) {
        float length = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
        for (int i = 0; i < 3; i++)
            result[i] = v[i] / length;
    }
    
    void cross(const float* a, const float* b, float* result) {
        result[0] = a[1] * b[2] - a[2] * b[1];
        result[1] = a[2] * b[0] - a[0] * b[2];
        result[2] = a[0] * b[1] - a[1] * b[0];
    }
};

#endif /* Camera_h */
