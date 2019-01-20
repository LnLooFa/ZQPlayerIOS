//
//  TabBarViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/11/26.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "TabBarViewController.h"
#import "RedViewController.h"
#import "GreenViewController.h"
@interface TabBarViewController ()
#import "RedViewController.h"

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tabBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSLog(@"%@",item.title);
    if([@"red" isEqualToString:item.title]){
        UIViewController* redController = [[RedViewController alloc] init];
        [self addChildViewController:redController];
        [_container addSubview:redController.view];
        [_container setNeedsLayout];
    }else if([@"green" isEqualToString:item.title]){
        UIViewController* greenController = [[GreenViewController alloc] init];
        [self addChildViewController:greenController];
        [_container addSubview:greenController.view];

    }
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
