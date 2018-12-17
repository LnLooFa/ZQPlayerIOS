//
//  AnimationViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/12/2.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "AnimationViewController.h"

@interface AnimationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *target;

@end

@implementation AnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)start:(id)sender {
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"position.y"];
    anima.fromValue = @(_target.center.y + 50);
    anima.toValue = @(_target.center.y + 100);
    anima.duration = 2;
    //1.2设置动画执行完毕之后不删除动画
    anima.removedOnCompletion=NO;
    //1.3设置保存动画的最新状态
    anima.fillMode=kCAFillModeForwards;
    [_target.layer addAnimation:anima forKey:nil];
}
- (IBAction)targetClick:(id)sender {
    NSLog(@"点击");
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
