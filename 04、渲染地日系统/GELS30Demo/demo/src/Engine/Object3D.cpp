//
//  Object3D.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/14.
//

#include "Object3D.h"

Object3D::Object3D() : mScale(1.0f, 1.0f, 1.0f) {

}

void Object3D::RecursiveLoop(XSMatrix &proj, XSMatrix &cam, XSMatrix &parent)
{
    //先缩放（Scale），再旋转（Rotate），最后位移（Translate）
    //M = T * R * S
    this->mObjMatrix.makeScale(mScale.x, mScale.y, mScale.z);
    this->mObjMatrix.applyRotateXLeft(mRotation.x);
    this->mObjMatrix.applyRotateYLeft(mRotation.y);
    this->mObjMatrix.applyRotateZLeft(mRotation.z);
    this->mObjMatrix.applyTranslateLeft(mPosition.x, mPosition.y, mPosition.z);

    XSMatrix combination;
    XSMatrix::multiply(combination, parent, mObjMatrix);

    OnLoopOnce(proj, cam, combination);

    //所有子对象，更新变换矩阵
    for (shared_ptr<Object3D>& child: mChildren)
    {
        child->RecursiveLoop(proj, cam, combination);
    }
}

const XSMatrix &Object3D::getMatrix() const {
    return mObjMatrix;
}

void Object3D::addChild(shared_ptr<Object3D> childObject3D) {
    this->mChildren.push_back(childObject3D);
}

void Object3D::setPosition(const XSVector3 &mPosition) {
    Object3D::mPosition = mPosition;
}

void Object3D::setRotation(const XSVector3 &mRotation)
{
    Object3D::mRotation = mRotation;
}


void Object3D::setScale(const XSVector3 &mScale) {
    Object3D::mScale = mScale;
}

const vector<shared_ptr<Object3D>> &Object3D::getChildren() const {
    return mChildren;
}

void Object3D::Begin() {
    if (mChildren.size() > 0) {
        for (std::shared_ptr<Object3D> &child: mChildren) {
            child->Begin();
        }
    }
}

void Object3D::End() {
    if (mChildren.size() > 0) {
        for (shared_ptr<Object3D> &child: mChildren) {
            child->End();
        }
    }
}
