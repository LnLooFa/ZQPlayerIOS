//
//  MyTabBarViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/11/29.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "RedViewController.h"
#import "GreenViewController.h"
@interface MyTabBarViewController ()

@end

@implementation MyTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.delegate = self;
    
    UIViewController* redController = [[RedViewController alloc] init];
    UITabBarItem *redItem = [[UITabBarItem alloc] initWithTitle:@"red" image:nil tag:0];
    redController.tabBarItem = redItem;
    
    UIViewController* greenController = [[GreenViewController alloc] init];
    UITabBarItem *greenItem = [[UITabBarItem alloc] initWithTitle:@"green" image:nil tag:1];
    greenController.tabBarItem = greenItem;
    
    NSMutableArray *viewControllersArray = [[NSMutableArray alloc] init];
    [viewControllersArray addObject:redController];
    [viewControllersArray addObject:greenController];
    self.viewControllers = viewControllersArray;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
