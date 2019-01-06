//
//  SplashViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/3.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "SplashViewController.h"
#import "HomeTabBarViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"SplashViewController viewcontrollers 数量 %lu",[[[self navigationController] viewControllers] count]);
    [[[self navigationController] viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%lu - %@",(unsigned long)idx, obj);
    }];
    [self navigateToHomeTabBar];
//    [[self navigationController] pushViewController:homeViewController animated:true];
}

- (void)viewDidAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:true];
}

- (void)navigateToHomeTabBar{
    HomeTabBarViewController *homeViewController = [[HomeTabBarViewController alloc] init];
    NSArray<__kindof UIViewController *> *viewControllers = [[NSArray alloc] initWithObjects:homeViewController, nil];
    
    
    [[self navigationController] setViewControllers:viewControllers];
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
