//
// Created by wakeyang on 2018/2/23.
//

#include "XSVector3.h"

#include <math.h>

namespace xscore
{
    XSVector3::XSVector3()
    {
        this->x = 0;
        this->y = 0;
        this->z = 0;
    }

    XSVector3::XSVector3(float x, float y, float z)
    {
        this->x = x;
        this->y = y;
        this->z = z;
    }

    void XSVector3::set(float x, float y, float z)
    {
        this->x = x;
        this->y = y;
        this->z = z;
    }

    void XSVector3::set(const float* value)
    {
        this->x = value[0];
        this->y = value[1];
        this->z = value[2];
    }

    void XSVector3::scale(float scale)
    {
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
    }

    void XSVector3::normalize()
    {
        float scale = 1.0f / length(x, y, z);
        this->x *= scale;
        this->y *= scale;
        this->z *= scale;
    }

    float XSVector3::length() const
    {
        return sqrtf(this->x * this->x + this->y * this->y + this->z * this->z);
    }

    XSVector3 XSVector3::operator+(const XSVector3& vec3) const
    {
        return XSVector3(this->x + vec3.x, this->y + vec3.y, this->z + vec3.z);
    }

    XSVector3 XSVector3::operator-(const XSVector3& vec3) const
    {
        return XSVector3(this->x - vec3.x, this->y - vec3.y, this->z - vec3.z);
    }

    XSVector3 XSVector3::operator*(float scale) const
    {
        return XSVector3(this->x * scale, this->y * scale, this->z * scale);
    }

    XSVector3 XSVector3::operator/(float scale) const
    {
        return XSVector3(this->x / scale, this->y / scale, this->z / scale);
    }

    float& XSVector3::operator[](int index)
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
            default:
                return error;
        }
    }

    float XSVector3::length(float x, float y, float z)
    {
        return sqrtf(x * x + y * y + z * z);
    }

    float XSVector3::length(const XSVector3& v)
    {
        return length(v.x, v.y, v.z);
    }

    XSVector3 XSVector3::normalize(float x, float y, float z)
    {
        float scale = 1.0f / length(x, y, z);
        return XSVector3(x * scale, y * scale, z * scale);
    }

    XSVector3 XSVector3::normalize(const XSVector3& v)
    {
        float scale = 1.0f / length(v);
        return XSVector3(v.x * scale, v.y * scale, v.z * scale);
    }
}
