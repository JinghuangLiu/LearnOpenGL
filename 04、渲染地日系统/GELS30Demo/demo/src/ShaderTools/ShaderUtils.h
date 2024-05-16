//
//  ShaderUtils.h
//  demo
//
//  Created by 刘靖煌 on 2024/5/15.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include "OpenGLES.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShaderUtils : NSObject

@property (nonatomic, assign) GLuint myProgram;

+ (instancetype)sharedInstance;

/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *  @param vert 顶点着色器
 *  @param frag 片元着色器
 *
 *  @return 编译成功的shaders
 */
- (GLuint)loadShaders:(NSString *)vert frag:(NSString *)frag;

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

- (void)linkShader;

@end

NS_ASSUME_NONNULL_END
