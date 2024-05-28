//
//  Cube.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/20.
//

#include "Cube.h"

Cube::Cube(float edge, shared_ptr<Material> &material) {
    this->setMaterial(material);
    float halfEdge = edge / 2;
    //前面三个为顶点位置、后面2个为贴图
//    float cubeVertices[] = {
//        //正背面
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
//        halfEdge, -halfEdge, -halfEdge, 1.0f, 0.0f,
//        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
//        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
//        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
//        //正面
//        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
//        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
//        halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
//        halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
//        -halfEdge, halfEdge, halfEdge, 0.0f, 1.0f,
//        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
//        //左面
//        -halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        -halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
//        -halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        //右面
//        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
//        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
//        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        //下面
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        halfEdge, -halfEdge, -halfEdge, 1.0f, 1.0f,
//        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
//        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
//        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
//        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
//        //上面
//        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
//        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
//        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
//        -halfEdge, halfEdge, halfEdge, 0.0f, 0.0f,
//        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f
//    };
    
    float cubeVertices[] = {
        -halfEdge, halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, -halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        halfEdge, halfEdge, halfEdge, 0.0f, 1.0f,

        //正背面
        -halfEdge, halfEdge, -halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, -halfEdge, 1.0f, 1.0f,
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        -halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, -halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        
        //左面
        -halfEdge, halfEdge, -halfEdge, 0.0f, 0.0f,
        -halfEdge, -halfEdge, -halfEdge, 1.0f, 1.0f,
        -halfEdge, -halfEdge, halfEdge, 0.0f, 1.0f,
        -halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, halfEdge, halfEdge, 0.0f, 1.0f,
        
        //右面
        halfEdge, halfEdge, halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
        halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
        
        //上面
        -halfEdge, halfEdge, -halfEdge, 0.0f, 0.0f,
        -halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, halfEdge, 0.0f, 1.0f,
        -halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, halfEdge, 0.0f, 0.0f,
        halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
        
        
        //下面
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, -halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        -halfEdge, -halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, halfEdge, 0.0f, 1.0f,
    };

    
    for (int i = 0; i < VERTICE_SIZE * VERTICE_LENGTH; ++i) {
        this->mVertices[i] = cubeVertices[i];
    }

}

void Cube::Begin() {

    //创建、绑定顶点数组对象
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    //把cubeVertices写入到这个缓冲对象里
    glBufferData(GL_ARRAY_BUFFER, sizeof(mVertices), mVertices, GL_STATIC_DRAW);
        
    //解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    Object3D::Begin();
}

void Cube::OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    if (!this->getMaterial()) {
        return;
    }
    
    //数据传递给着色器的Uniform变量
    int shaderProgram = this->getMaterial()->use();
    glUniform1i(glGetUniformLocation(shaderProgram, "ourTexture"), 0);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "u_model"), 1, GL_FALSE, parent.m);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "u_view"), 1, GL_FALSE, cam.m);
    glUniformMatrix4fv(glGetUniformLocation(shaderProgram, "u_projection"), 1, GL_FALSE, proj.m);

    //绑定和渲染
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    for (int i = 0; i < 6; ++i) {
        
        //绘制前激活纹理单元，并绑定到特定纹理对象
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, this->getMaterial()->getTextureId());
        
        //设置顶点属性指针
        //第一个参数指定要配置的顶点属性，在顶点着色器中使用layout(location = 0)定义了position顶点属性的位置值
        //第二个参数指定顶点属性的大小。顶点属性是一个vec3，它由3个值组成，所以大小是3。
        //第三个参数指定数据的类型
        //第四个参数指定是否数据被标准化
        //第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔
        //最后一个参数的类型是void*，表示位置数据在缓冲中起始位置的偏移量(Offset)
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *) (30 * i * sizeof(float)));
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float),(void *) ((3 + 30 * i) * sizeof(float)));
        glEnableVertexAttribArray(2);
        
        //每个面有2个三角形 共6个顶点
        glDrawArrays(GL_TRIANGLES, 0, 2 * 3);
    }

    //解绑
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void Cube::setMaterial(const shared_ptr<Material> &material) {
    this->mMaterial = material;
}

const shared_ptr<Material> &Cube::getMaterial() const {
    return mMaterial;
}

void Cube::End() {
    Object3D::End();
    if (mMaterial) {
        glDeleteProgram(mMaterial->getProgramId());
    }
}
