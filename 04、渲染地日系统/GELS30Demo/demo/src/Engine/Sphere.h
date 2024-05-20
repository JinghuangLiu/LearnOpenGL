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
#include <vector>

#include "Object3D.h"
#include "Material.h"
#include "OpenGLES.h"

using namespace std;
using namespace xscore;

//定义球形模型
class Sphere : public Object3D {
    
public:
    Sphere(float radius, shared_ptr<Material> &material);

    void Begin() override;
    virtual void OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent) override;
    void End() override;

//private:
    GLuint VAO, VBO, EBO;
    
    //顶点数据
    vector<VertexData> mVertex;

    //索引数据
    vector<unsigned int> mVertices;

    //材质
    shared_ptr<Material> mMaterial;
public:
    const shared_ptr<Material> &getMaterial() const;

    void setMaterial(const shared_ptr<Material> &material);
};

#endif /* Sphere_hpp */
