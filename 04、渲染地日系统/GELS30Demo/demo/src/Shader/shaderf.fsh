
varying lowp vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标
void main()
{
    gl_FragColor = vec4(varyTextCoord.x, varyTextCoord.y, 0.2, 1.0);
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
