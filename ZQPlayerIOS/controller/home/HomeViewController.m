//
//  HomeViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/6.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoListViewController.h"
#import "YellowViewController.h"

@interface HomeViewController ()

@property (nonatomic, nullable, copy) NSArray<NSString *> *titleArray;

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
//    self.menuViewStyle = WMMenuViewStyleSegmented;
    
}

- (void)viewDidAppear:(BOOL)animated{
    self.titleColorSelected = [UIColor whiteColor];
}


-(NSArray<NSString *> *)titleArray{
    if(!_titleArray){
        _titleArray = [NSArray arrayWithObjects:@"LOL",@"绝地求生",@"王者荣耀",@"星秀",
                     @"吃鸡手游",@"吃喝玩乐",@"主机",@"CF",
                     @"颜值",@"二次元", @"DNF",@"暴雪",@"我的世界", nil];
    }
    return _titleArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController{
    return self.titleArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index{
    return self.titleArray[index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index{
    return index == 0 ? [[VideoListViewController alloc] init] : [[UIViewController alloc] init];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView{
    return CGRectMake(0, kStatusBarHeight, self.view.frame.size.width, 40.0f);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height - originY);
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    CGFloat width = [super menuView:menu widthForItemAtIndex:index];
    return width + 10;
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
