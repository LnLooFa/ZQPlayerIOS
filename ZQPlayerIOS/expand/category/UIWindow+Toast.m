//
//  UIWindow+Toast.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "UIWindow+Toast.h"
#import "AppDelegate.h"
#import <Toast/UIView+Toast.h>

@implementation UIWindow (Toast)

+ (void)windowToastString:(NSString *)toastString
{
    UIWindow *mainWindow = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [mainWindow makeToast:toastString duration:1.0f position:[CSToastManager defaultPosition]];
}

@end
