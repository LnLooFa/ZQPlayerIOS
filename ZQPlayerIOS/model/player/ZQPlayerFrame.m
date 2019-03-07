//
//  ZQPlayerFrame.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/2/23.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ZQPlayerFrame.h"

@implementation ZQPlayerFrame

- (id)init {
    self = [super init];
    if (self) {
        _type = ZQPlayerFrameTypeNone;
        _data = nil;
    }
    return self;
}

@end
