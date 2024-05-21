//
//  Cube.hpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/20.
//

#ifndef Cube_hpp
#define Cube_hpp

#include <stdio.h>
#include <iostream>
#include <vector>

#include "Object3D.h"
#include "Material.h"
#include "OpenGLES.h"

using namespace std;
using namespace xscore;

#define VERTICE_SIZE 36
#define VERTICE_LENGTH 5

class Cube : public Object3D {
    
public:
    Cube(float edge, shared_ptr<Material> &material);

    void Begin() override;
    virtual void OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent) override;
    void End() override;
    
private:
    //顶点数据
    float mVertices[VERTICE_SIZE * VERTICE_LENGTH];
    //材质
    shared_ptr<Material> mMaterial;

    //顶点数组对象：Vertex Array Object，VAO
    //顶点缓冲对象：Vertex Buffer Object，VBO
    //元素缓冲对象：Element Buffer Object，EBO 或 索引缓冲对象 Index Buffer Object，IBO
    GLuint VAO, VBO;
    
public:
    const shared_ptr<Material> &getMaterial() const;
    void setMaterial(const std::shared_ptr<Material> &material);
    
};

#endif /* Cube_hpp */
