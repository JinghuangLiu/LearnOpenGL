//
// Created by yangyk on 2024/4/1.
//

#pragma once

#include <string>
#include <map>
#include <list>
#include <vector>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

class NativeRender
{
public:
    void create(int width, int height);
    void destroy();
    int drawFrame(int texture, double interval);
};

