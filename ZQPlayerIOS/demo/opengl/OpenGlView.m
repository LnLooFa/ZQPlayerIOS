//
//  OpenGlView.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "OpenGlView.h"
#import "OpenGlUtils.h"

#define VERTEX_ATTRIBUTE_POSITION   0
#define VERTEX_ATTRIBUTE_TEXCOORD   1
@interface OpenGlView (){
    GLfloat _vec4Position[8];
    GLfloat _vec2Texcoord[8];
    GLfloat _mat4Projection[16];
    
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _programHandle;
    GLint _backingWidth;
    GLint _backingHeight;
    
    GLuint _projectionSlot;
    
    GLuint _texture;
    GLint _sampler;
}
@end

@implementation OpenGlView

-(instancetype)init{
    self = [super init];
    if (self) {
        if (![self initVars]) {
            self = nil;
            return nil;
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (![self initVars]) {
            self = nil;
            return nil;
        }
    }
    return self;
}

- (BOOL)initVars {
    _vec4Position[0] = -1; _vec4Position[1] = -1;
    _vec4Position[2] =  1; _vec4Position[3] = -1;
    _vec4Position[4] = -1; _vec4Position[5] =  1;
    _vec4Position[6] =  1; _vec4Position[7] =  1;
    
    _vec2Texcoord[0] = 0; _vec2Texcoord[1] = 1;
    _vec2Texcoord[2] = 1; _vec2Texcoord[3] = 1;
    _vec2Texcoord[4] = 0; _vec2Texcoord[5] = 0;
    _vec2Texcoord[6] = 1; _vec2Texcoord[7] = 0;
    
    //单位矩阵
    for(int i = 0;i < 16; i++){
        _mat4Projection[i] = 0;
    }
    for(int i = 0;i < 4; i++){
        _mat4Projection[i * 5] = 0;
    }
    
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (_context == nil) {
        NSLog(@"EAGLContext 生成 错误");
    };
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"setCurrentContext 错误");
    };
    
    // render buffer
    glGenRenderbuffers(1, &_renderBuffer);
    //绑定buffer 到 GL_RENDERBUFFER（可理解为变量）
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    // frame buffer
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    
    // Create program
    GLuint program = glCreateProgram();
    if (program == 0) {
        NSLog(@"create program.错误 ");
        return NO;
    }
    
    // 生成着色器 Load shaders
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *vertexShaderFile = [bundle pathForResource:@"OpenGlVertexShader" ofType:@"glsl"];
    NSString *fragmentShaderFile = [bundle pathForResource:@"OpenGlRGBFragmentShader" ofType:@"glsl"];
    GLuint vertexShader = [OpenGlUtils loadShader:GL_VERTEX_SHADER withFile:vertexShaderFile];
    GLuint fragmentShader = [OpenGlUtils loadShader:GL_FRAGMENT_SHADER withFile:fragmentShaderFile];
    // 添加到 program 中 Attach shaders
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // 绑定 ：将glsl文件代码中的变量 绑定到 常量上，也可以用 GLES20.glGetAttribLocation 动态获取
    glBindAttribLocation(program, VERTEX_ATTRIBUTE_POSITION, "position");
    glBindAttribLocation(program, VERTEX_ATTRIBUTE_TEXCOORD, "texcoord");
    //    _projectionSlot = glGetUniformLocation(program, "projection");
    
    // 链接 Link program
    glLinkProgram(program);
    
    // Check status
    GLint linked = 0;
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (linked == 0) {
        GLint length = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
        if (length > 1) {
            char *log = malloc(sizeof(char) * length);
            glGetProgramInfoLog(program, length, NULL, log);
            NSLog(@"FAILED to link program, error: %s", log);
            free(log);
        }
        
        glDeleteProgram(program);
        return NO;
    }
    
    // 应用 程序代码
    glUseProgram(program);
    
    _programHandle = program;
    //    [self render];
    
    return YES;

    
}


//渲染
- (void)render:(ZQPlayerFrameVideo *)frame {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    // Set frame 字节对齐
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (_texture == 0) {
        glGenTextures(1, &_texture);
    }
    
    if (_texture == 0) {
        NSLog(@"glGenTextures 错误");
        return;
    };
    //绑定纹理 到 GL_TEXTURE_2D  之后 对 GL_TEXTURE_2D的操作会应用到_texture
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, frame.format, frame.width, frame.height, 0, frame.format, GL_UNSIGNED_BYTE, frame.data.bytes);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    if (_sampler == -1) {
        _sampler = glGetUniformLocation(_programHandle, "s_texture");
        if (_sampler == -1) {
            NSLog(@"采样获取sampler 错误");
        };
    }
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(_sampler, 0);
    
    
    //    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, _mat4Projection);
    glVertexAttribPointer(VERTEX_ATTRIBUTE_POSITION, 2, GL_FLOAT, GL_FALSE, 0, _vec4Position);
    glEnableVertexAttribArray(VERTEX_ATTRIBUTE_POSITION);
    glVertexAttribPointer(VERTEX_ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, _vec2Texcoord);
    glEnableVertexAttribArray(VERTEX_ATTRIBUTE_TEXCOORD);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //显示
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
