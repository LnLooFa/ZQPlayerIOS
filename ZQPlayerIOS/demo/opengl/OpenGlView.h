//
//  OpenGlView.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/3/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZQPlayerFrameVideo.h"
#import <GLKit/GLKit.h>
@interface OpenGlView : GLKView
- (void)render:(ZQPlayerFrameVideo *)frame;
@end
