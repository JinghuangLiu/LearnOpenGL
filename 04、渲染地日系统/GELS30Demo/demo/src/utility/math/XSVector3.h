//
// Created by wakeyang on 2018/2/23.
//

#ifndef XSPRITE_XSVECTOR3_H
#define XSPRITE_XSVECTOR3_H

//#include "../../XSPlatform.h"

namespace xscore
{
    class XSVector3
    {
    public:
        float x;
        float y;
        float z;

    public:
        XSVector3();

        XSVector3(float x, float y, float z);

    public:
        void set(float x, float y, float z);

        void set(const float* value);

        void scale(float scale);

        void normalize();

        float length() const;

        XSVector3 operator+(const XSVector3& vec3) const;

        XSVector3 operator-(const XSVector3& vec3) const;

        XSVector3 operator*(float scale) const;

        XSVector3 operator/(float scale) const;

        float& operator[](int index);

        static float length(float x, float y, float z);

        static float length(const XSVector3& v);

        static XSVector3 normalize(float x, float y, float z);

        static XSVector3 normalize(const XSVector3& v);
    };
}

#endif //XSPRITE_XSVECTOR3_H
