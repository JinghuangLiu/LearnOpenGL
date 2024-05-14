//
//  Sphere.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Sphere_hpp
#define Sphere_hpp

#include <stdio.h>
#include <iostream>
#include "Object3D.hpp"
#include "Material.hpp"
using namespace xscore;

//定义球形模型
class Sphere : public Object3D
{
    //顶点信息字段
    std::vector<float> *mVertex;

    //索引信息字段
    std::vector<int> *mVertices;

    //材质
    std::shared_ptr<Material> *mMaterialk;
};

#endif /* Sphere_hpp */
