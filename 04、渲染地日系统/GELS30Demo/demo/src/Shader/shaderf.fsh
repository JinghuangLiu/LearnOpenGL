varying mediump vec2 varyTextCoord; //顶点着色器传递过来的纹理坐标
//uniform samplerCube ourTexture;
uniform sampler2D ourTexture;
void main()
{
    gl_FragColor = texture2D(ourTexture,varyTextCoord);
//    gl_FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
