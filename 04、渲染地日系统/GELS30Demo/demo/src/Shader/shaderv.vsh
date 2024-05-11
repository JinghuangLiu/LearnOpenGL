

//attribute vec4 position;
//attribute vec4 vertexNormal; // 法线
//attribute mediump vec2 textCoordinate; //纹理坐标
//varying mediump vec4 varyVertexNormal;
//varying mediump vec2 varyTextCoord; //传递给片元着色器纹理坐标

#version 330 core
layout (location = 0) in vec4 position;
layout (location = 1) in vec4 vertexNormal; // 法线
layout (location = 2) in mediump vec2 textCoordinate; //纹理坐标
out mediump vec4 varyVertexNormal;
out mediump vec2 varyTextCoord; //传递给片元着色器纹理坐标

uniform mat4 projectionMatrix; //投影矩阵
uniform mat4 view; // 视图矩阵
uniform mat4 model; // 模型矩阵
uniform mat4 modelViewMatrix;  //模型视图矩阵

void main()
{
    varyVertexNormal = vertexNormal;
    varyTextCoord = textCoordinate;
    gl_Position = projectionMatrix * view * model * position;
}
