//
//  TableViewAdapter.h
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/21.
//  Copyright © 2018年 johnwu. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "TableViewController.h"
#import "ActionItemBean.h"

@interface TableViewAdapter : NSObject <UITableViewDataSource>

@property (weak, nonatomic) NSMutableArray* source;
@property (weak, nonatomic) TableViewController* controller;

- (id)initWithSource:(NSMutableArray*) source Controller:(TableViewController*) controller;

@end
