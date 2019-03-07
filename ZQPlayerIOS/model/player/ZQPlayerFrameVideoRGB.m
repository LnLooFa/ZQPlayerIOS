//
//  ZQPlayerFrameVideoRGB.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/23.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ZQPlayerFrameVideoRGB.h"

@implementation ZQPlayerFrameVideoRGB


-(NSString*) description
{
    //返回一个字符串
    return [NSString stringWithFormat:@"height：%d, width：%d, position: %f, duration: %f, linesize: %lu",
            self.height,self.width,self.position,self.duration,(unsigned long)self.linesize];
}

@end
