attribute vec4 position;
uniform mat4 projectionMatrix; //投影矩阵
uniform mat4 modelViewMatrix;  //模型视图矩阵

void main()
{
    gl_Position = projectionMatrix * modelViewMatrix * position;
}
