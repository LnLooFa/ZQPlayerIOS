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
    NSString *title = [[NSString alloc] initWithFormat:@"SplashViewController"];
    [data addObject:[[ActionItemBean alloc]initWith:title]];
    
    [data addObject:[[ActionItemBean alloc]initWith:@"NSUserDefaultsViewController"]];
    
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
