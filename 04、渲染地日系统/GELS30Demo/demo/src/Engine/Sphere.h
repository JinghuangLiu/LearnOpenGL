//
//  Sphere.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#ifndef Sphere_hpp
#define Sphere_hpp

#include <stdio.h>
#include <iostream>
#include "Object3D.h"
#include "Material.h"
#include "OpenGLES.h"
#include <vector>
using namespace xscore;

//定义球形模型
class Sphere : public Object3D
{
public:
    Sphere(float radius, std::shared_ptr<Material> &material);

    void Begin() override;

    //void LoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent) override;
    virtual void OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent);

    void End() override;

//private:
    GLuint VAO, VBO, EBO;
    //顶点信息字段
    std::vector<VertexData> mVertex;

    //索引信息字段
    std::vector<unsigned int> mVertices;

    //材质
    std::shared_ptr<Material> mMaterial;
public:
    const std::shared_ptr<Material> &getMaterial() const;

    void setMaterial(const std::shared_ptr<Material> &material);
};

#endif /* Sphere_hpp */
