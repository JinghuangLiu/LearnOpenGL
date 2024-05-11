//varying mediump vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标

#version 300 es
in mediump vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标
out mediump vec4 FragColor;

uniform sampler2D ourTexture;  //纹理数据：在OpenGL程序代码中设定这个变量

void main()
{
//    gl_FragColor = texture2D(ourTexture,varyTextCoord);
    FragColor = texture(ourTexture,varyTextCoord);
//    gl_FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
