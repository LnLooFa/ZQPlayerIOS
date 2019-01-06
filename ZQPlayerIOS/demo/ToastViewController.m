//
//  ToastViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ToastViewController.h"
#import "UIWindow+Toast.h"
@interface ToastViewController ()

@end

@implementation ToastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)showToast:(id)sender {
    [UIWindow windowToastString:@"toast show"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
