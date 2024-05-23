//
//  GLESMath.c
//
//  Created by kesalin@gmail.com on 12-11-26.
//  Copyright (c) 2012 Äê http://blog.csdn.net/kesalin/. All rights reserved.
//

#include "GLESMath.h"
#include <stdlib.h>
#include <math.h>

void * memcpy(void *, const void *, size_t);
void * memset(void *, int, size_t);

//
// Matrix math utils
//

void ksScale(KSMatrix4 *result, GLfloat sx, GLfloat sy, GLfloat sz)
{
    result->m[0][0] *= sx;
    result->m[0][1] *= sx;
    result->m[0][2] *= sx;
    result->m[0][3] *= sx;
    
    result->m[1][0] *= sy;
    result->m[1][1] *= sy;
    result->m[1][2] *= sy;
    result->m[1][3] *= sy;
    
    result->m[2][0] *= sz;
    result->m[2][1] *= sz;
    result->m[2][2] *= sz;
    result->m[2][3] *= sz;
}

void ksTranslate(KSMatrix4 *result, GLfloat tx, GLfloat ty, GLfloat tz)
{
    result->m[3][0] += (result->m[0][0] * tx + result->m[1][0] * ty + result->m[2][0] * tz);
    result->m[3][1] += (result->m[0][1] * tx + result->m[1][1] * ty + result->m[2][1] * tz);
    result->m[3][2] += (result->m[0][2] * tx + result->m[1][2] * ty + result->m[2][2] * tz);
    result->m[3][3] += (result->m[0][3] * tx + result->m[1][3] * ty + result->m[2][3] * tz);
}

void ksRotate(KSMatrix4 *result, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
    GLfloat sinAngle, cosAngle;
    GLfloat mag = sqrtf(x * x + y * y + z * z);
    
    sinAngle = sinf ( angle * M_PI / 180.0f );
    cosAngle = cosf ( angle * M_PI / 180.0f );
    if ( mag > 0.0f )
    {
        GLfloat xx, yy, zz, xy, yz, zx, xs, ys, zs;
        GLfloat oneMinusCos;
        KSMatrix4 rotMat;
        
        x /= mag;
        y /= mag;
        z /= mag;
        
        xx = x * x;
        yy = y * y;
        zz = z * z;
        xy = x * y;
        yz = y * z;
        zx = z * x;
        xs = x * sinAngle;
        ys = y * sinAngle;
        zs = z * sinAngle;
        oneMinusCos = 1.0f - cosAngle;
        
        rotMat.m[0][0] = (oneMinusCos * xx) + cosAngle;
        rotMat.m[0][1] = (oneMinusCos * xy) - zs;
        rotMat.m[0][2] = (oneMinusCos * zx) + ys;
        rotMat.m[0][3] = 0.0F; 
        
        rotMat.m[1][0] = (oneMinusCos * xy) + zs;
        rotMat.m[1][1] = (oneMinusCos * yy) + cosAngle;
        rotMat.m[1][2] = (oneMinusCos * yz) - xs;
        rotMat.m[1][3] = 0.0F;
        
        rotMat.m[2][0] = (oneMinusCos * zx) - ys;
        rotMat.m[2][1] = (oneMinusCos * yz) + xs;
        rotMat.m[2][2] = (oneMinusCos * zz) + cosAngle;
        rotMat.m[2][3] = 0.0F; 
        
        rotMat.m[3][0] = 0.0F;
        rotMat.m[3][1] = 0.0F;
        rotMat.m[3][2] = 0.0F;
        rotMat.m[3][3] = 1.0F;
        
        ksMatrixMultiply( result, &rotMat, result );
    }
}

void ksMatrixMultiply(KSMatrix4 *result, const KSMatrix4 *srcA, const KSMatrix4 *srcB)
{
    KSMatrix4    tmp;
    int         i;
    
	for (i=0; i<4; i++)
	{
		tmp.m[i][0] =	(srcA->m[i][0] * srcB->m[0][0]) +
        (srcA->m[i][1] * srcB->m[1][0]) +
        (srcA->m[i][2] * srcB->m[2][0]) +
        (srcA->m[i][3] * srcB->m[3][0]) ;
        
		tmp.m[i][1] =	(srcA->m[i][0] * srcB->m[0][1]) + 
        (srcA->m[i][1] * srcB->m[1][1]) +
        (srcA->m[i][2] * srcB->m[2][1]) +
        (srcA->m[i][3] * srcB->m[3][1]) ;
        
		tmp.m[i][2] =	(srcA->m[i][0] * srcB->m[0][2]) + 
        (srcA->m[i][1] * srcB->m[1][2]) +
        (srcA->m[i][2] * srcB->m[2][2]) +
        (srcA->m[i][3] * srcB->m[3][2]) ;
        
		tmp.m[i][3] =	(srcA->m[i][0] * srcB->m[0][3]) + 
        (srcA->m[i][1] * srcB->m[1][3]) +
        (srcA->m[i][2] * srcB->m[2][3]) +
        (srcA->m[i][3] * srcB->m[3][3]) ;
	}
    
    memcpy(result, &tmp, sizeof(KSMatrix4));
}

void ksCopyMatrix4(KSMatrix4 * target, const KSMatrix4 * src)
{
    memcpy(target, src, sizeof(KSMatrix4));
}

void ksMatrix4ToMatrix3(KSMatrix3 * t, const KSMatrix4 * src)
{
    t->m[0][0] = src->m[0][0];
    t->m[0][1] = src->m[0][1];
    t->m[0][2] = src->m[0][2];
    t->m[1][0] = src->m[1][0];
    t->m[1][1] = src->m[1][1];
    t->m[1][2] = src->m[1][2];
    t->m[2][0] = src->m[2][0];
    t->m[2][1] = src->m[2][1];
    t->m[2][2] = src->m[2][2];
}

void ksMatrixLoadIdentity(KSMatrix4 *result)
{
    memset(result, 0x0, sizeof(KSMatrix4));

    result->m[0][0] = 1.0f;
    result->m[1][1] = 1.0f;
    result->m[2][2] = 1.0f;
    result->m[3][3] = 1.0f;
}

void ksFrustum(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    KSMatrix4    frust;
    
    if ( (nearZ <= 0.0f) || (farZ <= 0.0f) ||
        (deltaX <= 0.0f) || (deltaY <= 0.0f) || (deltaZ <= 0.0f) )
        return;
    
    frust.m[0][0] = 2.0f * nearZ / deltaX;
    frust.m[0][1] = frust.m[0][2] = frust.m[0][3] = 0.0f;
    
    frust.m[1][1] = 2.0f * nearZ / deltaY;
    frust.m[1][0] = frust.m[1][2] = frust.m[1][3] = 0.0f;
    
    frust.m[2][0] = (right + left) / deltaX;
    frust.m[2][1] = (top + bottom) / deltaY;
    frust.m[2][2] = -(nearZ + farZ) / deltaZ;
    frust.m[2][3] = -1.0f;
    
    frust.m[3][2] = -2.0f * nearZ * farZ / deltaZ;
    frust.m[3][0] = frust.m[3][1] = frust.m[3][3] = 0.0f;
    
    ksMatrixMultiply(result, &frust, result);
}

void ksPerspective(KSMatrix4 *result, float fovy, float aspect, float nearZ, float farZ)
{
    GLfloat frustumW, frustumH;
    
    frustumH = tanf( fovy / 360.0f * M_PI ) * nearZ;
    frustumW = frustumH * aspect;
    
    ksFrustum( result, -frustumW, frustumW, -frustumH, frustumH, nearZ, farZ );
}

void ksOrtho(KSMatrix4 *result, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    KSMatrix4    ortho;
    
    if ( (deltaX == 0.0f) || (deltaY == 0.0f) || (deltaZ == 0.0f) )
        return;
    
    ksMatrixLoadIdentity(&ortho);
    ortho.m[0][0] = 2.0f / deltaX;
    ortho.m[3][0] = -(right + left) / deltaX;
    ortho.m[1][1] = 2.0f / deltaY;
    ortho.m[3][1] = -(top + bottom) / deltaY;
    ortho.m[2][2] = -2.0f / deltaZ;
    ortho.m[3][2] = -(nearZ + farZ) / deltaZ;
    
    ksMatrixMultiply(result, &ortho, result);
}


KSMatrix4 ksLookAt(float eyeX, float eyeY, float eyeZ,
              float centerX, float centerY, float centerZ,
         float upX, float upY, float upZ) {
    KSMatrix4 result;
    ksMatrixLoadIdentity(&result);
    GLfloat f[3], s[3], u[3];
    f[0] = centerX - eyeX;
    f[1] = centerY - eyeY;
    f[2] = centerZ - eyeZ;
    normalize(f);
    GLfloat tempUp[3];
    tempUp[0] = upX;
    tempUp[1] = upY;
    tempUp[2] = upZ;
    cross(f, tempUp, s);
    normalize(s);
    cross(s, f, u);
    
    GLfloat tempEye[3];
    tempEye[0] = eyeX;
    tempEye[1] = eyeY;
    tempEye[2] = eyeZ;
    
    result.m[0][0] = s[0];
    result.m[0][1] = u[0];
    result.m[0][2] = -f[0];
    result.m[1][0] = s[1];
    result.m[1][1] = u[1];
    result.m[1][2] = -f[1];
    result.m[2][0] = s[2];
    result.m[2][1] = u[2];
    result.m[2][2] = -f[2];
    result.m[3][0] = -dot(s, tempEye);
    result.m[3][1] = -dot(u, tempEye);
    result.m[3][2] = dot(f, tempEye);
    return result;
    
}

//KSMatrix4 lookAt(const float* eye, const float* center, const float* up) {
//    KSMatrix4 result;
//    float f[3], s[3], u[3];
//    for (int i = 0; i < 3; i++) {
//        f[i] = center[i] - eye[i];
//    }
//    normalize(f);
//    cross(f, up, s);
//    normalize(s);
//    cross(s, f, u);
//    
//    result.m[0] = s[0];
//    result.m[1] = u[0];
//    result.m[2] = -f[0];
//    result.m[4] = s[1];
//    result.m[5] = u[1];
//    result.m[6] = -f[1];
//    result.m[8] = s[2];
//    result.m[9] = u[2];
//    result.m[10] = -f[2];
//    result.m[12] = -dot(s, eye);
//    result.m[13] = -dot(u, eye);
//    result.m[14] = dot(f, eye);
//    
//    return result;
//}

void normalize(float* v) {
    float length = sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    v[0] /= length;
    v[1] /= length;
    v[2] /= length;
}

void cross(const float* a, const float* b, float* result) {
    result[0] = a[1] * b[2] - a[2] * b[1];
    result[1] = a[2] * b[0] - a[0] * b[2];
    result[2] = a[0] * b[1] - a[1] * b[0];
}

float dot(const float* a, const float* b) {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}
