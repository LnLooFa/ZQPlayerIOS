//
//  NetWorkViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/1.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "NetWorkViewController.h"
#import "User.h"
@interface NetWorkViewController ()
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *result2;

@property (weak, nonatomic) IBOutlet UILabel *result3;

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

- (IBAction)requestUrl3:(id)sender {
    NSString *urlStr = @"http://193.112.65.251:8080/myuser/all";
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSDictionary *dict = responseObject;
        @try {
            int code = [[dict objectForKey:@"code"] intValue];
            if (code == 0) {
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                NSDictionary *usersDict = [dataDict objectForKey:@"users"];
                NSArray *userlist = [User mj_objectArrayWithKeyValuesArray:usersDict];
                NSLog(@"请求成功  %lu ",(unsigned long)userlist.count);
                if(userlist != nil && userlist.count > 0){
                    User* user = userlist[0];
                    NSLog(@"请求成功  %@ ",user.name);
                }
                
            }
            else {
                NSString *message = [dict objectForKey:@"msg"];
                NSLog(@"请求失败 %@",message);
            }
        } @catch (NSException *exception) {
            NSLog(@"获取验证码报错 %@",exception);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败  %@ ",error);
    }];
}

- (IBAction)request4:(id)sender {
    NSString *urlStr = @"http://193.112.65.251:8080/live/list";
    NSDictionary* parmeters = @{
                                @"pageno" : @"1",
                                @"pagenum" : @"20",
                                @"cate" : @"lol",
                                @"room" : @"1",
                                @"version" : @"3.3.1.5978"
                                };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    /**设置请求超时时间*/
    manager.requestSerializer.timeoutInterval = 30.0f;
    /**设置相应的缓存策略*/
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    /**分别设置请求以及相应的序列化器*/
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    /**分别设置返回以及相应的反序列化器*/
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = response;
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:urlStr parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功  %@ ",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败  %@ ",error);
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
