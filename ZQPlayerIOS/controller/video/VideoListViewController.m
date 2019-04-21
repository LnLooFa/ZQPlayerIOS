//
//  VideoListViewController.m
//  ZQPlayerIOS
//
//  Created by johnwu on 2019/1/16.
//  Copyright © 2019年 johnwu. All rights reserved.
//

#import "VideoListViewController.h"
#import <SDCycleScrollView.h>
#import "NetworkingManager.h"
#import "VideoListItemModel.h"
#import "VideoPlayViewController.h"

static const CGFloat MJDuration = 2.0;

@interface VideoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView * collectionView;
@property(strong, nonatomic) NSMutableArray *videoList;
@property(assign, nonatomic) NSInteger pageNumber;
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
        make.left.mas_equalTo(self.view).mas_offset(5);
        make.right.mas_equalTo(self.view).mas_offset(-5);
    }];
    
    // 下拉刷新
    self.collectionView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:self.pageNumber isRefresh:true];
    }];
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadData:self.pageNumber isRefresh:false];
    }];
    [self.collectionView.mj_header beginRefreshing];

}

-(void)loadData:(NSInteger)page isRefresh:(Boolean)isRefresh{
    
    if(isRefresh){
        self.pageNumber = 1;
    }
    NSString *pageNumberString = [NSString stringWithFormat:@"%ld",page*20];
    NSDictionary* parmeters = @{
                                @"offset" : pageNumberString,
                                @"limit" : @"20",
                                @"live_type" : @"",
                                @"game_type" : @"ow"
                                };
    [[NetworkingManager shareManager] POST:kLiveListUrl parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        @try {
            int code = [[dict objectForKey:@"code"] intValue];
            if (code == 1) {
                NSDictionary *dataDict = [dict objectForKey:@"data"];
                NSArray *videolist = [VideoListItemModel mj_objectArrayWithKeyValuesArray:dataDict];
                if(videolist != nil && videolist.count > 0){
                    if(page == 1){
                        [self.videoList removeAllObjects];
                    }
                    self.pageNumber++;
                    [self.videoList addObjectsFromArray:videolist];
                }
                [self.collectionView reloadData];
            }else {
                NSString *message = [dict objectForKey:@"msg"];
                NSLog(@"请求失败 %@",message);
            }
        } @catch (NSException *exception) {
            NSLog(@"获取验证码报错 %@",exception);
        }
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败  %@ ",error);
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

-(UIView*)setUpHeaderVie{
    UIView* headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints=NO;
    headerView.backgroundColor = [UIColor whiteColor];
    
    
    UIView* searchView = [[UIView alloc] init];
    searchView.translatesAutoresizingMaskIntoConstraints=NO;
    searchView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4" alpha:1.0];
    searchView.layer.cornerRadius = 15;
    UILabel* searchLabel =[[UILabel alloc] init];
    UIImageView* searchScan =[[UIImageView alloc] init];
    [searchView addSubview:searchLabel];
    [searchView addSubview:searchScan];
    
    [headerView addSubview:searchView];
    searchLabel.font = [UIFont systemFontOfSize:14];
    searchLabel.text = @"一起看|S8|轩子巨2兔子";
    UIImage *imageScan=[UIImage imageNamed:@"icon_scan"];
    searchScan.image=imageScan;
    
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(headerView).mas_offset(10);
        make.left.mas_equalTo(headerView).mas_offset(15);
        make.right.mas_equalTo(headerView).mas_offset(-15);
        make.height.mas_equalTo(30);
    }];
    [searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo([searchView mas_centerY]);
        make.centerX.mas_equalTo([searchView mas_centerX]);
    }];
    [searchScan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo([searchView mas_right]).mas_offset(-10);
        make.centerY.mas_equalTo([searchView mas_centerY]);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
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
        make.left.mas_equalTo(headerView);
        make.right.mas_equalTo(headerView);
        make.height.mas_equalTo(150);
    }];
    
    UIView* titleView = [[UIView alloc] init];
    UIImageView* iconLeft =[[UIImageView alloc] init];
    UILabel* labelLeft =[[UILabel alloc] init];
    UIImageView* iconArrow =[[UIImageView alloc] init];
    UILabel* labelRight =[[UILabel alloc] init];
    [titleView addSubview:iconLeft];
    [titleView addSubview:labelLeft];
    [titleView addSubview:iconArrow];
    [titleView addSubview:labelRight];
    [headerView addSubview:titleView];
    
    
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo([bannerView mas_bottom]).mas_offset(10);
        make.bottom.mas_equalTo([headerView mas_bottom]).mas_offset(-20);
        make.left.mas_equalTo(headerView).mas_offset(5);
        make.right.mas_equalTo(headerView).mas_offset(-5);
        make.height.mas_equalTo(40);
    }];
    
    UIImage *image1=[UIImage imageNamed:@"icon_heart_title_left"];
    iconLeft.image=image1;
    UIImage *image2=[UIImage imageNamed:@"icon_right_arrow"];
    iconArrow.image=image2;
    labelLeft.text = @"全部直播";
    labelLeft.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    labelRight.text = @"S8全球总决赛热播中";
    [iconLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo([titleView mas_centerY]);
        make.left.mas_equalTo(titleView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    [labelLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo([titleView mas_centerY]);
        make.left.mas_equalTo([iconLeft mas_right]);
        
    }];
    [iconArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo([titleView mas_centerY]);
        make.left.mas_equalTo([labelLeft mas_right]);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
    }];
    [labelRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo([titleView mas_centerY]);
        make.right.mas_equalTo(titleView);
    }];
    return headerView;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kScreenWidth, 270);
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
    return self.videoList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenWidth - 10) / 2 - 5 , 120);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseVideoItemCell" forIndexPath:indexPath];
    if(!cell){
        //在xib文件中设置了 reuseIdentifier，，才能复用
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"VideoItemCell" owner:self options:nil];
        cell = [nibViews objectAtIndex:0];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImageView *pic = (UIImageView *)[cell viewWithTag:1];
    pic.layer.cornerRadius = 5;
    pic.clipsToBounds = YES;
    UILabel *nameLab = (UILabel *)[cell viewWithTag:2];
    VideoListItemModel* item = self.videoList[indexPath.row];
    [pic sd_setImageWithURL:[NSURL URLWithString:item.live_img]];
    nameLab.text = item.live_title;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoListItemModel* item = self.videoList[indexPath.row];
    VideoPlayViewController* playController = [[VideoPlayViewController alloc] init];
    playController.live_id =item.live_id;
    playController.live_type =item.live_type;
    playController.game_type =item.game_type;
    [self.navigationController pushViewController:playController animated:true];
}


- (NSMutableArray *)videoList
{
    if (!_videoList) {
        self.videoList = [NSMutableArray array];
    }
    return _videoList;
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
