//
// Created by yangyk on 2024/4/1.
//

#include "NativeRender.h"

void NativeRender::create(EAGLContext *mContext, int width, int height) {
    //调整视口
    resize(width, height);
    //创建相机对象
    float aspectRatio = width * 1.0f / height; // 宽高比
    this->camera = make_shared<Camera>(xscore::XSVector3(0.0f, 0.0f, 10.0f),45.0f,aspectRatio, 0.1f, 100.0f);

    //创建世界物体对象
    this->worldObj = make_shared<NewWorld>();
    //begin阶段
    this->worldObj->Begin();
}

void NativeRender::resize(int width, int height) {
    glViewport(0, 0, width, height);
}

void NativeRender::destroy()
{
    if (this->worldObj) {
        this->worldObj->End();
    }
}

int NativeRender::drawFrame(int texture, double interval)
{
    glClearColor(0.2f, 0.2f, 0.2f, 0.5f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glEnable(GL_DEPTH_TEST);
    //启用面剔除
    //    glEnable(GL_CULL_FACE);
    //    glCullFace(GL_FRONT);

    auto proj = this->camera->getProjectionPerspectiveMatrix();
    auto view = this->camera->getViewMatrix();
    //world的parent矩阵是原点
    xscore::XSMatrix parent;
    this->worldObj->LoopOnce(proj, view, parent);


    glFlush();

    return 0;
}

