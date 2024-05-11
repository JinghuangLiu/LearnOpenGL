//
// Created by yangyk on 2021/4/24.
//

#include "XSQuaternion.h"

#include "XSMatrix.h"
#include "XSVector3.h"
#include "XSVector4.h"

#include <math.h>

namespace xscore
{
    XSQuaternion::XSQuaternion()
    {
        this->w = 1;
        this->x = 0;
        this->y = 0;
        this->z = 0;
    }

    XSQuaternion::XSQuaternion(float w, float x, float y, float z)
    {
        this->w = w;
        this->x = x;
        this->y = y;
        this->z = z;
    }

    const XSQuaternion& XSQuaternion::identity()
    {
        static XSQuaternion q(1, 0, 0, 0);
        return q;
    }

    /* 四元数的乘法并不是旋转效果的叠加，
    void XSQuaternion::multiply(XSQuaternion& result, const XSQuaternion& left, const XSQuaternion& right)
    {
        result.w = left.w * right.w - left.x * right.x - left.y * right.y - left.z * right.z;
        result.x = left.w * right.x + left.x * right.w + left.y * right.z - left.z * right.y;
        result.y = left.w * right.y - left.x * right.z + left.y * right.w + left.z + right.x;
        result.z = left.w * right.z + left.x * right.y - left.y * right.x + left.z * right.w;
    }
     */

    void XSQuaternion::scale(float scale)
    {
        this->w *= scale;
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
    }

    float XSQuaternion::length() const
    {
        return sqrtf(this->w * this->w + this->x * this->x + this->y * this->y + this->z * this->z);
    }

    float XSQuaternion::dot(const XSQuaternion& q) const
    {
        const XSQuaternion& s = *this;
        return s.w * q.w + s.x * q.x + s.y * q.y + s.z * q.z;
    }

    XSQuaternion XSQuaternion::operator+(const XSQuaternion& q) const
    {
        return XSQuaternion(this->w + q.w, this->x + q.x, this->y + q.y, this->z + q.z);
    }

    XSQuaternion XSQuaternion::operator-(const XSQuaternion& q) const
    {
        return XSQuaternion(this->w - q.w, this->x - q.x, this->y - q.y, this->z - q.z);
    }

    XSQuaternion XSQuaternion::operator*(float scale) const
    {
        return XSQuaternion(this->w * scale, this->x * scale, this->y * scale, this->z * scale);
    }

    XSQuaternion XSQuaternion::operator/(float scale) const
    {
        return XSQuaternion(this->w / scale, this->x / scale, this->y / scale, this->z / scale);
    }

    XSQuaternion XSQuaternion::slerp(const XSQuaternion& q, float t, bool detour) const
    {
        t = fminf(1.0f, t);
        t = fmaxf(0.0f, t);

        XSQuaternion s = *this;
        XSQuaternion d = q;
        s.normalize();
        d.normalize();

        //计算夹角
        float dot = s.dot(d);
        if ((dot < 0 && !detour) || (dot > 0 && detour))
        {//将四元数取反，得到另一条路径
            s.scale(-1.0f);
            dot = s.dot(d);
        }

        float len1 = s.length();
        float len2 = d.length();
        float theta = acosf(dot / (len1 * len2));

        if (fabsf(theta) < 0.01f)
        {//角度很小，使用线性插值
            XSQuaternion r = s * (1.0f - t) + d * t;
            r.normalize();
            return r;
        }
        else
        {//角度不小，使用球面插值
            XSQuaternion r = (s * sinf((1.0f - t) * theta) + d * sinf(t * theta)) / sinf(theta);
            return r;
        }
    }

    void XSQuaternion::normalize()
    {
        float length = sqrtf(this->w * this->w + this->x * this->x + this->y * this->y + this->z * this->z);
        float scale = 1.0f / length;
        this->w *= scale;
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
    };

    void XSQuaternion::makeIdentity()
    {
        this->w = 1;
        this->x = 0;
        this->y = 0;
        this->z = 0;
    }

    void XSQuaternion::makeFromMatrix(const XSMatrix& m)
    {
        //注意OpenGL的矩阵是列向量矩阵。
        this->w = 0.5f * sqrt(1.0f + m.m[0] + m.m[5] + m.m[10]);
        this->x = (m.m[6] - m.m[9]) / (4.0f * this->w);
        this->y = (m.m[8] - m.m[2]) / (4.0f * this->w);
        this->z = (m.m[1] - m.m[4]) / (4.0f * this->w);
    }

    void XSQuaternion::makeFromAxisAngle(const XSVector3& v, float radian)
    {
        XSVector3 vec3 = v;
        vec3.normalize();
        this->w = cosf(radian / 2);
        this->x = vec3.x * sinf(radian / 2);
        this->y = vec3.y * sinf(radian / 2);
        this->z = vec3.z * sinf(radian / 2);
    }

    void XSQuaternion::makeFromAxisAngle(float x, float y, float z, float radian)
    {
        XSVector3 v(x, y, z);
        makeFromAxisAngle(v, radian);
    }

    void XSQuaternion::makeFromAxisAngle(const XSVector4& v, float radian)
    {
        XSVector3 vec3(v.x, v.y, v.z);
        makeFromAxisAngle(vec3, radian);
    }
}