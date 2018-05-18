//
//  BannerViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "BannerViewController.h"
#import "ArticleApi.h"
#import "ArticleModel.h"

@interface BannerViewController ()
@property(nonatomic,strong,readwrite)UILabel *bannerView;
@property(nonatomic,strong,readwrite)ArticleApi *api;
@property(nonatomic,strong,readwrite)ArticleModel *articleModel;
@end

@implementation BannerViewController
-(instancetype)init{
    self = [super initWithConfigBuilder:^(HPKViewConfig *defaultConfig) {
        defaultConfig.needWebView = NO;
    }];
    if (self) {
    }
    return self;
}

- (void)dealloc{
    if (_api) {
        [_api cancel];
        _api = nil;
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view addSubview:({
        _bannerView  = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200.f)];
        _bannerView.backgroundColor = [UIColor whiteColor];
        _bannerView.textAlignment = NSTextAlignmentCenter;
        _bannerView.numberOfLines = 0;
        _bannerView.font = [UIFont systemFontOfSize:40.f];
        _bannerView.text = @"HybridPageKit \n BannerView";
        _bannerView.textColor = [UIColor colorWithRed:28.f/255.f green:135.f/255.f blue:219.f/255.f alpha:1.f];
        [_bannerView.layer addSublayer:({
            CALayer *bottomLine = [[CALayer alloc]init];
            bottomLine.frame = CGRectMake(0, _bannerView.bounds.size.height -1, _bannerView.bounds.size.width, 1.f);
            bottomLine.backgroundColor = [UIColor lightGrayColor].CGColor;
            bottomLine;
        })];
        _bannerView;
    })];
    [self _getRemoteDataAndLoad];
}

#pragma mark -
- (NSArray<HPKController *> *)getValidComponentControllers{
    return @[
             [[RelateNewsController alloc]init],
             [[HotCommentController alloc]init],
             [[MediaController alloc]init]
             ];
}

-(void)_getRemoteDataAndLoad{
    __weak typeof(self) wself = self;
    _api = [[ArticleApi alloc]initWithApiType:kArticleApiTypeArticle completionBlock:^(NSDictionary *responseDic, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        strongSelf.articleModel = [[ArticleModel alloc]initWithDic:responseDic];
        [strongSelf setArticleDetailModel:strongSelf.articleModel
                           topInsetOffset:strongSelf.bannerView.frame.origin.y + strongSelf.bannerView.frame.size.height
                      extensionComponents:strongSelf.articleModel.extensionComponents];
    }];
}
@end
