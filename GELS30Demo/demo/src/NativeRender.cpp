//
// Created by yangyk on 2024/4/1.
//

#include "NativeRender.h"

void NativeRender::create(int width, int height)
{

}

void NativeRender::destroy()
{

}

int NativeRender::drawFrame(int texture, double interval)
{
    glClearColor(1.0f, 0, 0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    glFlush();
    return 0;
}

