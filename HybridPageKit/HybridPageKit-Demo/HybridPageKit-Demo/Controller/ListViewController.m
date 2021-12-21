//
// ListViewController.m
//
// Copyright (c) 2019 dequanzhu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "ListViewController.h"
#import "SingleWebViewController.h"
#import "WebComponentController.h"
#import "NativeComponentController.h"
#import "NestingWebViewController.h"
#import "NestingBannerController.h"

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
            _subTitleLabel.font = [UIFont systemFontOfSize:12.f];
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
             @"0":@[@"1. Single WebView Controller",@"可扩展、可复用的WKWebView实用"],
             @"1":@[@"2. Web Component Controller", @"替换WebView Dom元素为Native，支持滚动复用"],
             @"2":@[@"3. Native Component Controller", @"非Web类型底层页，多ScrollView滚动嵌套"],
             @"3":@[@"4. Nesting WebView Controller",@"典型内容页，WebView + Native多ScrollView滚动嵌套"],
             @"4":@[@"5. Nesting WebView Controller",@"典型内容页，自定义组件排序规则"],
             @"5":@[@"6. Nseting Banner Controller",@"支持头部Banner及折叠收起"],
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HybridPageKit";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
    UIColor *barTintColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.titleTextAttributes = titleTextAttributes;
        appearance.backgroundColor = barTintColor;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
        self.navigationController.navigationBar.barTintColor = barTintColor;
    }
    
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
    
    __kindof UIViewController *controller;
    
    if (indexPath.row == 0) {
        controller = [[SingleWebViewController alloc] init];
    } else if (indexPath.row == 1){
        controller = [[WebComponentController alloc] init];
    }else if (indexPath.row == 2){
        controller = [[NativeComponentController alloc] init];
    }else if (indexPath.row == 3){
        controller = [[NestingWebViewController alloc] init];
    }else if (indexPath.row == 4){
        controller = [[NestingWebViewController alloc] initWithUseCustomComparator:YES];
    }else if (indexPath.row == 5){
        controller = [[NestingBannerController alloc] init];
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
