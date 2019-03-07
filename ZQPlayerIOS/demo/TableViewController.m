//
//  ViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/2.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewAdapter.h"
#import "ActionItemBean.h"
@interface TableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property TableViewAdapter *tableViewAdapter;
@end

NSMutableArray *data;

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
     data = [[NSMutableArray alloc]init];
    NSString *title = [[NSString alloc] initWithFormat:@"Splash scrollview引导页"];
    [data addObject:[[ActionItemBean alloc]initWith:title target:@"SplashDemoViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"NSUserDefaults数据缓存" target:@"NSUserDefaultsViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"Image 拉伸" target:@"ImageViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"TabBar 实现 tabBarViewController" target:@"TabBarViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"UITabBarViewController 实践" target:@"MyTabBarViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"动画 实践" target:@"AnimationViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"定位" target:@"LocationViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"网络请求" target:@"NetWorkViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"Toast测试" target:@"ToastViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"图片加载测试" target:@"ImageLoaderViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"水平table测试" target:@"HorizontalTableViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"CollectionView测试" target:@"CollectionViewViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"布局约束测试" target:@"ConstraintTestViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"音频测试" target:@"AudioViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"视频测试" target:@"VideoViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"FFmpeg测试" target:@"FFmpegTestViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"AVPlayer测试" target:@"AVPlayerTestViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"ImagePicker测试" target:@"ImagePickerViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"多线程测试" target:@"ThreadTestViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"openGl显示图片测试" target:@"ShowPhotoViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"openGl2显示图片测试" target:@"GlShowPhotoViewController"]];
    [data addObject:[[ActionItemBean alloc]initWith:@"ffmpeg播放视频测试" target:@"PlayerVideoViewController"]];
    
    _tableViewAdapter = [[TableViewAdapter alloc] initWithSource:data Controller:self];
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = _tableViewAdapter;
    _tableView.delegate = _tableViewAdapter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
