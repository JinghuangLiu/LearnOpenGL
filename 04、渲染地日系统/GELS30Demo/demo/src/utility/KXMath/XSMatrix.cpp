//
// Created by yangyk on 2018/2/14.
//

#include "XSMatrix.h"

#include "XSVector3.h"
#include "XSVector4.h"
#include "XSQuaternion.h"

namespace xscore
{
    static const float MATRIX_IDENTITY[16] =
            {
                    1.0f, 0.0f, 0.0f, 0.0f,
                    0.0f, 1.0f, 0.0f, 0.0f,
                    0.0f, 0.0f, 1.0f, 0.0f,
                    0.0f, 0.0f, 0.0f, 1.0f
            };

    XSMatrix::XSMatrix()
    {
        memcpy(this->m, MATRIX_IDENTITY, MATRIX_SIZE);
    }

    XSMatrix::XSMatrix(const float* m)
    {
        memcpy(this->m, m, MATRIX_SIZE);
    }

    void XSMatrix::set(const float* m)
    {
        memcpy(this->m, m, MATRIX_SIZE);
    }

    bool XSMatrix::invert(XSMatrix& out)
    {
        // transpose matrix
        float src0 = m[0];
        float src4 = m[1];
        float src8 = m[2];
        float src12 = m[3];

        float src1 = m[4];
        float src5 = m[5];
        float src9 = m[6];
        float src13 = m[7];

        float src2 = m[8];
        float src6 = m[9];
        float src10 = m[10];
        float src14 = m[11];

        float src3 = m[12];
        float src7 = m[13];
        float src11 = m[14];
        float src15 = m[15];

        // calculate pairs for first 8 elements (cofactors)
        float atmp0 = src10 * src15;
        float atmp1 = src11 * src14;
        float atmp2 = src9 * src15;
        float atmp3 = src11 * src13;
        float atmp4 = src9 * src14;
        float atmp5 = src10 * src13;
        float atmp6 = src8 * src15;
        float atmp7 = src11 * src12;
        float atmp8 = src8 * src14;
        float atmp9 = src10 * src12;
        float atmp10 = src8 * src13;
        float atmp11 = src9 * src12;

        // calculate first 8 elements (cofactors)
        float dst0 = (atmp0 * src5 + atmp3 * src6 + atmp4 * src7) - (atmp1 * src5 + atmp2 * src6 + atmp5 * src7);
        float dst1 = (atmp1 * src4 + atmp6 * src6 + atmp9 * src7) - (atmp0 * src4 + atmp7 * src6 + atmp8 * src7);
        float dst2 = (atmp2 * src4 + atmp7 * src5 + atmp10 * src7) - (atmp3 * src4 + atmp6 * src5 + atmp11 * src7);
        float dst3 = (atmp5 * src4 + atmp8 * src5 + atmp11 * src6) - (atmp4 * src4 + atmp9 * src5 + atmp10 * src6);
        float dst4 = (atmp1 * src1 + atmp2 * src2 + atmp5 * src3) - (atmp0 * src1 + atmp3 * src2 + atmp4 * src3);
        float dst5 = (atmp0 * src0 + atmp7 * src2 + atmp8 * src3) - (atmp1 * src0 + atmp6 * src2 + atmp9 * src3);
        float dst6 = (atmp3 * src0 + atmp6 * src1 + atmp11 * src3) - (atmp2 * src0 + atmp7 * src1 + atmp10 * src3);
        float dst7 = (atmp4 * src0 + atmp9 * src1 + atmp10 * src2) - (atmp5 * src0 + atmp8 * src1 + atmp11 * src2);

        // calculate pairs for second 8 elements (cofactors)
        float btmp0 = src2 * src7;
        float btmp1 = src3 * src6;
        float btmp2 = src1 * src7;
        float btmp3 = src3 * src5;
        float btmp4 = src1 * src6;
        float btmp5 = src2 * src5;
        float btmp6 = src0 * src7;
        float btmp7 = src3 * src4;
        float btmp8 = src0 * src6;
        float btmp9 = src2 * src4;
        float btmp10 = src0 * src5;
        float btmp11 = src1 * src4;

        // calculate second 8 elements (cofactors)
        float dst8 = (btmp0 * src13 + btmp3 * src14 + btmp4 * src15) - (btmp1 * src13 + btmp2 * src14 + btmp5 * src15);
        float dst9 = (btmp1 * src12 + btmp6 * src14 + btmp9 * src15) - (btmp0 * src12 + btmp7 * src14 + btmp8 * src15);
        float dst10 = (btmp2 * src12 + btmp7 * src13 + btmp10 * src15) - (btmp3 * src12 + btmp6 * src13 + btmp11 * src15);
        float dst11 = (btmp5 * src12 + btmp8 * src13 + btmp11 * src14) - (btmp4 * src12 + btmp9 * src13 + btmp10 * src14);
        float dst12 = (btmp2 * src10 + btmp5 * src11 + btmp1 * src9) - (btmp4 * src11 + btmp0 * src9 + btmp3 * src10);
        float dst13 = (btmp8 * src11 + btmp0 * src8 + btmp7 * src10) - (btmp6 * src10 + btmp9 * src11 + btmp1 * src8);
        float dst14 = (btmp6 * src9 + btmp11 * src11 + btmp3 * src8) - (btmp10 * src11 + btmp2 * src8 + btmp7 * src9);
        float dst15 = (btmp10 * src10 + btmp4 * src8 + btmp9 * src9) - (btmp8 * src9 + btmp11 * src10 + btmp5 * src8);

        // calculate determinant
        float det = src0 * dst0 + src1 * dst1 + src2 * dst2 + src3 * dst3;

        if (det == 0.0f)
        {
            return false;
        }

        // calculate matrix inverse
        float invdet = 1.0f / det;
        out.m[0] = dst0 * invdet;
        out.m[1] = dst1 * invdet;
        out.m[2] = dst2 * invdet;
        out.m[3] = dst3 * invdet;

        out.m[4] = dst4 * invdet;
        out.m[5] = dst5 * invdet;
        out.m[6] = dst6 * invdet;
        out.m[7] = dst7 * invdet;

        out.m[8] = dst8 * invdet;
        out.m[9] = dst9 * invdet;
        out.m[10] = dst10 * invdet;
        out.m[11] = dst11 * invdet;

        out.m[12] = dst12 * invdet;
        out.m[13] = dst13 * invdet;
        out.m[14] = dst14 * invdet;
        out.m[15] = dst15 * invdet;

        return true;
    }

    const XSMatrix& XSMatrix::identity()
    {
        static XSMatrix m(MATRIX_IDENTITY);
        return m;
    }

    void XSMatrix::multiply(XSMatrix& result, const XSMatrix& left, const XSMatrix& right)
    {
        //注意OpenGL的矩阵是列向量矩阵。
        result.m[0] = left.m[0] * right.m[0] + left.m[4] * right.m[1] + left.m[8] * right.m[2] + left.m[12] * right.m[3];
        result.m[4] = left.m[0] * right.m[4] + left.m[4] * right.m[5] + left.m[8] * right.m[6] + left.m[12] * right.m[7];
        result.m[8] = left.m[0] * right.m[8] + left.m[4] * right.m[9] + left.m[8] * right.m[10] + left.m[12] * right.m[11];
        result.m[12] = left.m[0] * right.m[12] + left.m[4] * right.m[13] + left.m[8] * right.m[14] + left.m[12] * right.m[15];

        result.m[1] = left.m[1] * right.m[0] + left.m[5] * right.m[1] + left.m[9] * right.m[2] + left.m[13] * right.m[3];
        result.m[5] = left.m[1] * right.m[4] + left.m[5] * right.m[5] + left.m[9] * right.m[6] + left.m[13] * right.m[7];
        result.m[9] = left.m[1] * right.m[8] + left.m[5] * right.m[9] + left.m[9] * right.m[10] + left.m[13] * right.m[11];
        result.m[13] = left.m[1] * right.m[12] + left.m[5] * right.m[13] + left.m[9] * right.m[14] + left.m[13] * right.m[15];

        result.m[2] = left.m[2] * right.m[0] + left.m[6] * right.m[1] + left.m[10] * right.m[2] + left.m[14] * right.m[3];
        result.m[6] = left.m[2] * right.m[4] + left.m[6] * right.m[5] + left.m[10] * right.m[6] + left.m[14] * right.m[7];
        result.m[10] = left.m[2] * right.m[8] + left.m[6] * right.m[9] + left.m[10] * right.m[10] + left.m[14] * right.m[11];
        result.m[14] = left.m[2] * right.m[12] + left.m[6] * right.m[13] + left.m[10] * right.m[14] + left.m[14] * right.m[15];

        result.m[3] = left.m[3] * right.m[0] + left.m[7] * right.m[1] + left.m[11] * right.m[2] + left.m[15] * right.m[3];
        result.m[7] = left.m[3] * right.m[4] + left.m[7] * right.m[5] + left.m[11] * right.m[6] + left.m[15] * right.m[7];
        result.m[11] = left.m[3] * right.m[8] + left.m[7] * right.m[9] + left.m[11] * right.m[10] + left.m[15] * right.m[11];
        result.m[15] = left.m[3] * right.m[12] + left.m[7] * right.m[13] + left.m[11] * right.m[14] + left.m[15] * right.m[15];
    }

    void XSMatrix::multiply(XSVector4& result, const XSMatrix& left, const XSVector4& right)
    {
        //注意OpenGL的矩阵是列向量矩阵。
        result.x = left.m[0] * right.x + left.m[4] * right.y + left.m[8] * right.z + left.m[12] * right.w;
        result.y = left.m[1] * right.x + left.m[5] * right.y + left.m[9] * right.z + left.m[13] * right.w;
        result.z = left.m[2] * right.x + left.m[6] * right.y + left.m[10] * right.z + left.m[14] * right.w;
        result.w = left.m[3] * right.x + left.m[7] * right.y + left.m[11] * right.z + left.m[15] * right.w;
    }

    void XSMatrix::makeIdentity()
    {
        set(MATRIX_IDENTITY);
    }

    void XSMatrix::makeFromQuaternion(const XSQuaternion& q)
    {
        //注意OpenGL的矩阵是列向量矩阵。
        this->m[0] = 1.0f - 2.0f * q.y * q.y - 2.0f * q.z * q.z;
        this->m[1] = 2.0f * q.x * q.y + 2.0f * q.z * q.w;
        this->m[2] = 2.0f * q.x * q.z - 2.0f * q.y * q.w;
        this->m[3] = 0;

        this->m[4] = 2.0f * q.x * q.y - 2.0f * q.z * q.w;
        this->m[5] = 1.0f - 2.0f * q.x * q.x - 2.0f * q.z * q.z;
        this->m[6] = 2.0f * q.y * q.z + 2.0f * q.x * q.w;
        this->m[7] = 0;

        this->m[8] = 2.0f * q.x * q.z + 2.0f * q.y * q.w;
        this->m[9] = 2.0f * q.y * q.z - 2.0f * q.x * q.w;
        this->m[10] = 1.0f - 2.0f * q.x * q.x - 2.0f * q.y * q.y;
        this->m[11] = 0;

        this->m[12] = 0;
        this->m[13] = 0;
        this->m[14] = 0;
        this->m[15] = 1;
    }

    void XSMatrix::makePerspective(float fovy, float aspect, float zNear, float zFar)
    {
        float field = 1.0f / tanf(fovy / 2);
        float range = 1.0f / (zNear - zFar);

        m[0] = field / aspect;
        m[1] = 0.0f;
        m[2] = 0.0f;
        m[3] = 0.0f;

        m[4] = 0.0f;
        m[5] = field;
        m[6] = 0.0f;
        m[7] = 0.0f;

        m[8] = 0.0f;
        m[9] = 0.0f;
        m[10] = (zFar + zNear) * range;
        m[11] = -1.0f;

        m[12] = 0.0f;
        m[13] = 0.0f;
        m[14] = 2.0f * zFar * zNear * range;
        m[15] = 0.0f;
    }

    void XSMatrix::makeOrtho2D(float left, float right, float bottom, float top, float near, float far)
    {
        if (left == right)
        {
            //xscore::q2loge("matrix left == right");
            return;
        }
        if (bottom == top)
        {
            //xscore::q2loge("matrix bottom == top");
            return;
        }
        if (near == far)
        {
            //xscore::q2loge("matrix near == far");
            return;
        }

        float r_width = 1.0f / (right - left);
        float r_height = 1.0f / (top - bottom);
        float r_depth = 1.0f / (far - near);
        float x = 2.0f * (r_width);
        float y = 2.0f * (r_height);
        float z = -2.0f * (r_depth);
        float tx = -(right + left) * r_width;
        float ty = -(top + bottom) * r_height;
        float tz = -(far + near) * r_depth;
        m[0] = x;
        m[5] = y;
        m[10] = z;
        m[12] = tx;
        m[13] = ty;
        m[14] = tz;
        m[15] = 1.0f;
        m[1] = 0.0f;
        m[2] = 0.0f;
        m[3] = 0.0f;
        m[4] = 0.0f;
        m[6] = 0.0f;
        m[7] = 0.0f;
        m[8] = 0.0f;
        m[9] = 0.0f;
        m[11] = 0.0f;
    }

    void XSMatrix::makeLookAt(const XSVector3& pos, const XSVector3& to, const XSVector3& up)
    {
        return makeLookAt(pos.x, pos.y, pos.z, to.x, to.y, to.z, up.x, up.y, up.z);
    }

    void XSMatrix::makeLookAt(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ)
    {
        float fx = centerX - eyeX;
        float fy = centerY - eyeY;
        float fz = centerZ - eyeZ;

        // Normalize f
        float rlf = 1.0f / XSVector3::length(fx, fy, fz);
        fx *= rlf;
        fy *= rlf;
        fz *= rlf;

        // compute s = f x up (x means "cross product")
        float sx = fy * upZ - fz * upY;
        float sy = fz * upX - fx * upZ;
        float sz = fx * upY - fy * upX;

        // and normalize s
        float rls = 1.0f / XSVector3::length(sx, sy, sz);
        sx *= rls;
        sy *= rls;
        sz *= rls;

        // compute u = s x f
        float ux = sy * fz - sz * fy;
        float uy = sz * fx - sx * fz;
        float uz = sx * fy - sy * fx;

        m[0] = sx;
        m[1] = ux;
        m[2] = -fx;
        m[3] = 0.0f;

        m[4] = sy;
        m[5] = uy;
        m[6] = -fy;
        m[7] = 0.0f;

        m[8] = sz;
        m[9] = uz;
        m[10] = -fz;
        m[11] = 0.0f;

        m[12] = 0.0f;
        m[13] = 0.0f;
        m[14] = 0.0f;
        m[15] = 1.0f;

        float x = -eyeX;
        float y = -eyeY;
        float z = -eyeZ;
        for (int i = 0; i < 4; i++)
        {
            int mi = i;
            m[12 + mi] += m[mi] * x + m[4 + mi] * y + m[8 + mi] * z;
        }
    }

    void XSMatrix::makeScale(float x, float y, float z)
    {
        makeIdentity();
        for (int i = 0; i < 4; i++)
        {
            this->m[i] *= x;
            this->m[4 + i] *= y;
            this->m[8 + i] *= z;
        }
    }

    void XSMatrix::makeTranslate(float x, float y, float z)
    {
        makeIdentity();
        this->m[12] = x;
        this->m[13] = y;
        this->m[14] = z;
    }

    void XSMatrix::makeRotate(float radian, float x, float y, float z)
    {
        XSVector3 v = XSVector3::normalize(x, y, z);
        float _cos = cosf(radian);
        float _cosp = 1.0f - _cos;
        float _sin = sinf(radian);

        this->m[0] = _cos + _cosp * v.x * v.x;
        this->m[1] = _cosp * v.x * v.y + v.z * _sin;
        this->m[2] = _cosp * v.x * v.z - v.y * _sin;
        this->m[3] = 0.0f;
        this->m[4] = _cosp * v.x * v.y - v.z * _sin;
        this->m[5] = _cos + _cosp * v.y * v.y;
        this->m[6] = _cosp * v.y * v.z + v.x * _sin;
        this->m[7] = 0.0f;
        this->m[8] = _cosp * v.x * v.z + v.y * _sin;
        this->m[9] = _cosp * v.y * v.z - v.x * _sin;
        this->m[10] = _cos + _cosp * v.z * v.z;
        this->m[11] = 0.0f;
        this->m[12] = 0.0f;
        this->m[13] = 0.0f;
        this->m[14] = 0.0f;
        this->m[15] = 1.0f;
    }

    void XSMatrix::makeRotateX(float radian)
    {
        return makeRotate(radian, 1, 0, 0);
    }

    void XSMatrix::makeRotateY(float radian)
    {
        return makeRotate(radian, 0, 1, 0);
    }

    void XSMatrix::makeRotateZ(float radian)
    {
        return makeRotate(radian, 0, 0, 1);
    }

    void XSMatrix::applyScaleLeft(float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeScale(x, y, z);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyScaleRight(float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeScale(x, y, z);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyRotateLeft(float radian, float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeRotate(radian, x, y, z);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyRotateRight(float radian, float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeRotate(radian, x, y, z);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyRotateXLeft(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateX(radian);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyRotateYLeft(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateY(radian);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyRotateZLeft(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateZ(radian);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyQuaternionLeft(const XSQuaternion& q)
    {
        XSMatrix matrix;
        matrix.makeFromQuaternion(q);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyRotateXRight(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateX(radian);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyRotateYRight(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateY(radian);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyRotateZRight(float radian)
    {
        XSMatrix matrix;
        matrix.makeRotateZ(radian);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyQuaternionRight(const XSQuaternion& q)
    {
        XSMatrix matrix;
        matrix.makeFromQuaternion(q);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyTranslateLeft(float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeTranslate(x, y, z);
        applyMultiplyLeft(matrix);
    }

    void XSMatrix::applyTranslateRight(float x, float y, float z)
    {
        XSMatrix matrix;
        matrix.makeTranslate(x, y, z);
        applyMultiplyRight(matrix);
    }

    void XSMatrix::applyMultiplyLeft(const XSMatrix& mat)
    {
        XSMatrix right(*this);
        multiply(*this, mat, right);
    }

    void XSMatrix::applyMultiplyRight(const XSMatrix& mat)
    {
        XSMatrix left(*this);
        multiply(*this, left, mat);
    }
}