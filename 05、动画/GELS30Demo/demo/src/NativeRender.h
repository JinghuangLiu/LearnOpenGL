//
// Created by yangyk on 2024/4/1.
//

#pragma once

#include <string>
#include <map>
#include <list>
#include <vector>

#include "Engine/Engine.h"
#include "Engine/OpenGLES.h"
#include "NewScene.h"

#include <GLKit/GLKit.h>

class NativeRender
{
public:
    void create(int width, int height);
    void resize(int width, int height);
    void drawFrame();
    void destroy();
    shared_ptr<Camera> camera;
private:
    shared_ptr<NewScene> worldObj;
};

