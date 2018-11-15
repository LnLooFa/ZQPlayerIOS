//
//  SplashViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/25.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    rightItem.title = @"hhh";
    self.navigationItem.rightBarButtonItem = rightItem;
    
//    CGRect r = [UIScreen mainScreen ].applicationFrame;
//    CGRect bounds = [[UIScreen mainScreen] applicationFrame];  //获取界面区域
    
}

- (void)viewDidLayoutSubviews{
    CGRect bounds = _scrollView.bounds;
    bounds.origin.y = 0;
    UIImageView* guideOne = [[UIImageView alloc] initWithFrame:CGRectMake(0, bounds.origin.y, bounds.size.width, bounds.size.height)];
    [guideOne setImage:[UIImage imageNamed:@"guide_one.png"]];
//    [guideOne setBackgroundColor:[UIColor redColor]];
    
    UIImageView* guideTwo = [[UIImageView alloc] initWithFrame:CGRectMake(bounds.size.width, bounds.origin.y, bounds.size.width, bounds.size.height)];
    [guideTwo setImage:[UIImage imageNamed:@"guide_two.png"]];
    
    
    UIImageView* guideThree = [[UIImageView alloc] initWithFrame:CGRectMake(bounds.size.width * 2, bounds.origin.y, bounds.size.width, bounds.size.height)];
    [guideThree setImage:[UIImage imageNamed:@"guide_three.png"]];
    [_scrollView addSubview:guideOne];
    [_scrollView addSubview:guideTwo];
    [_scrollView addSubview:guideThree];
    _scrollView.bounces = false;
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(bounds.size.width * 3, bounds.size.height);
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
