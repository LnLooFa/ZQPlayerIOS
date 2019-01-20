//
//  VideoListViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/16.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "VideoListViewController.h"
#import "WMLoopView.h"


@interface VideoListViewController ()

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIView* headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints=NO;
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    //左边 右边距
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[headerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView)]];
    
    UIView* searchView = [[UIView alloc] init];
    searchView.translatesAutoresizingMaskIntoConstraints=NO;
    searchView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" alpha:1.0];
    searchView.layer.cornerRadius = 15;
    [headerView addSubview:searchView];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[searchView]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    
    
    
    NSArray *images = @[@"banner1",@"banner2",@"banner3",@"banner4"];
    WMLoopView *bannerView = [[WMLoopView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150) images:images autoPlay:YES delay:5.0];
    bannerView.translatesAutoresizingMaskIntoConstraints=NO;
    [headerView addSubview:bannerView];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[bannerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bannerView)]];
    
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:searchView attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
    
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    
    //searchView 根据 子view 的高度适应， searchView不能设置高度，否则无效
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:150]];

    
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
