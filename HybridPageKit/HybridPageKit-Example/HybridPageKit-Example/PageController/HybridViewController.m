//
//  HybridViewController.m
//  HybridPageKit
//
//  Created by dequanzhu.
//  Copyright © 2018 HybridPageKit. All rights reserved.
//

#import "HybridViewController.h"
#import "ArticleApi.h"
#import "ArticleModel.h"
#import "HtmlRenderHandler.h"

@interface HybridViewController()<WKNavigationDelegate>
@property(nonatomic,strong,readwrite)ArticleApi *api;
@property(nonatomic,strong,readwrite)ArticleModel *articleModel;
@end

@implementation HybridViewController
-(instancetype)initWithShortContent:(BOOL)shortContent{
    self = [super initWithConfigBuilder:^(HPKViewConfig *defaultConfig) {
        defaultConfig.needWebView = YES;
        defaultConfig.webViewComponentPlaceHolderDomClass = HPKWebViewHandlerComponentClass;
    }];
    if (self) {
        [self _getRemoteDataWithShortContent:shortContent];
    }
    return self;
}

- (void)dealloc{
    if (_api) {
        [_api cancel];
        _api = nil;
    }
}

#pragma mark -
- (NSArray<HPKController *> *)getValidComponentControllers{
    return @[
             [[AdController alloc]init],
             [[VideoController alloc]init],
             [[GifController alloc]init],
             [[ImageController alloc]init],
             [[RelateNewsController alloc]init],
             [[HotCommentController alloc]init],
             [[MediaController alloc]init],
             [[TitleController alloc]init]
             ];
}

- (void)_getRemoteDataWithShortContent:(BOOL)shortContent{
    __weak typeof(self) wself = self;
    _api = [[ArticleApi alloc]initWithApiType: shortContent ? kArticleApiTypeShortArticle : kArticleApiTypeArticle completionBlock:^(NSDictionary *responseDic, NSError *error) {
        __strong __typeof(wself) strongSelf = wself;
        strongSelf.articleModel = [[ArticleModel alloc] initWithDic:responseDic];
        [strongSelf _renderAndLoadData];
    }];
}

- (void)_renderAndLoadData{
    __weak typeof(self) wself = self;
    [[HtmlRenderHandler shareInstance]
     asyncRenderHTMLString:self.articleModel.contentTemplateString
            componentArray:self.articleModel.webViewComponents
                completeBlock:^(NSString *finalHTMLString, NSError *error) {
                    __strong __typeof(wself) strongSelf = wself;
                   [strongSelf setArticleDetailModel:strongSelf.articleModel
                                        htmlTemplate:finalHTMLString
                             webviewExternalDelegate:strongSelf
                                   webViewComponents:strongSelf.articleModel.webViewComponents
                                 extensionComponents:strongSelf.articleModel.extensionComponents];
               }];
}

#pragma mark -
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    // custom webviewe delegate
}
@end
