//
//  NetworkingManager.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/24.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkingManager : AFHTTPSessionManager
/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)shareManager;
@end
