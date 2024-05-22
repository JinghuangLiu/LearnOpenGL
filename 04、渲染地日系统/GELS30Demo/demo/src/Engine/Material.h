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
             unsigned char *textureData, 
             int textureW,
             int textureH);

    unsigned int getTextureId() const;

    unsigned int getProgramId() const;

    int use() const;

private:
    unsigned int programId, textureId;
};

#endif /* Material_hpp */
