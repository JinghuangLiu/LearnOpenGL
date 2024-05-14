
//2.0写法
//varying mediump vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标

//3.0写法
#version 300 core
in mediump vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标
out mediump vec4 FragColor;

uniform sampler2D ourTexture;  //纹理数据：在OpenGL程序代码中设定这个变量

void main()
{
    //2.0写法
//    gl_FragColor = texture2D(ourTexture,varyTextCoord);
//    gl_FragColor = vec4(1.0, 0.5, 0.2, 1.0);
    
    //3.0写法
    FragColor = texture(ourTexture,varyTextCoord);
//    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
