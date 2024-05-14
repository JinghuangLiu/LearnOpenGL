//
// Created by yangyk on 2018/2/14.
//

#ifndef XSPRITE_XSMATRIX_H
#define XSPRITE_XSMATRIX_H

//#include "../../XSPlatform.h"
#include <cstring>
#include <cmath>
#include <cstdint>
#include "XSVector2.h"
#include "XSVector3.h"
#include "XSVector4.h"
#define MATRIX_SIZE (sizeof(float) * 16)

namespace xscore
{
    class XSVector3;

    class XSVector4;

    class XSQuaternion;

    class XSMatrix
    {
    public:
        float m[16];

    public:
        XSMatrix();

        XSMatrix(const float* src);

    public:
        void set(const float* m);

        bool invert(XSMatrix& out);

    public:
        static const XSMatrix& identity();

        static void multiply(XSMatrix& result, const XSMatrix& left, const XSMatrix& right);

        static void multiply(XSVector4& result, const XSMatrix& left, const XSVector4& right);

    public:
        void makeIdentity();

        void makeFromQuaternion(const XSQuaternion& q);

        void makePerspective(float fovy, float aspect, float zNear, float zFar);

        void makeOrtho2D(float left, float right, float bottom, float top, float near, float far);

        void makeLookAt(const XSVector3& pos, const XSVector3& to, const XSVector3& up);

        void makeLookAt(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ);

        void makeScale(float x, float y, float z);

        void makeTranslate(float x, float y, float z);

        void makeRotate(float radian, float x, float y, float z);

        void makeRotateX(float radian);

        void makeRotateY(float radian);

        void makeRotateZ(float radian);

        void applyScaleLeft(float x, float y, float z);

        void applyScaleRight(float x, float y, float z);

        void applyRotateLeft(float radian, float x, float y, float z);

        void applyRotateRight(float radian, float x, float y, float z);

        void applyRotateXLeft(float radian);

        void applyRotateYLeft(float radian);

        void applyRotateZLeft(float radian);

        void applyQuaternionLeft(const XSQuaternion& q);

        void applyRotateXRight(float radian);

        void applyRotateYRight(float radian);

        void applyRotateZRight(float radian);

        void applyQuaternionRight(const XSQuaternion& q);

        void applyTranslateLeft(float x, float y, float z);

        void applyTranslateRight(float x, float y, float z);

        void applyMultiplyLeft(const XSMatrix& mat);

        void applyMultiplyRight(const XSMatrix& mat);
    };
}

#endif //XSPRITE_XSMATRIX_H
