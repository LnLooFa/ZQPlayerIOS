//
//  MainViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/2.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Boolean isShowDemo = false;
    if(isShowDemo){
        [self performSegueWithIdentifier:@"showDemo" sender:self];
    }else{
        [self performSegueWithIdentifier:@"showSplash" sender:self];
    }
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
