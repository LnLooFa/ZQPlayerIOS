//
//  ActionItemBean.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/21.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionItemBean : NSObject
@property NSString* title;
@property NSString* target;
- (id) initWith:(NSString*) title target:(NSString*) target;

@end
