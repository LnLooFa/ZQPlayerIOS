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
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
    }];
    
    UIView* searchView = [[UIView alloc] init];
    searchView.translatesAutoresizingMaskIntoConstraints=NO;
    searchView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" alpha:1.0];
    searchView.layer.cornerRadius = 15;
    [headerView addSubview:searchView];
    
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView).mas_offset(10);
        make.left.mas_equalTo(headerView).mas_offset(15);
        make.right.mas_equalTo(headerView).mas_offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    NSArray *images = @[@"banner1",@"banner2",@"banner3",@"banner4"];
    WMLoopView *bannerView = [[WMLoopView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150) images:images autoPlay:YES delay:5.0];
    bannerView.translatesAutoresizingMaskIntoConstraints=NO;
    [headerView addSubview:bannerView];
    
    [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([searchView mas_bottom]).mas_offset(10);
        make.bottom.mas_equalTo([headerView mas_bottom]).mas_offset(-10);
        make.height.mas_equalTo(150);
    }];
    
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
