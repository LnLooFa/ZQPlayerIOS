//
//  NSUserDefaultsViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2018/11/5.
//  Copyright © 2018年 johnwu. All rights reserved.
//

#import "NSUserDefaultsViewController.h"
#import "people.h"
@interface NSUserDefaultsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *mBtnRead;
@property (weak, nonatomic) IBOutlet UIButton *mBtnSave;
@property (weak, nonatomic) IBOutlet UITextField *mTfContent;

@property (weak, nonatomic) IBOutlet UITextField *archiverName;
@property (weak, nonatomic) IBOutlet UITextField *archiverAge;
@property (weak, nonatomic) IBOutlet UIButton *archiverBtn;


@property (weak, nonatomic) IBOutlet UITextField *unarchiverName;
@property (weak, nonatomic) IBOutlet UITextField *unarchiverAge;
@property (weak, nonatomic) IBOutlet UIButton *unarchiverBtn;


@end


@implementation NSUserDefaultsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_mBtnRead setTitle:@"读取normal" forState:UIControlStateNormal];
    
    [_mBtnRead setTitle:@"点击Highlighted" forState:UIControlStateHighlighted];
    
    _mBtnRead.titleLabel.font = [UIFont systemFontOfSize:30];
    
//    [_mBtnRead setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal]
    
    [_mBtnRead addTarget:self action:@selector(readData:) forControlEvents:UIControlEventTouchUpInside];
    
    [_mBtnSave addTarget:self action:@selector(saveData:) forControlEvents:UIControlEventTouchUpInside];
    
    _mBtnSave.backgroundColor = [UIColor redColor];
    _mBtnSave.layer.cornerRadius = 10;
    
    
    
    
    
    
    
    
}

//数据存储之归档解档 NSKeyedArchiver NSKeyedUnarchiver
- (IBAction)archiver:(id)sender {
    People *people = [[People alloc] init];
    people.name = _archiverName.text;
    people.age = _archiverAge.text;
    
    NSMutableData *archiverData = [[NSMutableData alloc] init];
    // 1.初始化
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiverData];
    // 2.归档
    [archiver encodeObject:people forKey:@"kPeople"];
    //3.完成归档
    [archiver finishEncoding];
    
    // 4.保存
    [[NSUserDefaults standardUserDefaults] setObject:archiverData forKey:@"kPeople"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (IBAction)unarchiver:(id)sender {
    // 解归档,获取保存的数据
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPeople"];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        People *people = [unarchiver decodeObjectForKey:@"kPeople"];
        [unarchiver finishDecoding];
        _unarchiverName.text = people.name;
        _unarchiverAge.text = people.age;
    }
}

-(void)readData:(UIButton*)button{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    _mTfContent.text = [user objectForKey:@"mTfContent"];
}

-(void)saveData:(UIButton*)button{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:_mTfContent.text forKey:@"mTfContent"];
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
