//
//  Sphere.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#include "Sphere.h"

const shared_ptr<Material> &Sphere::getMaterial() const {
    return mMaterial;
}

void Sphere::setMaterial(const shared_ptr<Material> &material) {
    this->mMaterial = material;
}

Sphere::Sphere(float radius, shared_ptr<Material> &mMaterial) {
    
    this->setMaterial(mMaterial);
    this->mScale.set(1.0f, 1.0f, 1.0f);
    int stacks = 15;
    int slices = 33;

    // 生成顶点
    for (int i = 0; i <= stacks; ++i) {
        float phi = PI * (i / (float) (stacks - 1) - 0.5f); // 纬度角，从-PI/2到PI/2
        float sinPhi = sinf(phi);
        float cosPhi = cosf(phi);

        for (int j = 0; j <= slices; ++j) {
            float theta = 2.0f * PI * j / (float) slices; // 经度角，从0到2PI
            float sinTheta = sinf(theta);
            float cosTheta = cosf(theta);

            // 计算顶点坐标
            VertexData v;
            v.position[0] = radius * cosPhi * sinTheta;
            v.position[1] = radius * sinPhi;
            v.position[2] = radius * cosPhi * cosTheta;

            // 计算纹理坐标 (s, t)，s对应经度，t对应纬度
            v.texCoord[0] = j / (float) slices; // 范围从0到1
            v.texCoord[1] = 1.0f - i / (float) stacks; // 反转纬度以匹配常见的纹理映射（北极在上）

            this->mVertex.push_back(v);
        }
    }

    //生成索引
    for (int i = 0; i < stacks - 1; ++i) {
        for (int j = 0; j < slices; ++j) {
            // 第一个三角形
            mVertexIndices.push_back(i * (slices + 1) + j);
            mVertexIndices.push_back((i + 1) * (slices + 1) + j);
            mVertexIndices.push_back(i * (slices + 1) + j + 1);

            // 第二个三角形
            mVertexIndices.push_back((i + 1) * (slices + 1) + j);
            mVertexIndices.push_back((i + 1) * (slices + 1) + j + 1);
            mVertexIndices.push_back(i * (slices + 1) + j + 1);
        }
    }
}

void Sphere::Begin() {

    //1、创建VAO和VBO
    glGenVertexArrays(1, &VAO);
    //第一个参数：要生成多少个缓冲对象。
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO); // 如果使用索引绘制，则需要EBO

    //2、绑定VAO和VBO
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    
    //3、把顶点数组复制到缓冲中供OpenGL使用
    GLsizeiptr dataSize = mVertex.size() * sizeof(VertexData); // 计算数据总大小（字节）
    glBufferData(GL_ARRAY_BUFFER, dataSize, this->mVertex.data(), GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * this->mVertexIndices.size(), this->mVertexIndices.data(), GL_STATIC_DRAW);
    
    //4、设置顶点属性指针
    //第一个参数指定要配置的顶点属性
    //第二个参数指定顶点属性的大小
    //第三个参数指定数据的类型
    //第四个参数指定是否数据被标准化
    //第五个参数叫做步长(Stride)，它告诉我们在连续的顶点属性组之间的间隔
    //最后一个参数的类型是void*，表示位置数据在缓冲中起始位置的偏移量(Offset)
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData),(void *) (0 * sizeof(float)));
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData),(void *) (3 * sizeof(float)));
    glEnableVertexAttribArray(2);

    //5、解绑
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    Object3D::Begin();
}

void Sphere::OnLoopOnce(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
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

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, this->getMaterial()->getTextureId());
    
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glDrawElements(GL_TRIANGLES, this->mVertexIndices.size(), GL_UNSIGNED_INT, nullptr);

    //解绑
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void Sphere::End() {
    Object3D::End();
    if (mMaterial) {
        glDeleteProgram(mMaterial->getProgramId());
    }
}
