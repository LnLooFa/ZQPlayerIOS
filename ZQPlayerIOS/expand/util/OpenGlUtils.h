//
//  OpenGlUtils.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>
@interface OpenGlUtils : NSObject
+ (GLuint)loadShader:(GLenum)type withFile:(NSString *)shaderFile;
+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;
@end
