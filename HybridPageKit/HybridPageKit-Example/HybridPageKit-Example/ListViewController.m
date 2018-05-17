//
//  ListViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "ListViewController.h"
#import "HybridViewController.h"
#import "BannerViewController.h"
#import "SingleWebViewController.h"
#import "FoldedViewController.h"

#pragma mark - _customListCell

@interface _customListCell : UICollectionViewCell
@property(nonatomic,strong,readwrite)UILabel *titleLabel;
@property(nonatomic,strong,readwrite)UILabel *subTitleLabel;
@end
@implementation _customListCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:({
            _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 10, frame.size.width, frame.size.height/2)];
            _titleLabel.font = [UIFont systemFontOfSize:18.f];
            _titleLabel;
        })];
        [self addSubview:({
            _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(28, frame.size.height/2 + 4, frame.size.width, frame.size.height/2 - 10)];
            _subTitleLabel.font = [UIFont systemFontOfSize:10.f];
            _subTitleLabel.numberOfLines = 2;
            _subTitleLabel.textColor = [UIColor lightGrayColor];
            _subTitleLabel;
        })];
    }
    return self;
}
@end

#pragma mark - ListViewController

@interface ListViewController ()<UICollectionViewDelegate , UICollectionViewDataSource>
@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,copy,readwrite) NSDictionary *cellInfoDic;
@end
@implementation ListViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        _cellInfoDic = @{
             @"0":@[@"1. Only WebView",@"单独WebView以及WbeView上的Native Component\n适用于简单新闻底层页"],
             @"1":@[@"2. Long WebView With Native Element",@"长度超过一屏的WebView,以及WebView内、外的Native组件\n适用于复杂新闻底层页 + 扩展阅读区 + 运营推广 + 评论等"],
             @"2":@[@"3. Short WebView With Native Element",@"长度小于一屏的WebView,以及WebView内、外的Native组件\n适用于复杂新闻底层页 + 扩展阅读区 + 运营推广 + 评论等"],
             @"3":@[@"4. BannerView With Native Element",@"顶部BannerView\n适用于顶部固定视频内容页"],
             @"4":@[@"5. FoldedView With Native Element",@"支持头部折叠收起\n适用于问题 & 回答类型内容页"],
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HybridPageKit";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];

    [self.view addSubview:({
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:239.f/255.f blue:240.f/255.f alpha:1.f];;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[_customListCell class]
            forCellWithReuseIdentifier:NSStringFromClass([self class])];
        _collectionView;
    })];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    __kindof HPKAbstractViewController *controller;
    
    if (indexPath.row == 0) {
        controller = [[SingleWebViewController alloc] init];
    } else if (indexPath.row == 1){
        controller = [[HybridViewController alloc] initWithShortContent:NO];
    }else if (indexPath.row == 2){
        controller = [[HybridViewController alloc] initWithShortContent:YES];
    }else if (indexPath.row == 3){
        controller = [[BannerViewController alloc] init];
    }else if (indexPath.row == 4){
        controller = [[FoldedViewController alloc] init];
    }else{
        //error
    }

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *cellInfoArray = [_cellInfoDic objectForKey:@(indexPath.row).stringValue];
    if([cell isKindOfClass:[_customListCell class]] && cellInfoArray.count > 0){
        ((_customListCell *)cell).titleLabel.text = [cellInfoArray firstObject];
        ((_customListCell *)cell).subTitleLabel.text = [cellInfoArray lastObject];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _cellInfoDic.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 75);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.f;
}
@end
