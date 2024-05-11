//
// Created by wakeyang on 2018/2/23.
//

#include "XSVector4.h"

#include <math.h>

namespace xscore
{
    XSVector4::XSVector4()
    {
        this->x = 0;
        this->y = 0;
        this->z = 0;
        this->w = 0;
    }

    XSVector4::XSVector4(float x, float y, float z, float w)
    {
        this->x = x;
        this->y = y;
        this->z = z;
        this->w = w;
    }

    void XSVector4::set(float x, float y, float z, float w)
    {
        this->x = x;
        this->y = y;
        this->z = z;
        this->w = w;
    }

    void XSVector4::set(const float* value)
    {
        this->x = value[0];
        this->y = value[1];
        this->z = value[2];
        this->w = value[3];
    }

    void XSVector4::scale(float scale)
    {
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
        this->w *= scale;
    }

    void XSVector4::normalize()
    {
        float scale = 1.0f / length(x, y, z, w);
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
        this->w *= scale;
    }

    float XSVector4::length() const
    {
        return sqrtf(this->x * this->x + this->y * this->y + this->z * this->z + this->w * this->w);
    }

    XSVector4 XSVector4::operator+(const XSVector4& vec4) const
    {
        return XSVector4(this->x + vec4.x, this->y + vec4.y, this->z + vec4.z, this->w + vec4.w);
    }

    XSVector4 XSVector4::operator-(const XSVector4& vec4) const
    {
        return XSVector4(this->x - vec4.x, this->y - vec4.y, this->z - vec4.z, this->w - vec4.w);
    }

    XSVector4 XSVector4::operator*(float scale) const
    {
        return XSVector4(this->x * scale, this->y * scale, this->z * scale, this->w * scale);
    }

    XSVector4 XSVector4::operator/(float scale) const
    {
        return XSVector4(this->x / scale, this->y / scale, this->z / scale, this->w / scale);
    }

    float& XSVector4::operator[](int index)
    {
        static float error = -9999.99f;
        switch (index)
        {
            case 0:
                return x;
            case 1:
                return y;
            case 2:
                return z;
            case 3:
                return w;
            default:
                return error;
        }
    }

    float XSVector4::length(float x, float y, float z, float w)
    {
        return sqrtf(x * x + y * y + z * z + w * w);
    }

    float XSVector4::length(const XSVector4& v)
    {
        return length(v.x, v.y, v.z, v.w);
    }

    XSVector4 XSVector4::normalize(float x, float y, float z, float w)
    {
        float scale = 1.0f / length(x, y, z, w);
        return XSVector4(x * scale, y * scale, z * scale, w * scale);
    }

    XSVector4 XSVector4::normalize(const XSVector4& v)
    {
        float scale = 1.0f / length(v);
        return XSVector4(v.x * scale, v.y * scale, v.z * scale, v.w * scale);
    }
}