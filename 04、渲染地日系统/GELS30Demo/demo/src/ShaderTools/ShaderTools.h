//
//  ShaderTools.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#ifndef ShaderTools_hpp
#define ShaderTools_hpp

#include <stdio.h>
#include <iostream>
#include <string>
#include "OpenGLES.h"

class ShaderTools
{
public:
    static GLuint createShaderProgram(const std::string &vertexShaderText,const std::string &fragmentShaderText);
    
private:
    static std::string readShader(const std::string &path);
};


#endif /* ShaderTools_hpp */
