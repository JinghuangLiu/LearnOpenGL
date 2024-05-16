//
//  ShaderTools.cpp
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#include "ShaderTools.h"
#include <fstream>
#include <sstream>
GLuint ShaderTools::buildProgram(const std::string &vertexShaderText,const std::string &fragmentShaderText) {
    std::string v = ShaderTools::readShader(vertexShaderText);
    std::string f = ShaderTools::readShader(fragmentShaderText);
    const char *vst = v.c_str();
    const char *fst = f.c_str();
    
    GLuint vertexShaderHandle = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShaderHandle,1, &vst, NULL);
    glCompileShader(vertexShaderHandle);
    GLint success;
    glGetShaderiv(vertexShaderHandle,GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(vertexShaderHandle,
                           512, NULL, infoLog);
        printf("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n:%s", infoLog);
        return -1;
    }

    GLuint fragmentShaderHandle = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShaderHandle,
                   1, &fst, NULL);
    glCompileShader(fragmentShaderHandle);
    glGetShaderiv(fragmentShaderHandle,
                  GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(fragmentShaderHandle,
                           512, NULL, infoLog);
        printf("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n:%s", infoLog);
        return -1;
    }

    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShaderHandle);
    glAttachShader(programHandle, fragmentShaderHandle);
    glLinkProgram(programHandle);

    glGetProgramiv(programHandle, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(programHandle,
                            512, NULL, infoLog);
        printf("ERROR::SHADER::PROGRAM::COMPILATION_FAILED\n:%s", infoLog);
        glDeleteProgram(programHandle);
        programHandle = -1;
        return -1;
    }
    glDeleteShader(vertexShaderHandle);
    glDeleteShader(fragmentShaderHandle);
    return programHandle;
}

std::string ShaderTools::readShader(const std::string &path) {
    // 1. 从文件路径中获取顶点/片段着色器
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

void ShaderTools::printShaderLog(GLuint shader)
{
    int len = 0;
    int chWrittn = 0;
    char* log;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
    if (len > 0)
    {
        log = (char*)malloc(len);
        glGetShaderInfoLog(shader, len, &chWrittn, log);
        std::cout << "Shader Info Log: " << log << std::endl;
        free(log);
    }
}

void ShaderTools::printProgramLog(int prog)
{
    int len = 0;
    int chWrittn = 0;
    char* log;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &len);
    if (len > 0)
    {
        log = (char*)malloc(len);
        glGetProgramInfoLog(prog, len, &chWrittn, log);
        std::cout << "Program Info Log: " << log << std::endl;
        free(log);
    }
}

bool ShaderTools::checkOpenGLError()
{
    bool foundError = false;
    int glErr = glGetError();
    while (glErr != GL_NO_ERROR)
    {
        std::cout << "glError: " << glErr << std::endl;
        foundError = true;
        glErr = glGetError();
    }
    return foundError;
}

GLuint ShaderTools::createShaderProgram(const char* vertexShaderPath, const char* flagShaderPath)
{
    std::string vShaderStr = std::string(vertexShaderPath);
    std::string fShaderStr = std::string(flagShaderPath);
    const char* vshaderSource = vShaderStr.c_str();
    const char* fshaderSource = fShaderStr.c_str();

    GLint vertCompiled;
    GLint fragCompiled;
    GLint linked;

    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(vShader, 1, &vshaderSource, NULL);
    glShaderSource(fShader, 1, &fshaderSource, NULL);

    glCompileShader(vShader);
    checkOpenGLError();
    glGetShaderiv(vShader, GL_COMPILE_STATUS, &vertCompiled);
    if (vertCompiled != 1)
    {
        std::cout << "vertex compilation failed" << std::endl;
        printShaderLog(vShader);
    }

    glCompileShader(fShader);
    checkOpenGLError();
    glGetShaderiv(fShader, GL_COMPILE_STATUS, &fragCompiled);
    if (fragCompiled != 1)
    {
        std::cout << "fragment compilation failed" << std::endl;
        printShaderLog(fShader);
    }

    GLuint vfProgram = glCreateProgram();
    glAttachShader(vfProgram, vShader);
    glAttachShader(vfProgram, fShader);
    glLinkProgram(vfProgram);
    checkOpenGLError();
    glGetProgramiv(vfProgram, GL_LINK_STATUS, &linked);
    if (linked != 1)
    {
        std::cout << "linking failed" << std::endl;
        printProgramLog(vfProgram);
    }
    return vfProgram;
}
