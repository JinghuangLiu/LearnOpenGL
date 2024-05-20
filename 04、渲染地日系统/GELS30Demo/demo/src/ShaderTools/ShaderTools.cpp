//
//  ShaderTools.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#include "ShaderTools.h"
#include <fstream>
#include <sstream>

//实现参考：https://learnopengl.com/Getting-started/Hello-Triangle
GLuint ShaderTools::createShaderProgram(const std::string &vertexShaderText,const std::string &fragmentShaderText) {
    
    std::string v = ShaderTools::readShader(vertexShaderText);
    std::string f = ShaderTools::readShader(fragmentShaderText);
    const char *vst = v.c_str();
    const char *fst = f.c_str();
    
    //1、编译顶点着色器
    GLuint vertexShaderHandle = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShaderHandle,1, &vst, NULL);
    glCompileShader(vertexShaderHandle);
    //检测是否编译成功
    GLint success;
    glGetShaderiv(vertexShaderHandle,GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(vertexShaderHandle,
                           512, NULL, infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
        return -1;
    }
    
    //2、编译片元着色器
    GLuint fragmentShaderHandle = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShaderHandle,1, &fst, NULL);
    glCompileShader(fragmentShaderHandle);
    glGetShaderiv(fragmentShaderHandle,GL_COMPILE_STATUS, &success);
    //检测是否编译成功
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(fragmentShaderHandle,
                           512, NULL, infoLog);
        std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
        return -1;
    }
    
    //3、着色器程序
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShaderHandle);
    glAttachShader(programHandle, fragmentShaderHandle);
    glLinkProgram(programHandle);
    //检测链接着色器程序是否成功
    glGetProgramiv(programHandle, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(programHandle,512, NULL, infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::COMPILATION_FAILED\n" << infoLog << std::endl;
        glDeleteProgram(programHandle);
        programHandle = -1;
        return -1;
    }
    
    //4、把着色器对象链接到程序对象以后，删除着色器对象
    glDeleteShader(vertexShaderHandle);
    glDeleteShader(fragmentShaderHandle);
    return programHandle;
}

std::string ShaderTools::readShader(const std::string &path) {
    // 从文件路径中获取顶点/片段着色器
    std::string source;
    std::ifstream shaderFile;
    // 保证ifstream对象可以抛出异常
    shaderFile.exceptions(std::ifstream::badbit);
    try
    {
        // 打开文件
        shaderFile.open(path);
        // 读取文件的缓冲内容到流中
        std::stringstream shaderStream;
        shaderStream << shaderFile.rdbuf();
        // 关闭文件
        shaderFile.close();
        // 转换流到GLchar数组
        source = shaderStream.str();
    }
    catch(const std::exception& e)
    {
        std::cout << "ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ"<< std::endl;
        return "";
    }
    
    return source;
}
