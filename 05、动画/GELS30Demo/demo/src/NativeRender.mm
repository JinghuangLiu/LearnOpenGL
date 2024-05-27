//
// Created by yangyk on 2024/4/1.
//

#include "NativeRender.h"

void NativeRender::create(int width, int height) {
    //调整视口
    resize(width, height);
    
    //创建相机对象
    float aspectRatio = width * 1.0f / height; // 宽高比
    this->camera = make_shared<Camera>(XSVector3(0.0f, 0.0f, 10.0f),45.0f,aspectRatio, 0.1f, 100.0f);

    //创建世界物体对象
    this->worldObj = make_shared<NewScene>();
    //begin阶段
    this->worldObj->Begin();
    
    this->worldObj->addSunAnimate();

}

void NativeRender::resize(int width, int height) {
    //设置视口大小
    glViewport(0, 0, width, height);
}

void NativeRender::drawFrame()
{
    glClearColor(1, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //启用深度测试
    glEnable(GL_DEPTH_TEST);
    //启用面剔除
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);

    auto proj = this->camera->getProjectionPerspectiveMatrix();
    auto view = this->camera->getViewMatrix();
    
    //world的parent矩阵是原点
    XSMatrix parent;
    
    this->worldObj->startAnimate();
    
    this->worldObj->Loop(proj, view, parent);

    //强制将所有在之前调用的OpenGL命令都发送到GPU进行处理
    glFlush();
}

void NativeRender::destroy()
{
    if (this->worldObj) {
        this->worldObj->End();
    }
}


