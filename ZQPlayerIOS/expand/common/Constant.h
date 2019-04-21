//
//  Constant.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/4/21.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

static NSString * kBaseUrl = @"http://193.112.65.251:1234";

#define kLiveListUrl [NSString stringWithFormat:@"%@/live/list", kBaseUrl]
#define kLiveItemDetailUrl [NSString stringWithFormat:@"%@/live/list/item", kBaseUrl]

#endif /* Constant_h */
