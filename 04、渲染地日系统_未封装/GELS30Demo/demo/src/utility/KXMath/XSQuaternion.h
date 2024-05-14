//
// Created by yangyk on 2021/4/24.
//

#ifndef XSPRITE_XSQUATERNION_H
#define XSPRITE_XSQUATERNION_H

namespace xscore
{
    class XSMatrix;

    class XSVector3;

    class XSVector4;

    class XSQuaternion
    {
    public:
        float w;
        float x;
        float y;
        float z;

    public:
        XSQuaternion();

        XSQuaternion(float w, float x, float y, float z);

    public:
        static const XSQuaternion& identity();

    public:
        void scale(float scale);

        float length() const;

        float dot(const XSQuaternion& q) const;

        XSQuaternion operator+(const XSQuaternion& q) const;

        XSQuaternion operator-(const XSQuaternion& q) const;

        XSQuaternion operator*(float scale) const;

        XSQuaternion operator/(float scale) const;

        XSQuaternion slerp(const XSQuaternion& q, float t, bool detour) const;

        void normalize();

        void makeIdentity();

        void makeFromMatrix(const XSMatrix& m);

        void makeFromAxisAngle(float x, float y, float z, float radian);

        void makeFromAxisAngle(const XSVector3& v, float radian);

        void makeFromAxisAngle(const XSVector4& v, float radian);
    };
}


#endif //ANDROIDGLS_XSQUATERNION_H
