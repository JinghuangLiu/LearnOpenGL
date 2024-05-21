//
//  Material.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#include "Material.h"
#include "OpenGLES.h"
#include "ShaderTools.h"

Material::Material(const string &vertexShaderPath,
                   const string &fragmentShaderPath,
                   unsigned char *textureData, 
                   int textureW,
                   int textureH) {
    
    const char *vertexShaderText = vertexShaderPath.c_str();
    const char *fragmentShaderText = fragmentShaderPath.c_str();
    
    this->programId = ShaderTools::createShaderProgram(vertexShaderText, fragmentShaderText);

    //生成、绑定纹理
    glGenTextures(1, &this->textureId);
    glBindTexture(GL_TEXTURE_2D, this->textureId);
    
    //为当前绑定的纹理对象设置环绕、过滤方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //载入纹理数据
    if (textureData) {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureW, textureH, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
        glGenerateMipmap(GL_TEXTURE_2D);
    } else {
        std::cout << "纹理载入失败。\n" << std::endl;
    }
    free(textureData);
    
    //解绑
    glBindTexture(GL_TEXTURE_2D, 0);
}

int Material::use() const {
    glUseProgram(programId);
    return programId;
}

//void Material::setVec3(const string &name, XSVector3 &value) const {
//    glUniform3fv(glGetUniformLocation(this->programId, name.c_str()), 1, &value[0]);
//}

unsigned int Material::getTextureId() const {
    return textureId;
}

unsigned int Material::getProgramId() const {
    return programId;
}
