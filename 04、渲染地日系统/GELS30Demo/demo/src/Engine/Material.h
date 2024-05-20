//
//  Material.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Material_hpp
#define Material_hpp

#include <stdio.h>
#include <iostream>
#include "XSMatrix.h"

using namespace std;
using namespace xscore;

//定义材质对象
class Material
{
    
public:
    
    Material(const string &vertexShaderPath,
             const string &fragmentShaderPath,
             unsigned char *textureData, int textureW, int textureH);

    Material(unsigned int programId, unsigned int textureId) {
        this->programId = programId;
        this->textureId = textureId;
    }
    
    //        std::string vertexShaderText;
    //        std::string fragmentShaderText;
    //        std::string texturePath;

    unsigned int getTextureId() const;

    unsigned int getProgramId() const;

    int use() const;

    void setVec3(const std::string &name, XSVector3 &value) const;

private:
    unsigned int programId, textureId;
};

#endif /* Material_hpp */
