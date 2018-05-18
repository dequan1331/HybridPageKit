//
//  FoldedViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "FoldedViewController.h"
#import "ArticleApi.h"
#import "ArticleModel.h"

@interface FoldedViewController()
@property(nonatomic,strong,readwrite)ArticleApi *api;
@property(nonatomic,strong,readwrite)ArticleModel *articleModel;
@end

@implementation FoldedViewController
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
    [self _getRemoteDataAndLoad];
}

#pragma mark -
- (NSArray<HPKController *> *)getValidComponentControllers{
    return @[
             [[FoldedController alloc]init],
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
                           topInsetOffset:0.f
                      extensionComponents:strongSelf.articleModel.extensionComponents];
    }];
}
@end
