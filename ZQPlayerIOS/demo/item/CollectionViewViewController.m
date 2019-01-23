//
//  CollectionViewViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/9.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "CollectionViewViewController.h"
#import "MyCollectionViewCell.h"

@interface CollectionViewViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(130, 130);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 2;
    
//    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 244, self.view.frame.size.width,130) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.collectionViewLayout = layout;
//    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    //注意 自定义 的cell  xib  用registerNib
    [self.collectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
//    [cell.myImage setImage:[UIImage imageNamed:@"goldImage"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *myCell = (MyCollectionViewCell *)cell;
    if(indexPath.row == 1){

        NSURL *photourl = [NSURL URLWithString:@"http://img4.imgtn.bdimg.com/it/u=967395617,3601302195&fm=26&gp=0.jpg"];
        [myCell.myImage sd_setImageWithURL:photourl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            NSLog(@"错误信息:%@",error);

        }];
    }else{
        [myCell.myImage setImage:[UIImage imageNamed:@"goldImage"]];
    }
    
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
