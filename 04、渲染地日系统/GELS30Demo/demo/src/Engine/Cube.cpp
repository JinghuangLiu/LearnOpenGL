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
    float cubeVertices[] = {
        //正背面
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, -halfEdge, 1.0f, 0.0f,
        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 0.0f,
        //正面
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 1.0f,
        -halfEdge, halfEdge, halfEdge, 0.0f, 1.0f,
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        //左面
        -halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        -halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        //右面
        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        //下面
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        halfEdge, -halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
        halfEdge, -halfEdge, halfEdge, 1.0f, 0.0f,
        -halfEdge, -halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, -halfEdge, -halfEdge, 0.0f, 1.0f,
        //上面
        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f,
        halfEdge, halfEdge, -halfEdge, 1.0f, 1.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        halfEdge, halfEdge, halfEdge, 1.0f, 0.0f,
        -halfEdge, halfEdge, halfEdge, 0.0f, 0.0f,
        -halfEdge, halfEdge, -halfEdge, 0.0f, 1.0f
    };
    for (int i = 0; i < VERTICE_SIZE * VERTICE_LENGTH; ++i) {
        this->mVertices[i] = cubeVertices[i];
    }

}

void Cube::Begin() {

    //创建、绑定顶点数组对象
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    //    创建、绑定顶点缓冲对象：
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    //把cubeVertices写入到这个缓冲对象里
    glBufferData(GL_ARRAY_BUFFER, sizeof(mVertices), mVertices, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    Object3D::Begin();
}

void Cube::OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    if (!this->getMaterial()) {
        return;
    }
    int shaderProgram = this->getMaterial()->use();
    GLuint modelMatrixLoc = glGetUniformLocation(shaderProgram, "u_model");
    GLuint viewMatrixLoc = glGetUniformLocation(shaderProgram, "u_view");
    GLuint projectionMatrixLoc = glGetUniformLocation(shaderProgram, "u_projection");
    GLuint ourTextureLoc = glGetUniformLocation(shaderProgram, "ourTexture");

    glUniform1i(ourTextureLoc, 0);
    glUniformMatrix4fv(modelMatrixLoc, 1, GL_FALSE, parent.m);
    glUniformMatrix4fv(viewMatrixLoc, 1, GL_FALSE, cam.m);
    glUniformMatrix4fv(projectionMatrixLoc, 1, GL_FALSE, proj.m);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    for (int i = 0; i < 6; ++i) {
        glActiveTexture(GL_TEXTURE0);
//            glBindTexture(GL_TEXTURE_2D, this->texture[i]);
        glBindTexture(GL_TEXTURE_2D, this->getMaterial()->getTextureId());
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float),
                              (void *) (30 * i * sizeof(float)));
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float),
                              (void *) ((3 + 30 * i) * sizeof(float)));
        glEnableVertexAttribArray(2);
        //每个面有2个三角形 共6个顶点
        glDrawArrays(GL_TRIANGLES, 0, 2 * 3);
    }

    //最后做一个解绑
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
