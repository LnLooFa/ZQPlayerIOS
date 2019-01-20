//
//  ConstraintTestViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/20.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "ConstraintTestViewController.h"

@interface ConstraintTestViewController ()

@end

@implementation ConstraintTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff" alpha:1.0];
    
    UIView* searchView = [[UIView alloc] init];
    searchView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" alpha:1.0];
    searchView.layer.cornerRadius = 15;
    searchView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:searchView];
    //    //左边距
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:15]];
    //    //右边距
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-15]];
    //左边 右边距
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[searchView]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
    //上边距
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[searchView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchView)]];
    
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:searchView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
    
    
    UIView* childView = [[UIView alloc] init];
    childView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:1.0];
    childView.translatesAutoresizingMaskIntoConstraints=NO;
    [searchView addSubview:childView];
    [searchView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[childView]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(childView)]];
    [searchView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:searchView attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [searchView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:searchView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    //searchView 根据 子view 的高度适应， searchView不能设置高度，否则无效
    [searchView addConstraint:[NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100]];
    
    
    
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
