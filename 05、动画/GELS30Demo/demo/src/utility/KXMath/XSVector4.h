//
// Created by wakeyang on 2018/2/23.
//

#ifndef XSPRITE_XSVECTOR4_H
#define XSPRITE_XSVECTOR4_H

//#include "../../XSPlatform.h"

namespace xscore
{
    class XSVector4
    {
    public:
        float x;
        float y;
        float z;
        float w;

    public:
        XSVector4();

        XSVector4(float x, float y, float z, float w);

    public:
        void set(float x, float y, float z, float w);

        void set(const float* value);

        void scale(float scale);

        void normalize();

        float length() const;

        XSVector4 operator+(const XSVector4& vec4) const;

        XSVector4 operator-(const XSVector4& vec4) const;

        XSVector4 operator*(float scale) const;

        XSVector4 operator/(float scale) const;

        float& operator[](int index);

        static float length(float x, float y, float z, float w);

        static float length(const XSVector4& v);

        static XSVector4 normalize(float x, float y, float z, float w);

        static XSVector4 normalize(const XSVector4& v);
    };

    inline XSVector4 XSColorFromInteger(int color)
    {
        union Color
        {
            int color;
            char bgra[4];
        };

        Color c;
        c.color = color;

        return XSVector4(1.0f * c.bgra[2] / 255.0f, 1.0f * c.bgra[1] / 255.0f, 1.0f * c.bgra[0] / 255.0f, 1.0f * c.bgra[3] / 255.0f);
    }
}

#endif //XSPRITE_XSVECTOR4_H
