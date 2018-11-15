//
//  People.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/11/7.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "People.h"

@implementation People

// - 当将一个自定义对象保存到文件的时候就会调用该方法；
// - 在该方法中，说明如何存储自定义对象的属性,也就是说在该方法中说清楚存储自定义对象的哪些属性；

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.age forKey:@"age"];
}

// - 当文件中读取一个对象的时候就会调用该方法；
// - 在该方法中说明如何读取保存在文件中的对象,也就是说在该方法中说清楚怎么读取文件中的对象

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.age = [aDecoder decodeObjectForKey:@"age"];
    }
    return self;
}

@end
