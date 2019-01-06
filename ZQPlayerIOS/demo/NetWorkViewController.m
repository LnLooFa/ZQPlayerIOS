//
//  NetWorkViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/1.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "NetWorkViewController.h"

@interface NetWorkViewController ()
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *result2;


@end

@implementation NetWorkViewController

NSURLRequest * request;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *urlStr = @"http://193.112.65.251:8080/myuser/all";
    _urlLabel.text = urlStr;
    NSURL *url=[NSURL URLWithString:urlStr];
    request = [NSURLRequest requestWithURL:url];
}
- (IBAction)requestUrl:(id)sender {
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if(!connectionError){
            NSLog(@"请求成功");
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self->_resultLabel.text = result;
        }else{
            NSLog(@"请求失败");
        }
    }];
}
- (IBAction)requestUrl2:(id)sender {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSLog(@"请求成功");
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //切换到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_result2.text = result;
                
            });
        }else{
            NSLog(@"请求失败");
        }
    }];
    [task resume];
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
