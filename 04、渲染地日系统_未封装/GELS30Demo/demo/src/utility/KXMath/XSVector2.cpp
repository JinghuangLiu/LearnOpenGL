//
// Created by wakeyang on 2018/2/23.
//

#include "XSVector2.h"

#include <math.h>

namespace xscore
{
    XSVector2::XSVector2()
    {
        this->x = 0;
        this->y = 0;
    }

    XSVector2::XSVector2(float x, float y)
    {
        this->x = x;
        this->y = y;
    }

    void XSVector2::set(float x, float y)
    {
        this->x = x;
        this->y = y;
    }

    void XSVector2::set(const float* value)
    {
        this->x = value[0];
        this->y = value[1];
    }

    void XSVector2::scale(float scale)
    {
        this->x *= scale;
        this->y *= scale;
    }

    void XSVector2::normalize()
    {
        float scale = 1.0f / length(x, y);
        this->x *= scale;
        this->y *= scale;
    }

    float XSVector2::length() const
    {
        return sqrtf(this->x * this->x + this->y * this->y);
    }

    XSVector2 XSVector2::operator+(const XSVector2& vec2) const
    {
        return XSVector2(this->x + vec2.x, this->y + vec2.y);
    }

    XSVector2 XSVector2::operator-(const XSVector2& vec2) const
    {
        return XSVector2(this->x - vec2.x, this->y - vec2.y);
    }

    XSVector2 XSVector2::operator*(float scale) const
    {
        return XSVector2(this->x * scale, this->y * scale);
    }

    XSVector2 XSVector2::operator/(float scale) const
    {
        return XSVector2(this->x / scale, this->y / scale);
    }

    float& XSVector2::operator[](int index)
    {
        static float error = -9999.99f;
        switch (index)
        {
            case 0:
                return x;
            case 1:
                return y;
            default:
                return error;
        }
    }

    float XSVector2::length(float x, float y)
    {
        return sqrtf(x * x + y * y);
    }

    float XSVector2::length(const XSVector2& v)
    {
        return length(v.x, v.y);
    }

    XSVector2 XSVector2::normalize(float x, float y)
    {
        float scale = 1.0f / length(x, y);
        return XSVector2(x * scale, y * scale);
    }

    XSVector2 XSVector2::normalize(const XSVector2& v)
    {
        float scale = 1.0f / length(v);
        return XSVector2(v.x * scale, v.y * scale);
    }
}
