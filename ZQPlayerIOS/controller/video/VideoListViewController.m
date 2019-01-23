//
//  VideoListViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/16.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "VideoListViewController.h"
#import <SDCycleScrollView.h>

static const CGFloat MJDuration = 2.0;

@interface VideoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView * collectionView;
@property (strong, nonatomic) NSMutableArray *colors;
@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //1.初始化layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumLineSpacing = 10;//行距
    flowLayout.minimumInteritemSpacing = 5;//间距
    self.collectionView =[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    //注意 自定义 的cell  xib  用registerNib
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoItemCell" bundle:nil] forCellWithReuseIdentifier:@"reuseVideoItemCell"];
    
    [self.view addSubview:self.collectionView];
//    self.collectionView.contentInset = UIEdgeInsetsMake(200.0, .0, .0, .0);

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
    }];
    
    
    
    __weak __typeof(self) weakSelf = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"color"];
    // 下拉刷新
    self.collectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 增加5条假数据
        for (int i = 0; i<10; i++) {
            [weakSelf.colors insertObject:MJRandomColor atIndex:0];
        }

        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];

            // 结束刷新
            [weakSelf.collectionView.mj_header endRefreshing];
        });
    }];
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 增加5条假数据
        for (int i = 0; i<5; i++) {
            [weakSelf.colors addObject:MJRandomColor];
        }
        
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            // 结束刷新
            [weakSelf.collectionView.mj_footer endRefreshing];
        });
    }];
    [self.collectionView.mj_header beginRefreshing];

}

-(UIView*)setUpHeaderVie{
    UIView* headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints=NO;
    headerView.backgroundColor = [UIColor whiteColor];
    
    
    UIView* searchView = [[UIView alloc] init];
    searchView.translatesAutoresizingMaskIntoConstraints=NO;
    searchView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" alpha:1.0];
    searchView.layer.cornerRadius = 15;
    [headerView addSubview:searchView];
    
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView).mas_offset(10);
        make.left.mas_equalTo(headerView).mas_offset(15);
        make.right.mas_equalTo(headerView).mas_offset(-15);
        make.height.mas_equalTo(30);
    }];
    
    NSArray *images = @[@"banner1",@"banner2",@"banner3",@"banner4"];
    SDCycleScrollView *bannerView = [[SDCycleScrollView alloc] init];
    bannerView.autoScrollTimeInterval = 5;
    bannerView.currentPageDotColor = kRGBColorA(0, 0, 0, 0.7);
    bannerView.pageDotColor = kRGBColorA(0, 0, 0, 0.3);
    bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    bannerView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:bannerView];
    bannerView.imageURLStringsGroup = images;
    [bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([searchView mas_bottom]).mas_offset(10);
        make.bottom.mas_equalTo([headerView mas_bottom]).mas_offset(-10);
        make.left.mas_equalTo(headerView);
        make.right.mas_equalTo(headerView);
        make.height.mas_equalTo(150);
    }];
    return headerView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kScreenWidth, 220);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        UIView* headerView = [self setUpHeaderVie];
        [header addSubview:headerView];
        [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(header);
        }];
        
        reusableView = header;
    }
    reusableView.backgroundColor = [UIColor greenColor];
    if (kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerview.backgroundColor = [UIColor purpleColor];
        reusableView = footerview;
    }
    return reusableView;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colors.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(kScreenWidth / 2 - 5 , 120);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseVideoItemCell" forIndexPath:indexPath];
    if(!cell){
        //在xib文件中设置了 reuseIdentifier，，才能复用
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"VideoItemCell" owner:self options:nil];
        cell = [nibViews objectAtIndex:0];
    }
    UIImageView *pic = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
    pic.backgroundColor = self.colors[indexPath.row];
    nameLab.text = [NSString stringWithFormat: @"%ld", (long)indexPath.row];
    return cell;
}


- (NSMutableArray *)colors
{
    if (!_colors) {
        self.colors = [NSMutableArray array];
    }
    return _colors;
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
