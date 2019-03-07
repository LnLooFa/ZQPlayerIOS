//
//  ShowPhotoViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/21.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ShowPhotoViewController.h"

@interface ShowPhotoViewController ()
//用于基于着色器的OpenGL渲染中的一个简单的照明和着色系统
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
//保存了用于盛放本例中用到的顶点数据的缓存的OpenGl ES标识符
@property (nonatomic,readonly) GLuint vertexBufferID;

@end

@implementation ShowPhotoViewController

typedef struct{
    GLKVector3 positionCoords;//GLKVector3类型的positionCoords
    GLKVector2 textureCoords;//GLKVector2类型的纹理坐标
}SceneVertex;

//初始化位置坐标和纹理坐标
static const SceneVertex vertices[] = {
    {{-1.0f,1.0f,0.0f},{0.0f,0.0f}},//前面三个数字是位置坐标，后面2个数字是纹理坐标
    {{1.0f,1.0f,0.0f},{1.0f,0.0f}},
    {{-1.0f,-1.0f,0.0f},{0.0f,1.0f}},
    {{1.0f,-1.0f,0.0f},{1.0f,1.0f}}
};


- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    //使用NSAssert()函数的一个运行时检查会验证self.view是否为正确的类型
    NSAssert([view isKindOfClass:[GLKView class]], @"viewcontroller’s view is not a GLKView");
    //分配一个新的EAGLContext的实例，并将它初始化为OpenGL ES 2.0
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //在任何其他的OpenGL ES配置或者渲染之前，应用的GLKview实例的上下文属性都要设置为当前
    [EAGLContext setCurrentContext:view.context];

    self.baseEffect = [[GLKBaseEffect alloc] init];
    //启用元素的默认颜色
    self.baseEffect.useConstantColor = GL_TRUE;
    //设置默认颜色  光源的颜色，设置成黑色的话，图片不出来
    self.baseEffect.constantColor = GLKVector4Make(1.0f,//red
                                                   1.0f,//green
                                                   1.0f,//blue
                                                   1.0f);//alpha
    //生成纹理，由于UIKit的坐标系Y轴与OpenGL ES的Y轴刚好上下颠倒，因此如果图片不加任何处理的话，在贴图后将是颠倒显示
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scenery" ofType:@"jpg"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:nil];
//    CGImageRef imageRef = [[UIImage imageNamed:@"butterfly"] CGImage];
//    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    
    //贴图纹理
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    //设置背景色
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    //1. 生成缓存ID
    glGenBuffers(1, &_vertexBufferID);
    //2.
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    //3.填充数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    NSLog(@"drawInRect");
    [self.baseEffect prepareToDraw];
    //清除缓存，设成背景色
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //4. 启用顶点坐标（x, y, z）
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //5. 类型，成员个数，类型，规范化，间隔，偏移
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoords));
    //4.1 启用纹理坐标(u, v)
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    //5.1 设置纹理坐标
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoords));
    
    //6. 绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)dealloc
{
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];

    glDeleteBuffers(1, &_vertexBufferID);
    _vertexBufferID = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
