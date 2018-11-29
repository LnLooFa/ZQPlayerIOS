//
//  ActionItemBean.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/21.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "ActionItemBean.h"

@implementation ActionItemBean

- (id)initWith:(NSString *)title target:(NSString*) target{
    _title = title;
    _target = target;
    return self;
}

@end
