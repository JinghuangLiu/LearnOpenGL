//
//  BaseOpenGLVC.h
//  demo
//
//  Created by empty on 2024/5/6.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
NS_ASSUME_NONNULL_BEGIN

@interface BaseOpenGLVC : UIViewController
@property (nonatomic, strong,readonly) EAGLContext *mContext;
@property (nonatomic, assign,readonly) GLuint myProgram;
- (void)compileAndLinkShader:(NSString *)vertFile fragFile:(NSString *)fragFile;
@property (nonatomic, assign) GLuint depthRenderbuffer;
@end

NS_ASSUME_NONNULL_END
