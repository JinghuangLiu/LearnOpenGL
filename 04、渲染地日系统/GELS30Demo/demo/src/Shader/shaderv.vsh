attribute vec4 position;
uniform mat4 projectionMatrix; //投影矩阵
uniform mat4 modelViewMatrix;  //模型视图矩阵
attribute vec2 textCoordinate; //纹理坐标
varying lowp vec2 varyTextCoord; //传递给片元着色器纹理坐标
void main()
{
    varyTextCoord = textCoordinate;
    gl_Position = projectionMatrix * modelViewMatrix * position;
}
