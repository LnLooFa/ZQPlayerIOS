//
//  TableViewAdapter.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/10/21.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "TableViewAdapter.h"

@interface TableViewAdapter ()

@end

@implementation TableViewAdapter

- (id)initWithSource:(NSMutableArray *)source Controller:(TableViewController *)controller{
    self.source = source;
    self.controller = controller;
    return self;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _source.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    ActionItemBean *bean = [_source objectAtIndex:[indexPath row]];
//    cell.textLabel.text = bean.title;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionItemLayout"];
    if(!cell){
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"ActionItemLayout" owner:self options:nil];
        cell = [nibViews objectAtIndex:0];
    }
    UIImageView *pic = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
    UILabel *ageLab = (UILabel *)[cell viewWithTag:3];
    
    [nameLab setText:@"张三6"];
    [ageLab setText:@"16"];
    
    return cell;
}


@end


