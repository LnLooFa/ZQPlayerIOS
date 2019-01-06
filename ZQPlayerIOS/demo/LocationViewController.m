//
//  LocationViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/12/17.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "LocationViewController.h"
#import "CoreLocation/CoreLocation.h"

@interface LocationViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationInfo;
@property (weak, nonatomic) IBOutlet UILabel *log;

@property (strong, nonatomic) CLLocationManager* locationManager;
@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   

}


- (IBAction)startLocation:(id)sender {
    if([CLLocationManager locationServicesEnabled]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 10.0f;
        [self.locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8以上版本定位需要）
        _log.text = @"开始定位";
        [self.locationManager startUpdatingLocation];//开始定位
    }else{
        _log.text = @"请打开定位";
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    //当前所在城市的坐标值
    CLLocation *currLocation = [locations lastObject];
    _log.text = [NSString stringWithFormat:@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    _log.text = [NSString stringWithFormat:@"error:%d",error.code];
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
