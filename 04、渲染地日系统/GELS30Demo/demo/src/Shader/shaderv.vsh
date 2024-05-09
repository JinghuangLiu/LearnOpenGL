//#version 300 es
//layout (location = 0) in vec4 position;
attribute vec4 position;
uniform mat4 projectionMatrix; //投影矩阵
uniform mat4 view; // 视图矩阵
uniform mat4 model; // 模型矩阵
uniform mat4 modelViewMatrix;  //模型视图矩阵
attribute vec4 vertexNormal; // 法线
varying mediump vec4 varyVertexNormal;
attribute mediump vec2 textCoordinate; //纹理坐标
varying mediump vec2 varyTextCoord; //传递给片元着色器纹理坐标
void main()
{
    varyVertexNormal = vertexNormal;
    varyTextCoord = textCoordinate;
    gl_Position = projectionMatrix * view * model * position;
}
