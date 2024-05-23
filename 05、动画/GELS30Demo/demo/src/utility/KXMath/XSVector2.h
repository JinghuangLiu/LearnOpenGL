//
// Created by wakeyang on 2018/2/23.
//

#ifndef XSPRITE_XSVECTOR2_H
#define XSPRITE_XSVECTOR2_H

//#include "../../XSPlatform.h"

namespace xscore
{
    class XSVector2
    {
    public:
        float x;
        float y;

    public:
        XSVector2();

        XSVector2(float x, float y);

    public:
        void set(float x, float y);

        void set(const float* value);

        void scale(float scale);

        void normalize();

        float length() const;

        XSVector2 operator+(const XSVector2& vec2) const;

        XSVector2 operator-(const XSVector2& vec2) const;

        XSVector2 operator*(float scale) const;

        XSVector2 operator/(float scale) const;

        float& operator[](int index);

        static float length(float x, float y);

        static float length(const XSVector2& v);

        static XSVector2 normalize(float x, float y);

        static XSVector2 normalize(const XSVector2& v);
    };
}

#endif //XSPRITE_XSVECTOR3_H
