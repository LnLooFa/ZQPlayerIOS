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
